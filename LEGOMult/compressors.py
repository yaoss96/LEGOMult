"""
Compressor library for the ILP-Driven FPGA Multiplier Synthesis paper.

Table I (12 Pure-LUT compressors) is taken VERBATIM from the user reference
graph_gen.py and matches the paper Sec III.A.

Table II (LUT-CarryChain compressors, paper Fig.5(a) "three-input adder")
is extended in this version to support OIP/IGP mixed inputs:

  cI / cII / cIII                   :  all-IGP baselines (paper-exact)
  cI_o1 / cII_o1 / cIII_o1          :  1 OIP + (n-1) IGP (single LUT6_2)
  cI_o2 / cII_o2 / cIII_o2          :  2 OIP + (n-2) IGP (LUT6_2 + LUT6, 2 LUTs)

See LUT_CARRY_COMPRESSORS dict below for the per-variant arity, gen_n,
and cost rationale.
"""

from math import ceil


def _pack(cost, m, p, q, u, v, z, name):
    pins = 2 * m + p + q
    num_out = u + v + z
    kind = 'LUT6_2' if pins <= 5 else 'LUT6'
    return dict(cost=cost,
                oip_c=m, igp_c=p, igp_n=q,
                gen_c=u, gen_n=v, gen_2n=z,
                pins=pins, lut_pins=pins,
                num_out=num_out, kind=kind, name=name)


PURE_LUT_COMPRESSORS = {
    0:  _pack(1, 0, 3, 0, 1, 1, 0, '3IGP-FA'),
    1:  _pack(1, 1, 2, 0, 1, 1, 0, '1OIP+2IGP-3:2'),
    2:  _pack(1, 2, 1, 0, 1, 1, 0, '2OIP+1IGP-3:2'),
    3:  _pack(2, 3, 0, 0, 1, 1, 0, '3OIP-FA   (LUT4/5)'),
    4:  _pack(1, 2, 0, 0, 1, 1, 0, '2OIP-HA   (LUT8)'),
    5:  _pack(1, 1, 1, 0, 1, 1, 0, '1OIP+1IGP-HA'),
    6:  _pack(1, 0, 2, 0, 1, 1, 0, '2IGP-HA'),
    7:  _pack(3, 0, 6, 0, 1, 1, 1, '6IGP-7:3'),
    8:  _pack(3, 0, 5, 1, 1, 1, 1, '5IGP_c+1IGP_n-7:3 (paper Compressor 8)'),
    9:  _pack(2, 0, 5, 0, 1, 1, 1, '5IGP-6:3'),
    10: _pack(2, 0, 4, 1, 1, 1, 1, '4IGP_c+1IGP_n-6:3'),
    11: _pack(2, 0, 3, 2, 1, 1, 1, '3IGP_c+2IGP_n-7:3'),
}

_PAPER_LABEL = {
    'p0':  '0', 'p1':  '1', 'p2':  '2', 'p3':  '3',
    'p4':  '4', 'p5':  '5', 'p6':  '6', 'p7':  '7',
    'p8':  '8', 'p9':  '9', 'p10': '10', 'p11': '11',
    'cI':       'Table II Type I',
    'cII':      'Table II Type II',
    'cIII':     'Table II Type III',
    'cI_o1':    'Table II Type I (1 OIP+3 IGP)',
    'cII_o1':   'Table II Type II (1 OIP+2 IGP)',
    'cIII_o1':  'Table II Type III (1 OIP+2 IGP)',
    'cI_o2':    'Table II Type I (2 OIP+2 IGP, 2 LUTs)',
    'cII_o2':   'Table II Type II (2 OIP+1 IGP, 2 LUTs)',
    'cIII_o2':  'Table II Type III (2 OIP+1 IGP, 2 LUTs)',
}


