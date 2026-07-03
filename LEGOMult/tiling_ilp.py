"""
tiling_ilp.py  --  STEP 1 of the two-step flow.

Partition the Wa x Wb multiplier board into DSP / Booth(level-L) / LUT tiles by
solving a set-partition ILP.  Unlike the JOINT tiling+compression ILP of
Boettcher & Kumm (arXiv:2407.03962) -- which is optimal but does not scale to
large W -- this is the tiling half of a two-step decomposition (Step 1 tiling,
Step 2 LUT+CARRY4 compression), each ILP tractable on its own.

    minimise   sum_t pp_pin_weight(t) x_t
    s.t.       for every board cell (i,j):  sum_{t covers (i,j)} x_t == 1
               sum_{t is DSP} x_t  <=  max_dsp
               x_t in {0,1}

The Step-1 objective is the weighted number of partial products left for Step 2
plus Booth tile build cost.  DSP/Booth tiles are internally multiplied and
contribute IGP result bits, each counted with weight 1 because it occupies one
LUT input pin.  LUT residual cells contribute OIP bits, each counted with
weight 2 because an original-input product consumes two LUT input pins.  Booth
tiles also add their own structural LUT cost so high Booth levels are not
under-priced by only looking at the reduced PP heap.  Detailed LUT+CARRY4
compression is still handled by Step 2.

If gurobipy is unavailable, or the model is larger than the (restricted-license)
solver can handle, a deterministic greedy tiler returns a valid exact cover so
the rest of the flow (merge, RTL, verification) still runs.  Pass
use_gurobi=False to force the greedy path.
"""

from tiles import (Tile, enumerate_candidate_tiles, lut_tile_cost,
                   lut_max_shape_for_booth_level,
                   booth_tile_cost, booth_level_max_height,
                   _norm_levels, DSP_UNSIGNED, DSP_SIGNED)
from compressors import all_compressors


# --------------------------------------------------------------------------- #
#  Step-1 weighted remaining-PP objective
# --------------------------------------------------------------------------- #
#  The default Step-1 objective is:
#
#        minimise   sum_t (pp_pin_weight(t) + booth_own_lut(t)) * x_t
#
#  * LUT residual cells are OIP bits.  Each original-input product consumes two
#    LUT input pins in Step 2 (a_i and b_j), so a LUT h*w rectangle contributes
#    2*h*w weighted PP.
#  * DSP and BOOTH tiles are internally multiplied/pre-compressed and contribute
#    IGP result bits.  Each IGP occupies one LUT input pin, so a h*w hard tile
#    contributes h+w weighted PP bits (one opaque result vector).
#
#  Older helpers below can still compute own_LUT + f_LC for diagnostics, but the
#  solver default and reports use weighted remaining PP plus Booth own LUT cost.
# --------------------------------------------------------------------------- #
def _lc_envelope_params(use_lut_carry=True):
    """(SLOPE, FLOOR) of the convex envelope of f_LC, derived from the library.
    SLOPE = 1 / (max same-column bits a single LUT removes); FLOOR = 2."""
    comps = all_compressors(use_lut_carry=use_lut_carry)
    best = 0.0
    for s in comps.values():
        net = (s['oip_c'] + s['igp_c']) - s['gen_c']      # same-column removed
        if net >= 1 and s['cost'] >= 1:
            best = max(best, net / float(s['cost']))
    slope = (1.0 / best) if best > 0 else 1.0
    return slope, 2


def flc_table(hmax, use_lut_carry=True):
    """Exact min #LUT to reduce an isolated heap column of height n to <=2,
    using THIS project's compressor library (DP).  f_LC(0..2)=0."""
    comps = all_compressors(use_lut_carry=use_lut_carry)
    moves = []
    for s in comps.values():
        insame = s['oip_c'] + s['igp_c']
        if insame >= 1 and (insame - s['gen_c']) >= 1:
            moves.append((insame, s['gen_c'], s['cost']))
    f = [0] * (hmax + 1)
    for n in range(3, hmax + 1):
        best = None
        for (insame, gen, cost) in moves:
            if insame <= n:
                c = cost + f[n - insame + gen]
                if best is None or c < best:
                    best = c
        f[n] = best if best is not None else 0
    return f


