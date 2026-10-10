# -*- coding: utf-8 -*-
"""bench_B.py -- run OUR Step-2 compressor-tree ILP on the benchmark bit
matrices of [B] (Hossfeld et al., "High-efficiency Compressor Trees for Latest
AMD FPGAs", ACM TRETS 17(2), Article 30, 2024).

Why this is the fair way to compare against [B]
-----------------------------------------------
[B] is not a multiplier generator: it builds a compressor tree for a GIVEN bit
matrix, with a heuristic.  Our Step 2 solves exactly that problem, exactly.  So
the comparable experiment is not "their multiplier vs ours" -- it is "their tree
vs our tree on the same matrix, the same part, the same measurement".

[B]'s published suite is seven shapes, measured as LUTs *including the terminal
adder* inside a register sandwich (its Fig. 22 on Versal, Fig. 25 on 7 Series):

    (128) (256) (512) (128,128) (256,256) (512,512)   and   Mul16

where (h) is one column of h bits, (h,h) two columns of h bits each, and Mul16
is the partial-product matrix of a 16x16 unsigned multiplication.

Two input modes, because [B] measures both:

  external  every matrix bit is a primary input.  This is what [B] Fig. 22 and
            Fig. 25 report, so these are the directly comparable numbers.
  absorbed  Mul16 only: the AND gates are never materialised, they are consumed
            inside the compressor LUTs.  This is our UPP mechanism, and it is
            [B]'s "gate absorption" (its Section 8.6) expressed in our
            formulation; [B] measures it separately in its Fig. 24.
  gates     Mul16 only: the same 16x16 multiplication as `absorbed`, but with
            every AND gate materialised as its own LUT.  This is the baseline
            that makes absorption measurable -- same function, same solver,
            gates paid for explicitly.  It must NOT be compared with [B]'s
            published numbers, which exclude partial-product generation.

Emitted RTL keeps the (a, b, r) port names of the rest of the framework so that
synth.tcl and verilog_sim.py both work on it unchanged.

    python bench_B.py --shape Mul16 --mode external --out bench_out/
    python bench_B.py --all --out bench_out/
"""
from __future__ import print_function

import argparse
import json
import os
import random
import sys
import time

from merge_ilp import Heap, solve_merge, greedy_merge
from tiled_verilog_gen import TilePPManager, _emit_merge_cla
from verilog_gen import (_emit_compressor, _emit_lutcarry_chain,
                         _build_lutcarry_chains, IGPPool)
from compressors import all_compressors


# =============================================================================
#  The seven benchmark shapes of [B]
# =============================================================================
def mul_heights(Wa, Wb):
    """Column heights of the Wa x Wb unsigned AND-array partial-product matrix."""
    n = Wa + Wb
    h = [0] * n
    for i in range(Wa):
        for j in range(Wb):
            h[i + j] += 1
    return h


SHAPES = {
    'S128':  [128],
    'S256':  [256],
    'S512':  [512],
    'D128':  [128, 128],
    'D256':  [256, 256],
    'D512':  [512, 512],
    'Mul16': mul_heights(16, 16),
}

# how each shape is written in [B]
LABEL = {'S128': '(128)', 'S256': '(256)', 'S512': '(512)',
         'D128': '(128,128)', 'D256': '(256,256)', 'D512': '(512,512)',
         'Mul16': 'Mul16'}

# [B] Fig. 25, 7 Series (xc7vh870tflg1932-2, Vivado 2023.1), LUTs incl. terminal
# adder -- "Ours" (the generator of [B]), and the two Preusser [19] references
# it compares itself against.  Transcribed from the published bar labels.
B_7SERIES = {
    'S128':  {'B': 105, 'preusser_upd': 101, 'preusser': 102},
    'S256':  {'B': 204, 'preusser_upd': 203, 'preusser': 209},
    'S512':  {'B': 412, 'preusser_upd': 409, 'preusser': 422},
    'D128':  {'B': 208, 'preusser_upd': 204, 'preusser': 205},
    'D256':  {'B': 407, 'preusser_upd': 407, 'preusser': 417},
    'D512':  {'B': 824, 'preusser_upd': 815, 'preusser': 839},
    'Mul16': {'B': 146, 'preusser_upd': 147, 'preusser': 156},
}