# Table II compressors with mixed-OIP variants.
LUT_CARRY_COMPRESSORS = {
    'I':       dict(cost=1, oip_c=0, igp_c=4, igp_n=0,
                    gen_c=1, gen_n=0, gen_2n=0,
                    pins=4, lut_pins=4, num_out=1, kind='LUT6_2',
                    name='LUT-Carry-I  (chain head; 4 IGP)'),
    'II':      dict(cost=1, oip_c=0, igp_c=3, igp_n=0,
                    gen_c=1, gen_n=0, gen_2n=0,
                    pins=4, lut_pins=4, num_out=1, kind='LUT6_2',
                    name='LUT-Carry-II (chain body; 3 IGP)'),
    'III':     dict(cost=1, oip_c=0, igp_c=3, igp_n=0,
                    gen_c=1, gen_n=2, gen_2n=0,
                    pins=4, lut_pins=4, num_out=3, kind='LUT6_2',
                    name='LUT-Carry-III(chain tail; 3 IGP)'),
    'I_o1':    dict(cost=1, oip_c=1, igp_c=3, igp_n=0,
                    gen_c=1, gen_n=0, gen_2n=0,
                    pins=5, lut_pins=5, num_out=1, kind='LUT6_2',
                    name='LUT-Carry-I  (chain head; 1 OIP + 3 IGP)'),
    'II_o1':   dict(cost=1, oip_c=1, igp_c=2, igp_n=0,
                    gen_c=1, gen_n=0, gen_2n=0,
                    pins=5, lut_pins=5, num_out=1, kind='LUT6_2',
                    name='LUT-Carry-II (chain body; 1 OIP + 2 IGP)'),
    'III_o1':  dict(cost=1, oip_c=1, igp_c=2, igp_n=0,
                    gen_c=1, gen_n=2, gen_2n=0,
                    pins=5, lut_pins=5, num_out=3, kind='LUT6_2',
                    name='LUT-Carry-III(chain tail; 1 OIP + 2 IGP)'),
    'I_o2':    dict(cost=2, oip_c=2, igp_c=2, igp_n=0,
                    gen_c=1, gen_n=0, gen_2n=0,
                    pins=6, lut_pins=6, num_out=1, kind='LUT6_2',
                    name='LUT-Carry-I  (chain head; 2 OIP + 2 IGP, 2 LUTs)'),
    'II_o2':   dict(cost=2, oip_c=2, igp_c=1, igp_n=0,
                    gen_c=1, gen_n=0, gen_2n=0,
                    pins=6, lut_pins=6, num_out=1, kind='LUT6_2',
                    name='LUT-Carry-II (chain body; 2 OIP + 1 IGP, 2 LUTs)'),
    'III_o2':  dict(cost=2, oip_c=2, igp_c=1, igp_n=0,
                    gen_c=1, gen_n=2, gen_2n=0,
                    pins=6, lut_pins=6, num_out=3, kind='LUT6_2',
                    name='LUT-Carry-III(chain tail; 2 OIP + 1 IGP, 2 LUTs)'),
}


CHAIN_KIDS_HEAD = ('cI', 'cI_o1', 'cI_o2')
CHAIN_KIDS_BODY = ('cII', 'cII_o1', 'cII_o2')
CHAIN_KIDS_TAIL = ('cIII', 'cIII_o1', 'cIII_o2')
CHAIN_KIDS_ALL = CHAIN_KIDS_HEAD + CHAIN_KIDS_BODY + CHAIN_KIDS_TAIL


def chain_base_kid(kid):
    """Return the base chain-type for a (possibly variant-suffixed) chain kid."""
    if not kid.startswith('c'):
        return kid
    return kid.split('_')[0]


def chain_oip_count(kid):
    """Return the number of OIP same-col operands a chain variant consumes."""
    if not kid.startswith('c'):
        return 0
    parts = kid.split('_')
    if len(parts) == 1:
        return 0
    suffix = parts[1]
    if suffix.startswith('o') and suffix[1:].isdigit():
        return int(suffix[1:])
    return 0


def all_compressors(use_lut_carry=False):
    """Return ordered dict of {id_str: spec}."""
    out = {}
    for i, s in PURE_LUT_COMPRESSORS.items():
        out['p%d' % i] = s
    if use_lut_carry:
        for k, s in LUT_CARRY_COMPRESSORS.items():
            out['c' + k] = s
    return out