def tile_column_bits(t):
    """How many heap bits tile t deposits into each absolute column (i+j)."""
    d = {}
    if t.kind == 'LUT':
        for (i, j) in t.cells():
            d[i + j] = d.get(i + j, 0) + 1
    else:                                  # BOOTH / DSP : one opaque output row
        base = t.col_offset
        for b in range(t.h + t.w):
            d[base + b] = d.get(base + b, 0) + 1
    return d


def tile_own_cost(t):
    """Real build cost of a tile in LUT6 (no compression term)."""
    if t.kind == 'LUT':
        return lut_tile_cost(t.h, t.w)
    if t.kind == 'BOOTH':
        k = t.w if t.booth_axis == 'a' else t.h
        return booth_tile_cost(t.level, k)             # structural L*(k+1)
    if t.kind == 'DSP':
        return 0                                       # constrained by budget
    raise ValueError(t.kind)


def tile_pp_weight(t):
    """Weighted remaining partial products passed to Step 2.

    DSP/BOOTH output IGP bits each occupy one LUT input pin, so they count as
    h+w.  LUT residual OIP bits each need two operand pins, so they count as
    2*h*w.
    """
    if t.kind == 'LUT':
        return 2 * t.h * t.w
    if t.kind in ('BOOTH', 'DSP'):
        return t.h + t.w
    raise ValueError(t.kind)


def tile_booth_own_cost(t):
    """Booth tile structural LUT cost added to the Step-1 objective.

    DSP cost is controlled by max_dsp and LUT residual own cost is already
    represented as OIP pins, so only BOOTH gets this extra build-cost term.
    """
    return tile_own_cost(t) if t.kind == 'BOOTH' else 0


def tile_step1_objective_cost(t):
    """Per-tile default Step-1 objective: weighted PP + Booth own LUT cost."""
    return tile_pp_weight(t) + tile_booth_own_cost(t)


def tile_packing_coeff(t):
    """Objective coefficient of a HARD tile in the packing formulation.

    Exact-cover weighted-PP objective = sum_hard[pp+booth_own] + 2*(LUT cells).
    LUT cells = Wa*Wb - sum_hard(area), so dropping the constant 2*Wa*Wb the
    objective becomes sum_hard[pp_weight + booth_own - 2*area] over a packing
    (each cell covered at most once).  Coefficients are negative, so the solver
    maximises useful hard coverage; the LUT residual is implicit.
    """
    return tile_pp_weight(t) + tile_booth_own_cost(t) - 2 * t.area


def tile_colcost_coeff(t):
    """Per-hard-tile coefficient of the column-aware (OIP/IGP-split) objective.

    Estimate = Booth own LUT + sum_cols [ (2/3) O_c + max(0,(G_c-2)/2) ].
    O_c (OIP height) = LUT residual cells on diagonal c; LUT cells =
    board_cells - sum_hard(area), so (2/3) O_c contributes a constant
    (2/3)*board minus (2/3)*area per chosen hard tile.  Dropping the constant,
    the per-tile coefficient is booth_own(t) - (2/3)*area(t); the G_c (IGP) term
    is added separately as per-column epigraphs in solve_tiling.

    OIP ~ 2/3 LUT/bit (3 OIP -> 2 IGP costs 2 LUT) and IGP ~ 1/2 LUT/bit above
    the free 2 rows (CARRY4 chain body cII: 3->1, nets 2 per LUT)."""
    return tile_booth_own_cost(t) - (2.0 / 3.0) * t.area


def tiling_colcost(tiles, Wa, Wb):
    """Realised column-aware cost: Booth own LUT + per-column (2/3)*OIP +
    max(0,(IGP-2)/2).  OIP = LUT cells per diagonal, IGP = DSP/Booth opaque
    output bits per column.  Returns (total, booth_own, oip, igp)."""
    nCols = Wa + Wb
    O = [0] * nCols
    G = [0] * nCols
    for t in tiles:
        if t.kind == 'LUT':
            for (i, j) in t.cells():
                O[i + j] += 1
        else:
            base = t.col_offset
            for b in range(t.h + t.w):
                G[base + b] += 1
    booth_own = sum(tile_booth_own_cost(t) for t in tiles)
    oip = sum((2.0 / 3.0) * O[c] for c in range(nCols))
    igp = sum(max(0.0, (G[c] - 2) / 2.0) for c in range(nCols))
    return booth_own + oip + igp, booth_own, oip, igp


