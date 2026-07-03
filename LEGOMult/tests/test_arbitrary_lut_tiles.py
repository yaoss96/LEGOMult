from tiles import enumerate_candidate_tiles, Tile
from tiling_ilp import (tile_own_cost, greedy_tiling, solve_tiling,
                        retile_lut_residual, tile_pp_weight,
                        tile_step1_objective_cost, tiling_step1_objective_cost,
                        tiling_weighted_pp_cost)


def test_lut_candidates_include_level_bounded_rectangles_not_only_table_i_shapes():
    tiles = enumerate_candidate_tiles(
        Wa=6, Wb=5, sign_a=False, sign_b=False,
        booth_level=3, allow_dsp=False)
    lut_shapes = {(t.h, t.w) for t in tiles if t.kind == 'LUT'}

    assert (1, 4) in lut_shapes
    assert (4, 1) in lut_shapes
    assert (5, 5) in lut_shapes
    assert (6, 5) not in lut_shapes


def test_lut_candidate_max_shape_follows_booth_level_unsigned_height():
    l3 = enumerate_candidate_tiles(
        Wa=12, Wb=12, sign_a=False, sign_b=False,
        booth_level=3, allow_dsp=False)
    l4 = enumerate_candidate_tiles(
        Wa=12, Wb=12, sign_a=False, sign_b=False,
        booth_level=4, allow_dsp=False)
    l3_shapes = {(t.h, t.w) for t in l3 if t.kind == 'LUT'}
    l4_shapes = {(t.h, t.w) for t in l4 if t.kind == 'LUT'}

    assert (5, 5) in l3_shapes
    assert (6, 5) not in l3_shapes
    assert (7, 7) in l4_shapes
    assert (8, 7) not in l4_shapes


def test_lut_own_cost_is_defined_for_any_level_bounded_rectangle():
    assert tile_own_cost(Tile('LUT', 0, 3, 0, 0)) == 4
    assert tile_own_cost(Tile('LUT', 0, 3, 0, 3)) == 16


def test_greedy_fallback_can_use_level_bounded_lut_remainder_shape():
    # Width smaller than a level-3 Booth strip and no DSP means the fallback is
    # forced to cover the whole board with LUT tiles.  With level-bounded LUT
    # tiles, that can be one 4x4 tile instead of Table-I fragments.
    tiles = greedy_tiling(Wa=4, Wb=4, sign_a=False, sign_b=False,
                          booth_level=3, max_dsp=0)
    assert [(t.kind, t.h, t.w) for t in tiles] == [('LUT', 4, 4)]


def test_gurobi_off_solver_accepts_level_bounded_lut_tiles():
    tiles, info = solve_tiling(Wa=4, Wb=4, sign_a=False, sign_b=False,
                               booth_level=3, max_dsp=0, use_gurobi=False,
                               verbose=False)
    assert info['method'] == 'greedy'
    assert [(t.kind, t.h, t.w) for t in tiles] == [('LUT', 4, 4)]


def test_lut_residual_is_reblocked_after_hard_tile_selection():
    hard = [Tile('DSP', 0, 1, 0, 1)]
    fragmented = hard + [
        Tile('LUT', i, i, j, j)
        for i in range(4) for j in range(4)
        if not (i <= 1 and j <= 1)
    ]

    retiled = retile_lut_residual(fragmented, Wa=4, Wb=4, booth_level=3)

    hard_tiles = [t for t in retiled if t.kind != 'LUT']
    lut_tiles = [t for t in retiled if t.kind == 'LUT']
    assert [(t.kind, t.i0, t.i1, t.j0, t.j1) for t in hard_tiles] == [
        ('DSP', 0, 1, 0, 1)
    ]
    assert [(t.i0, t.i1, t.j0, t.j1) for t in lut_tiles] == [
        (0, 3, 2, 3),
        (2, 3, 0, 1),
    ]


def test_step1_pp_objective_weights_igp_as_one_pin_and_lut_oip_as_two_pins():
    # DSP/BOOTH are already internally multiplied and contribute IGP wires into
    # Step 2: one LUT pin per produced result bit.  LUT residual cells contribute
    # original-input products, each consuming two LUT pins (a_i and b_j).
    assert tile_pp_weight(Tile('DSP', 0, 1, 0, 2)) == 5       # h+w = 2+3
    assert tile_pp_weight(Tile('BOOTH', 0, 1, 0, 2,
                               booth_axis='a', level=3)) == 5
    assert tile_pp_weight(Tile('LUT', 0, 1, 0, 2)) == 12      # 2*h*w


def test_step1_objective_adds_booth_build_lut_cost_to_weighted_remaining_pp():
    tiles = [
        Tile('BOOTH', 0, 6, 0, 3, booth_axis='a', level=4),
        Tile('LUT', 7, 7, 0, 3),
        Tile('DSP', 8, 9, 0, 2),
    ]

    weighted_total, igp, oip = tiling_weighted_pp_cost(tiles)
    objective_total, weighted_pp, booth_lut = tiling_step1_objective_cost(tiles)

    assert igp == 16              # Booth 7+4 plus DSP 2+3
    assert oip == 8               # one 1x4 LUT residual => 4 OIPs * 2 pins
    assert weighted_total == 24
    assert booth_lut == 20        # level * (multiplicand_width + 1) = 4*(4+1)
    assert objective_total == 44  # weighted_PP + Booth own LUT cost


def test_tile_step1_objective_only_adds_booth_own_cost_not_dsp_or_lut_own_cost():
    booth = Tile('BOOTH', 0, 6, 0, 3, booth_axis='a', level=4)
    lut = Tile('LUT', 7, 7, 0, 3)
    dsp = Tile('DSP', 8, 9, 0, 2)

    assert tile_step1_objective_cost(booth) == tile_pp_weight(booth) + tile_own_cost(booth)
    assert tile_step1_objective_cost(lut) == tile_pp_weight(lut)
    assert tile_step1_objective_cost(dsp) == tile_pp_weight(dsp)