def compressor_paper_label(kid):
    return _PAPER_LABEL.get(kid, kid)


def _validate():
    for k, s in PURE_LUT_COMPRESSORS.items():
        in_w  = s['oip_c'] + s['igp_c'] + 2 * s['igp_n']
        out_w = s['gen_c'] + 2 * s['gen_n'] + 4 * s['gen_2n']
        if out_w < in_w:
            raise ValueError("PURE_LUT[%d]: out cap %d < in val %d"
                             % (k, out_w, in_w))
        if s['pins'] > 6:
            raise ValueError("PURE_LUT[%d]: LUT pin demand %d > 6"
                             % (k, s['pins']))
        if s['kind'] == 'LUT6':
            need_cost = s['num_out']
        else:
            need_cost = ceil(s['num_out'] / 2.0)
        if s['cost'] < need_cost:
            raise ValueError("PURE_LUT[%d]: cost %d < required %d"
                             % (k, s['cost'], need_cost))

    for k, s in LUT_CARRY_COMPRESSORS.items():
        if s['kind'] != 'LUT6_2':
            raise ValueError("LUT_CARRY[%s]: expected LUT6_2 kind" % k)
        if s['lut_pins'] > 6:
            raise ValueError("LUT_CARRY[%s]: lut_pins %d > 6" % (k, s['lut_pins']))
        parts = k.split('_')
        base = parts[0]
        n_oip = 0 if len(parts) == 1 else int(parts[1][1:])
        operand_total = {'I': 4, 'II': 3, 'III': 3}[base]
        if s['oip_c'] != n_oip or s['igp_c'] != operand_total - n_oip:
            raise ValueError(
                "LUT_CARRY[%s]: variant signature mismatch "
                "(expected oip_c=%d igp_c=%d, got oip_c=%d igp_c=%d)"
                % (k, n_oip, operand_total - n_oip, s['oip_c'], s['igp_c']))
        if s['gen_c'] != 1:
            raise ValueError("LUT_CARRY[%s]: gen_c must be 1" % k)
        if s['igp_n'] != 0:
            raise ValueError("LUT_CARRY[%s]: igp_n must be 0" % k)
        expected_gen_n = 2 if base == 'III' else 0
        if s['gen_n'] != expected_gen_n:
            raise ValueError("LUT_CARRY[%s]: gen_n must be %d for base %s"
                             % (k, expected_gen_n, base))
        if s['gen_2n'] != 0:
            raise ValueError("LUT_CARRY[%s]: gen_2n must be 0" % k)
        expected_cost = 2 if n_oip == 2 else 1
        if s['cost'] != expected_cost:
            raise ValueError("LUT_CARRY[%s]: cost must be %d for n_oip=%d"
                             % (k, expected_cost, n_oip))


_validate()


if __name__ == "__main__":
    fmt = "{:>4} {:>4} {:>4} {:>4} {:>4} {:>4} {:>4} {:>4} {:>4} {:<7} {}"
    print("=== Table I  Pure-LUT Compressors ===")
    print(fmt.format("idx", "cost", "m", "p", "q",
                     "u", "v", "z", "pins", "kind", "name"))
    for i, s in PURE_LUT_COMPRESSORS.items():
        print(fmt.format(str(i), s['cost'], s['oip_c'], s['igp_c'], s['igp_n'],
                         s['gen_c'], s['gen_n'], s['gen_2n'],
                         s['pins'], s['kind'], s['name']))
    print("\n=== Table II  LUT-CarryChain Compressors (paper-exact + extensions) ===")
    print(fmt.format("typ", "cost", "m", "igc", "ign",
                     "gc", "gn", "g2n", "pins", "kind", "name"))
    for k, s in LUT_CARRY_COMPRESSORS.items():
        print(fmt.format(k, s['cost'], s['oip_c'], s['igp_c'], s['igp_n'],
                         s['gen_c'], s['gen_n'], s['gen_2n'],
                         s['pins'], s['kind'], s['name']))
    print("\nValidation OK.")