def tiling_weighted_pp_cost(tiles):
    """Return (total, igp_weight, oip_weight) for remaining-PP diagnostics."""
    igp = 0
    oip = 0
    for t in tiles:
        w = tile_pp_weight(t)
        if t.kind == 'LUT':
            oip += w
        else:
            igp += w
    return igp + oip, igp, oip


def tiling_step1_objective_cost(tiles):
    """Return (objective_total, weighted_pp_total, booth_own_lut_total)."""
    weighted_pp = tiling_weighted_pp_cost(tiles)[0]
    booth_own = sum(tile_booth_own_cost(t) for t in tiles)
    return weighted_pp + booth_own, weighted_pp, booth_own


def tiling_cost(tiles, Wa, Wb, use_lut_carry=True):
    """Exact Step-1 objective of a tiling: own LUTs + per-column f_LC.
    Returns (total, own, compression)."""
    nCols = Wa + Wb
    f = flc_table(nCols + 8, use_lut_carry)
    H = [0] * nCols
    own = 0
    for t in tiles:
        own += tile_own_cost(t)
        for c, n in tile_column_bits(t).items():
            if 0 <= c < nCols:
                H[c] += n
    comp = sum(f[h] for h in H)
    return own + comp, own, comp


def tile_cost(t, use_lut_carry=True):
    """Per-tile default Step-1 cost; used for warm-start ordering / estimates.
    IGP=1 pin, OIP=2 pins, plus BOOTH structural LUT cost.
    """
    return tile_step1_objective_cost(t)


# --------------------------------------------------------------------------- #
#  greedy fallback : guaranteed-valid exact cover, no solver
# --------------------------------------------------------------------------- #
def greedy_tiling(Wa, Wb, sign_a, sign_b, booth_level, max_dsp):
    # Greedy warm-start / fallback uses a SINGLE representative level (the
    # smallest -> smallest, most flexible bands).  The ILP does the real mixing;
    # any single-level cover here is a valid start since its tiles are in the
    # mixed candidate set.
    booth_level = min(_norm_levels(booth_level))
    covered = [[False] * Wb for _ in range(Wa)]
    tiles = []
    dsp_used = 0

    def free_rect(i0, j0, h, w):
        if i0 + h > Wa or j0 + w > Wb:
            return False
        for i in range(i0, i0 + h):
            for j in range(j0, j0 + w):
                if covered[i][j]:
                    return False
        return True

    def mark(i0, j0, h, w):
        for i in range(i0, i0 + h):
            for j in range(j0, j0 + w):
                covered[i][j] = True

    # pass 0: DSP blocks tiled from the LSB corner, up to the budget
    if max_dsp > 0:
        du = DSP_UNSIGNED
        i0 = 0
        while i0 < Wa and dsp_used < max_dsp:
            j0 = 0
            while j0 < Wb and dsp_used < max_dsp:
                h = min(du[0], Wa - i0)
                w = min(du[1], Wb - j0)
                if free_rect(i0, j0, h, w) and h >= 1 and w >= 1:
                    tiles.append(Tile('DSP', i0, i0 + h - 1, j0, j0 + w - 1))
                    mark(i0, j0, h, w)
                    dsp_used += 1
                j0 += du[1]
            i0 += du[0]

    h_uns = booth_level_max_height(booth_level, False)   # 2L-1
    h_sgn = booth_level_max_height(booth_level, True)     # 2L

    # pass 1: Booth strips (operand a = multiplier) of the level height, greedy
    # widest free run along b.  Try signed height at the a-MSB, else unsigned.
    for i0 in range(Wa):
        for j0 in range(Wb):
            if covered[i0][j0]:
                continue
            # choose height: signed if this strip reaches a-MSB and sign_a
            placed = False
            for hh in ([h_sgn, h_uns] if sign_a else [h_uns]):
                if i0 + hh != Wa and i0 + hh - 1 == Wa - 1 and sign_a and hh == h_uns:
                    continue
                if i0 + hh - 1 != Wa - 1 and hh == h_sgn:
                    continue
                if i0 + hh > Wa:
                    continue
                # widest free width along b at this anchor for full height hh
                w = 0
                while j0 + w < Wb and free_rect(i0, j0 + w, hh, 1):
                    w += 1
                if w >= 2:
                    tiles.append(Tile('BOOTH', i0, i0 + hh - 1, j0, j0 + w - 1,
                                      booth_axis='a', level=booth_level))
                    mark(i0, j0, hh, w)
                    placed = True
                    break
            if not placed:
                continue

    # pass 2: LUT tiles for everything left, largest level-bounded rectangle first
    lut_max = lut_max_shape_for_booth_level(booth_level)
    lut_shapes = sorted(((h, w)
                         for h in range(1, min(Wa, lut_max) + 1)
                         for w in range(1, min(Wb, lut_max) + 1)),
                        key=lambda s: -(s[0] * s[1]))
    for i0 in range(Wa):
        for j0 in range(Wb):
            if covered[i0][j0]:
                continue
            for (h, w) in lut_shapes:
                if free_rect(i0, j0, h, w):
                    tiles.append(Tile('LUT', i0, i0 + h - 1, j0, j0 + w - 1))
                    mark(i0, j0, h, w)
                    break
            else:
                tiles.append(Tile('LUT', i0, i0, j0, j0))   # 1x1 always fits
                mark(i0, j0, 1, 1)

    _assert_exact_cover(tiles, Wa, Wb)
    return tiles