# [B] Fig. 22, Versal (VCK190, Vivado 2023.1), plain compression
B_VERSAL = {
    'S128':  {'B': 93,  'vivado': 156},
    'S256':  {'B': 185, 'vivado': 324},
    'S512':  {'B': 370, 'vivado': 709},
    'D128':  {'B': 176, 'vivado': 343},
    'D256':  {'B': 353, 'vivado': 696},
    'D512':  {'B': 708, 'vivado': 1431},
    'Mul16': {'B': 167, 'vivado': 260},
}


def n_cols_for(heights):
    """Columns needed to hold the largest value the matrix can represent."""
    total = sum(h << j for j, h in enumerate(heights))
    return max(1, total.bit_length())


# =============================================================================
#  Heap construction
# =============================================================================
def build_bench_heap(shape, mode):
    """Return (heap, n_inputs, nCols, Wa, Wb).

    external : every matrix bit is a primary input a[k]; b is unused (1 bit, so
               that the (a, b, r) port convention of the framework still holds).
    absorbed : Mul16 only; a[15:0] * b[15:0] with the AND cells left ungenerated
               (UPP), to be consumed inside the compressor LUTs.
    """
    heights = SHAPES[shape]
    nCols = n_cols_for(heights)
    heap = Heap(nCols)

    if mode in ('absorbed', 'gates'):
        if shape != 'Mul16':
            raise SystemExit('%s mode is defined for Mul16 only' % mode)
        Wa = Wb = 16
        for i in range(Wa):
            for j in range(Wb):
                if mode == 'absorbed':
                    heap.oip[i + j].append(('OIP', i, j))
                else:
                    # already a signal by the time the tree sees it
                    heap.igp[i + j].append(('AND', i, j))
        return heap, 0, nCols, Wa, Wb

    k = 0
    for col, h in enumerate(heights):
        for _ in range(h):
            # the ILP only ever reads the per-column COUNTS; the wire name is
            # what the emitter needs, so keep it right here
            heap.igp[col].append('a[%d]' % k)
            k += 1
    return heap, k, nCols, k, 1


