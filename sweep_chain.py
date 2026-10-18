# -*- coding: utf-8 -*-
"""sweep_chain.py -- trace the area-delay front of Step 2 by bounding carry-chain
length.

(O2) counts LUTs and knows nothing about time.  Left unbounded, the solver will
happily run a single carry chain across the whole heap to save a cell, and the
carry propagating along that chain is what the measured critical path is largely
made of.  `--max-chain D` bounds it, so minimising LUTs subject to D and
sweeping D gives a front that is *optimised* at every point instead of sampled
by varying an unrelated parameter.

This driver does Step 1 once and then re-solves Step 2 for each D, so the tiling
is held fixed and the numbers isolate the compressor stage.

    python sweep_chain.py --W 32 --mode uu --levels 4 --chains 2,3,4,6,8,0
"""
from __future__ import print_function

import argparse
import json
import os
import time

from tiling_ilp import solve_tiling
from merge_ilp import build_heap, solve_merge, simulate_merge_state
from tiled_verilog_gen import emit_tiled_verilog


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--W', type=int, default=32)
    ap.add_argument('--mode', default='uu', choices=['uu', 'us', 'su', 'ss'])
    ap.add_argument('--levels', type=int, default=4)
    ap.add_argument('--max-dsp', type=int, default=0)
    ap.add_argument('--booth-max-k', type=int, default=None,
                    help='cap the multiplicand width of a Booth band. The band '
                         'accumulates its levels serially through one carry '
                         'chain per level, so its width is its depth; capping '
                         'it trades more rows for Step 2 against a shorter '
                         'ripple inside the tile.')
    ap.add_argument('--booth-groups', type=int, default=1,
                    help='split each Booth band into this many level groups')
    ap.add_argument('--chains', default='2,3,4,6,8,0',
                    help='comma-separated bounds; 0 means unbounded')
    ap.add_argument('--time-limit', type=float, default=600.0)
    ap.add_argument('--threads', type=int, default=8)
    ap.add_argument('--out', default='chain_sweep')
    a = ap.parse_args()

    sa, sb = a.mode[0] == 's', a.mode[1] == 's'
    if not os.path.isdir(a.out):
        os.makedirs(a.out)

    print('Step 1: W=%d mode=%s level=%d dsp=%d' % (a.W, a.mode, a.levels,
                                                    a.max_dsp))
    t0 = time.time()
    tiles, tinfo = solve_tiling(a.W, a.W, sign_a=sa, sign_b=sb,
                                booth_level=a.levels, max_dsp=a.max_dsp,
                                booth_max_k=a.booth_max_k,
                                time_limit=a.time_limit, threads=a.threads,
                                verbose=False)
    from collections import Counter
    geom = Counter((t.kind, t.h, t.w) for t in tiles)
    print('  %d tiles in %.1f s : %s'
          % (len(tiles), time.time() - t0,
             ', '.join('%s %dx%d x%d' % (k[0], k[1], k[2], v)
                       for k, v in sorted(geom.items(), key=lambda kv: -kv[1]))))

    import booth_array
    booth_array.set_groups(a.booth_groups)

    heap = build_heap(tiles, a.W, a.W, sa, sb)
    print('  heap: %d columns, max height %d'
          % (heap.nCols, heap.max_height()))

    rows = []
    print('\n%-8s %-5s %-9s %-7s %-9s %-9s %-8s' %
          ('maxD', 'S', 'tree LUT', 'chains', 'longest', 'sum depth', 'solve s'))
    for tok in a.chains.split(','):
        D = int(tok.strip())
        D = None if D == 0 else D
        t1 = time.time()
        try:
            res = solve_merge(heap, use_lut_carry=True, max_chain=D,
                              threads=a.threads, time_limit=a.time_limit,
                              mip_gap=1e-4, verbose=False)
        except Exception as e:                                   # noqa: BLE001
            print('%-8s FAILED: %s' % (D or 'none', str(e)[:70]))
            continue
        dt = time.time() - t1
        ok, _, _ = simulate_merge_state(heap, res)
        if not ok:
            raise SystemExit('schedule does not reproduce the heap value')
        tag = '%dx%d_%s_L%d_d%d_k%s_g%d_D%s' % (a.W, a.W, a.mode, a.levels,
                                                a.max_dsp,
                                                a.booth_max_k or 'inf',
                                                a.booth_groups, D or 'inf')
        vf = os.path.join(a.out, 'mult_%s.v' % tag)
        emit_tiled_verilog(tiles, res, a.W, a.W, sa, sb, vf,
                           modname='mult_%s' % tag)
        rec = {'tag': tag, 'W': a.W, 'mode': a.mode, 'levels': a.levels,
               'max_dsp': a.max_dsp, 'booth_max_k': a.booth_max_k,
               'booth_groups': a.booth_groups,
               'max_chain': D, 'S': res['S'],
               'n_tiles': len(tiles),
               'band_w': max([t.w for t in tiles if t.kind == 'BOOTH'] or [0]),
               'ct_lut': res['ct_cost'], 'n_chain_cells': res['n_chain_cells'],
               'longest_chain': res['longest_chain'],
               'chain_depth': res['chain_depth'],
               'mipgap': res['mipgap'], 'solve_s': round(dt, 1),
               'verilog': os.path.basename(vf)}
        rows.append(rec)
        json.dump(rec, open(os.path.join(a.out, '%s.json' % tag), 'w'), indent=2)
        print('%-8s %-5d %-9.0f %-7d %-9d %-9d %-8.1f'
              % (D or 'none', res['S'], res['ct_cost'], res['n_chain_cells'],
                 res['longest_chain'], res['chain_depth'], dt))

    json.dump(rows, open(os.path.join(a.out, 'sweep.json'), 'w'), indent=2)
    print('\nwrote %s' % os.path.join(a.out, 'sweep.json'))


if __name__ == '__main__':
    main()