def retile_lut_residual(tiles, Wa, Wb, booth_level):
    """Keep selected DSP/Booth tiles, then re-fill the remaining cells with
    large level-bounded LUT rectangles.

    Step 1 should decide where the hard macro tiles (DSP/Booth) go. LUT tiles
    are only the residual exact cover; their internal shape does not change the
    represented partial products because each covered cell still contributes its
    own OIP/OIP_INV bit to Step 2. Reblocking the residual prevents Gurobi
    tie-breaks from returning a fragmented LUT cover while preserving the
    selected DSP/Booth placement.
    """
    hard = [t for t in tiles if t.kind != 'LUT']
    covered = [[False] * Wb for _ in range(Wa)]
    for t in hard:
        for i, j in t.cells():
            if covered[i][j]:
                raise AssertionError("non-LUT tiles overlap at (a=%d,b=%d)" % (i, j))
            covered[i][j] = True

    lut_max = lut_max_shape_for_booth_level(max(_norm_levels(booth_level)))
    lut_shapes = sorted(((h, w)
                         for h in range(1, min(Wa, lut_max) + 1)
                         for w in range(1, min(Wb, lut_max) + 1)),
                        key=lambda s: (-(s[0] * s[1]), -s[0], -s[1]))

    def free_rect(i0, j0, h, w):
        if i0 + h > Wa or j0 + w > Wb:
            return False
        for ii in range(i0, i0 + h):
            for jj in range(j0, j0 + w):
                if covered[ii][jj]:
                    return False
        return True

    def mark(i0, j0, h, w):
        for ii in range(i0, i0 + h):
            for jj in range(j0, j0 + w):
                covered[ii][jj] = True

    out = list(hard)
    for i0 in range(Wa):
        for j0 in range(Wb):
            if covered[i0][j0]:
                continue
            for h, w in lut_shapes:
                if free_rect(i0, j0, h, w):
                    out.append(Tile('LUT', i0, i0 + h - 1, j0, j0 + w - 1))
                    mark(i0, j0, h, w)
                    break
            else:
                raise AssertionError("cannot fill residual LUT cell (a=%d,b=%d)" % (i0, j0))

    _assert_exact_cover(out, Wa, Wb)
    return out