# =============================================================================
#  RTL emission
# =============================================================================
def emit_bench_verilog(heap, merge_res, mode, nCols, Wa, Wb, filename, modname):
    method = merge_res.get('method', 'ilp')
    use_chains = any(c['kid'].startswith('c') for c in merge_res['comps'])

    ppmgr = TilePPManager(Wa, Wb)
    ipool = IGPPool()

    with open(filename, 'w') as f:
        f.write("// ==========================================================\n")
        f.write("// Step-2 compressor tree on a [B] benchmark bit matrix\n")
        f.write("// mode=%s  cols=%d  merge=%s\n" % (mode, nCols, method))
        f.write("// heights=%s\n" % (heap.total_heights(),))
        f.write("// ==========================================================\n")
        f.write("module %s (\n  input  [%d:0] a,\n  input  [%d:0] b,\n"
                "  output [%d:0] r\n);\n"
                % (modname, Wa - 1, Wb - 1, nCols - 1))

        f.write("\n  // ---- bit matrix -> merge heap ----\n")
        if mode == 'absorbed':
            for col in range(nCols):
                for (kind, i, j) in heap.oip[col]:
                    ppmgr.add(col, i, j, kind == 'OIP_INV')
        elif mode == 'gates':
            f.write("  // every partial product is formed by its own LUT, so\n")
            f.write("  // that absorbing them instead can be measured against\n")
            f.write("  // this baseline rather than estimated\n")
            for col in range(nCols):
                for (_, i, j) in heap.igp[col]:
                    w = "pp_%d_%d" % (i, j)
                    f.write("  wire %s;\n" % w)
                    f.write("  LUT6 #(.INIT(64'h8888888888888888)) u_%s "
                            "(.O(%s), .I0(a[%d]), .I1(b[%d]), .I2(1'b0), "
                            ".I3(1'b0), .I4(1'b0), .I5(1'b0));\n"
                            % (w, w, i, j))
                    ipool.add(0, col, w)
        else:
            f.write("  // every matrix bit is a primary input (gates external,\n")
            f.write("  // exactly as the input shapes of [B] Fig. 22 / Fig. 25)\n")
            for col in range(nCols):
                for name in heap.igp[col]:
                    ipool.add(0, col, name)

        f.write("\n  // ---- merge : Step-2 ILP LUT6_2 / carry-chain tree ----\n")
        comps = all_compressors(use_lut_carry=use_chains)
        if use_chains:
            pure, chains = _build_lutcarry_chains(merge_res['comps'])
        else:
            pure, chains = list(merge_res['comps']), []
        by_step = {}
        for i, c in enumerate(pure):
            by_step.setdefault(c['step'], []).append(('pure', c['col'], i, c))
        for i, ch in enumerate(chains):
            by_step.setdefault(ch[0]['step'], []).append(
                ('chain', ch[0]['col'], i, ch))
        for step in sorted(by_step):
            for kind, col, i, obj in sorted(
                    by_step[step],
                    key=lambda x: (x[1], 0 if x[0] == 'pure' else 1, x[2])):
                if kind == 'pure':
                    spec = comps[obj['kid']]
                    cid = "s%d_c%d_n%d" % (obj['step'], obj['col'], i)
                    _emit_compressor(f, obj, spec, ppmgr, ipool, cid)
                else:
                    cid = "lc_s%d_c%d_n%d" % (obj[0]['step'], obj[0]['col'], i)
                    _emit_lutcarry_chain(f, obj, ppmgr, ipool, cid)

        _emit_merge_cla(f, nCols, ppmgr, ipool, merge_res['S'],
                        merge_res['OIPV'][-1], merge_res['IGPV'][-1])
        f.write("\nendmodule\n")
    return modname


# =============================================================================
#  Functional verification against the golden value of the matrix
# =============================================================================
def golden(shape, mode, a, b):
    if mode in ('absorbed', 'gates'):
        return (a * b) & ((1 << 32) - 1)
    heights = SHAPES[shape]
    val = 0
    k = 0
    for col, h in enumerate(heights):
        for _ in range(h):
            val += ((a >> k) & 1) << col
            k += 1
    return val