# --------------------------------------------------------------------------- #
#  ILP
# --------------------------------------------------------------------------- #
def solve_tiling(Wa, Wb, sign_a=False, sign_b=False,
                 booth_level=4, max_dsp=0,
                 use_gurobi=True, time_limit=600, mip_gap=1e-3,
                 threads=8, verbose=True, booth_max_k=None,
                 use_lut_carry=True, cost_model='colcost',
                 formulation='packing', booth_band_align=True,
                 booth_width_prune=True):
    """Return (tiles, info).  tiles is an exact cover of the board.

    formulation='packing' (default, scalable): variables are ONLY the hard
    DSP/Booth tiles; each board cell is covered at most once and the LUT residual
    is implicit (its 2-pin/cell cost folded into the objective, then materialised
    by retile_lut_residual).  No redundant LUT variables.  Combined with
    booth_band_align this is the large-W formulation.
    'cover' keeps the legacy exact-cover model (LUT variables, ==1) for
    ablation / equivalence checking.
    """
    packing = (formulation == 'packing')
    cands = enumerate_candidate_tiles(
        Wa, Wb, sign_a, sign_b, booth_level=booth_level,
        allow_dsp=(max_dsp > 0), booth_max_k=booth_max_k,
        include_lut=(not packing),
        booth_band_align=(booth_band_align and packing),
        booth_width_prune=(booth_width_prune and packing))
    info = {'n_candidates': len(cands), 'method': None,
            'booth_level': booth_level, 'max_dsp': max_dsp,
            'formulation': formulation}

    if not use_gurobi:
        tiles = greedy_tiling(Wa, Wb, sign_a, sign_b, booth_level, max_dsp)
        tiles = retile_lut_residual(tiles, Wa, Wb, booth_level)
        info['method'] = 'greedy'
        wpp_obj, wpp, booth_lut = tiling_step1_objective_cost(tiles)
        cc_total = tiling_colcost(tiles, Wa, Wb)[0]
        info['weighted_pp_cost'] = wpp
        info['booth_own_lut_cost'] = booth_lut
        info['colcost'] = cc_total
        info['cost'] = cc_total if cost_model == 'colcost' else wpp_obj
        return tiles, info

    try:
        import gurobipy as gp
        from gurobipy import GRB
    except Exception as e:
        if verbose:
            print("[tiling] gurobipy unavailable (%s); using greedy." % e)
        tiles = greedy_tiling(Wa, Wb, sign_a, sign_b, booth_level, max_dsp)
        tiles = retile_lut_residual(tiles, Wa, Wb, booth_level)
        info['method'] = 'greedy(no-gurobi)'
        wpp_obj, wpp, booth_lut = tiling_step1_objective_cost(tiles)
        cc_total = tiling_colcost(tiles, Wa, Wb)[0]
        info['weighted_pp_cost'] = wpp
        info['booth_own_lut_cost'] = booth_lut
        info['colcost'] = cc_total
        info['cost'] = cc_total if cost_model == 'colcost' else wpp_obj
        return tiles, info

    try:
        m = gp.Model("tiling_%dx%d" % (Wa, Wb))
        m.setParam("OutputFlag", 1 if verbose else 0)
        m.setParam("Threads", threads)
        m.setParam("TimeLimit", time_limit)
        m.setParam("MIPGap", mip_gap)

        x = m.addVars(len(cands), vtype=GRB.BINARY, name="x")
        # cell -> list of candidate indices covering it
        cover = {}
        for ti, t in enumerate(cands):
            for (i, j) in t.cells():
                cover.setdefault((i, j), []).append(ti)
        for (i, j), lst in cover.items():
            s = gp.quicksum(x[ti] for ti in lst)
            if packing:
                m.addConstr(s <= 1, name="pack_%d_%d" % (i, j))   # cover <=1
            else:
                m.addConstr(s == 1, name="cover_%d_%d" % (i, j))  # exact cover
        dsp_idx = [ti for ti, t in enumerate(cands) if t.kind == 'DSP']
        if dsp_idx:
            m.addConstr(gp.quicksum(x[ti] for ti in dsp_idx) <= max_dsp,
                        name="dsp_budget")

        # ---- objective ----
        if packing and cost_model == 'colcost':
            # Column-aware OIP/IGP objective (default):
            #   min  sum_t [ booth_own(t) - (2/3)*area(t) ]   (OIP residual)
            #      + sum_cols max(0, (G_c - 2)/2)             (IGP compression)
            # G_c = IGP height (DSP/Booth opaque output bits) in column c.
            nCols = Wa + Wb
            gcol = [gp.LinExpr() for _ in range(nCols)]
            for ti, t in enumerate(cands):
                for cc, nb in tile_column_bits(t).items():
                    if 0 <= cc < nCols:
                        gcol[cc].addTerms(nb, x[ti])
            zg = m.addVars(nCols, lb=0.0, name="zg")
            for cc in range(nCols):
                m.addConstr(zg[cc] >= 0.5 * (gcol[cc] - 2), name="igp_%d" % cc)
            m.setObjective(
                gp.quicksum(tile_colcost_coeff(t) * x[ti]
                            for ti, t in enumerate(cands))
                + gp.quicksum(zg[cc] for cc in range(nCols)),
                GRB.MINIMIZE)
        elif packing:
            # Packing weighted-PP (pin-weight) baseline: OIP=2 pins, IGP=1 pin.
            m.setObjective(
                gp.quicksum(tile_packing_coeff(t) * x[ti]
                            for ti, t in enumerate(cands)),
                GRB.MINIMIZE)
        elif cost_model == 'paper':
            # Legacy ablation: the paper's per-tile estimate own + 0.65*
            # (#output columns).  Per-tile (no column sharing), borrowed constant.
            own_term = gp.quicksum(tile_own_cost(t) * x[ti]
                                   for ti, t in enumerate(cands))
            m.setObjective(
                own_term + gp.quicksum(0.65 * len(tile_column_bits(t)) * x[ti]
                                       for ti, t in enumerate(cands)),
                GRB.MINIMIZE)
        elif cost_model == 'flc':
            # Legacy diagnostic: real own-cost + per-column LUT+CARRY4 envelope.
            own_term = gp.quicksum(tile_own_cost(t) * x[ti]
                                   for ti, t in enumerate(cands))
            nCols = Wa + Wb
            slope, floor = _lc_envelope_params(use_lut_carry)
            col_expr = [gp.LinExpr() for _ in range(nCols)]
            for ti, t in enumerate(cands):
                for c, nb in tile_column_bits(t).items():
                    if 0 <= c < nCols:
                        col_expr[c].addTerms(nb, x[ti])
            zc = m.addVars(nCols, lb=0.0, name="zcol")
            for c in range(nCols):
                m.addConstr(zc[c] >= slope * (col_expr[c] - floor),
                            name="ccost_%d" % c)
            m.setObjective(own_term + gp.quicksum(zc[c] for c in range(nCols)),
                           GRB.MINIMIZE)
        else:
            # DEFAULT: minimize weighted remaining PP pins passed into Step 2,
            # plus Booth structural LUT build cost. DSP/Booth IGP result bits
            # have weight 1; LUT OIP cells have weight 2.
            m.setObjective(
                gp.quicksum(tile_step1_objective_cost(t) * x[ti]
                            for ti, t in enumerate(cands)),
                GRB.MINIMIZE)

        # greedy warm start
        warm = greedy_tiling(Wa, Wb, sign_a, sign_b, booth_level, max_dsp)
        key2idx = {(t.kind, t.i0, t.i1, t.j0, t.j1, t.booth_axis, t.level): ti
                   for ti, t in enumerate(cands)}
        for ti in range(len(cands)):
            x[ti].Start = 0
        for t in warm:
            k = (t.kind, t.i0, t.i1, t.j0, t.j1, t.booth_axis, t.level)
            if k in key2idx:
                x[key2idx[k]].Start = 1

        m.optimize()
        if m.SolCount == 0:
            raise RuntimeError("tiling ILP infeasible/no solution")
        sel = [cands[ti] for ti in range(len(cands)) if x[ti].X > 0.5]
        if not packing:
            _assert_exact_cover(sel, Wa, Wb)      # LUT vars present -> full cover
        # packing: sel are hard tiles only; LUT residual filled here
        tiles = retile_lut_residual(sel, Wa, Wb, booth_level)
        info['method'] = 'ilp'
        info['solver_obj'] = m.ObjVal
        wpp_obj, wpp, booth_lut = tiling_step1_objective_cost(tiles)
        cc_total = tiling_colcost(tiles, Wa, Wb)[0]
        info['weighted_pp_cost'] = wpp
        info['booth_own_lut_cost'] = booth_lut
        info['colcost'] = cc_total
        info['cost'] = cc_total if cost_model == 'colcost' else wpp_obj
        info['mipgap'] = m.MIPGap
        info['status'] = m.Status
        return tiles, info
    except Exception as e:
        if verbose:
            print("[tiling] ILP failed (%s); falling back to greedy." % str(e)[:140])
        tiles = greedy_tiling(Wa, Wb, sign_a, sign_b, booth_level, max_dsp)
        tiles = retile_lut_residual(tiles, Wa, Wb, booth_level)
        info['method'] = 'greedy(ilp-fail)'
        wpp_obj, wpp, booth_lut = tiling_step1_objective_cost(tiles)
        cc_total = tiling_colcost(tiles, Wa, Wb)[0]
        info['weighted_pp_cost'] = wpp
        info['booth_own_lut_cost'] = booth_lut
        info['colcost'] = cc_total
        info['cost'] = cc_total if cost_model == 'colcost' else wpp_obj
        return tiles, info