def verify(vfile, shape, mode, Wa, Wb, nCols, n_random, budget=400000,
           seed=20240601):
    """Random-vector check through the primitive-level simulator.

    The simulator is pure Python and costs roughly one pass over every gate per
    vector, so a fixed vector count would make the 512-bit shapes take hours
    while the small ones finish instantly.  The vector count is therefore scaled
    to a fixed budget of gate evaluations, with a floor so that even the largest
    design still gets a real test.
    """
    import verilog_sim as vs
    mod = vs.parse(vfile, Wa, Wb, nCols)
    n_el = max(1, len(mod.elements))
    n_random = max(40, min(n_random, budget // n_el))
    rng = random.Random(seed)
    mask_a = (1 << Wa) - 1
    mask_b = (1 << Wb) - 1
    mask_r = (1 << nCols) - 1

    vectors = [(0, 0), (mask_a, mask_b), (1, 1), (mask_a, 1), (1, mask_b)]
    for _ in range(n_random):
        vectors.append((rng.randrange(mask_a + 1), rng.randrange(mask_b + 1)))

    for (a, b) in vectors:
        got = vs.simulate(mod, a, b) & mask_r
        want = golden(shape, mode, a, b) & mask_r
        if got != want:
            return False, (a, b, got, want), len(vectors)
    return True, None, len(vectors)


# =============================================================================
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--shape', choices=sorted(SHAPES) + ['all'], default='all')
    ap.add_argument('--mode',
                    choices=['external', 'absorbed', 'gates', 'both'],
                    default='external')
    ap.add_argument('--out', default='bench_out')
    ap.add_argument('--time-limit', type=float, default=900.0)
    ap.add_argument('--mip-gap', type=float, default=1e-4)
    ap.add_argument('--threads', type=int, default=8)
    ap.add_argument('--verify', type=int, default=3000,
                    help='max random vectors (0 disables)')
    ap.add_argument('--verify-budget', type=int, default=400000,
                    help='gate-evaluation budget that caps the vector count')
    ap.add_argument('--greedy', action='store_true',
                    help='Gurobi-free fallback, for smoke tests')
    ap.add_argument('--quiet', action='store_true')
    a = ap.parse_args()

    shapes = sorted(SHAPES) if a.shape == 'all' else [a.shape]
    modes = ['external', 'absorbed'] if a.mode == 'both' else [a.mode]
    if not os.path.isdir(a.out):
        os.makedirs(a.out)

    for shape in shapes:
        for mode in modes:
            if mode in ('absorbed', 'gates') and shape != 'Mul16':
                continue
            tag = '%s_%s' % (shape, mode)
            print('=' * 72)
            print('%-12s %-9s  heights=%s' % (LABEL[shape], mode,
                                              SHAPES[shape]))
            heap, nIn, nCols, Wa, Wb = build_bench_heap(shape, mode)
            print('  columns=%d  max height=%d  total bits=%d'
                  % (nCols, heap.max_height(), sum(heap.total_heights())))

            t0 = time.time()
            if a.greedy:
                res = greedy_merge(heap)
            else:
                res = solve_merge(heap, threads=a.threads,
                                  time_limit=a.time_limit, mip_gap=a.mip_gap,
                                  verbose=not a.quiet)
            t_solve = time.time() - t0

            modname = 'bench_%s' % tag
            vfile = os.path.join(a.out, modname + '.v')
            emit_bench_verilog(heap, res, mode, nCols, Wa, Wb, vfile, modname)

            ok, bad, nvec = (None, None, 0)
            if a.verify:
                ok, bad, nvec = verify(vfile, shape, mode, Wa, Wb, nCols,
                                       a.verify, a.verify_budget)

            rec = {
                'shape': shape, 'label': LABEL[shape], 'mode': mode,
                'heights': SHAPES[shape], 'nCols': nCols, 'Wa': Wa, 'Wb': Wb,
                'total_bits': sum(heap.total_heights()),
                'max_height': heap.max_height(),
                'S': res['S'], 'ct_cost': res['ct_cost'],
                'n_chain_cells': res['n_chain_cells'],
                'objval': res['objval'], 'mipgap': res.get('mipgap'),
                'status': res.get('status'), 'method': res.get('method'),
                'solve_s': round(t_solve, 2),
                'verified': ok, 'n_vectors': nvec,
                'verilog': os.path.basename(vfile),
                'B_7series': B_7SERIES.get(shape),
                'B_versal': B_VERSAL.get(shape),
            }
            with open(os.path.join(a.out, modname + '.json'), 'w') as fh:
                json.dump(rec, fh, indent=2)

            print('  Step-2: S=%d  tree LUT cost=%.1f  chain cells=%d  '
                  'gap=%.2g  %.1fs'
                  % (res['S'], res['ct_cost'], res['n_chain_cells'],
                     res.get('mipgap') or 0.0, t_solve))
            if ok is None:
                print('  verify: skipped')
            elif ok:
                print('  verify: OK (%d vectors)' % nvec)
            else:
                print('  verify: FAILED a=%d b=%d got=%d want=%d' % bad)
                sys.exit(1)
            print('  rtl   : %s' % vfile)


if __name__ == '__main__':
    main()