def _assert_exact_cover(tiles, Wa, Wb):
    grid = [[0] * Wb for _ in range(Wa)]
    for t in tiles:
        for (i, j) in t.cells():
            grid[i][j] += 1
    for i in range(Wa):
        for j in range(Wb):
            if grid[i][j] != 1:
                raise AssertionError(
                    "tiling not an exact cover at (a=%d,b=%d): covered %d times"
                    % (i, j, grid[i][j]))


def summarize_tiling(tiles, Wa, Wb, info=None):
    from collections import Counter
    c = Counter(t.kind for t in tiles)
    lines = []
    lines.append("Tiling %dx%d : %d tiles  (%s)"
                 % (Wa, Wb, len(tiles), dict(c)))
    total, igp, oip = tiling_weighted_pp_cost(tiles)
    obj, _, booth_lut = tiling_step1_objective_cost(tiles)
    if info:
        lines.append("  method=%s  step1_obj=%d (weighted_PP=%d: IGP_pin=%d + OIP_pin=%d; "
                     "Booth_LUT=%d)  candidates=%d"
                     % (info.get('method'), obj, total, igp, oip, booth_lut,
                        info.get('n_candidates', -1)))
    cc, cb, co, ci = tiling_colcost(tiles, Wa, Wb)
    lines.append("  colcost=%.1f  (Booth_LUT=%d + OIP*2/3=%.1f + IGP_col=%.1f)"
                 % (cc, cb, co, ci))
    booth = [t for t in tiles if t.kind == 'BOOTH']
    if booth:
        lv = Counter(t.level for t in booth)
        widths = Counter((t.w if t.booth_axis == 'a' else t.h) for t in booth)
        lines.append("  Booth count=%d  levels=%s  multiplicand-widths=%s"
                     % (len(booth), dict(sorted(lv.items())), dict(widths)))
    dsp = [t for t in tiles if t.kind == 'DSP']
    if dsp:
        lines.append("  DSP count=%d  shapes=%s"
                     % (len(dsp), Counter((t.h, t.w) for t in dsp)))
    return "\n".join(lines)


if __name__ == "__main__":
    import sys
    Wa = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    Wb = int(sys.argv[2]) if len(sys.argv) > 2 else Wa
    L = int(sys.argv[3]) if len(sys.argv) > 3 else 4
    md = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    for use_g in (True, False):
        tiles, info = solve_tiling(Wa, Wb, sign_a=True, sign_b=True,
                                   booth_level=L, max_dsp=md,
                                   use_gurobi=use_g, verbose=False, time_limit=30)
        print(summarize_tiling(tiles, Wa, Wb, info))
        print()
