"""
verilog_sim.py  --  a tiny structural simulator for the exact primitive subset
emitted by tiled_verilog_gen / verilog_gen: LUT6, LUT6_2, CARRY4, the
behavioural DSP `*`, and simple wire/assign statements.

It exists so the generated netlist can be checked against a*b in-sandbox WITHOUT
iverilog.  It is NOT a general Verilog parser -- it only understands the regular
constructs this project emits.  Semantics:

  LUT6   : O  = INIT[ {I5,I4,I3,I2,I1,I0} ]
  LUT6_2 : O6 = INIT[ {I5,I4,I3,I2,I1,I0} ] ;  O5 = INIT[ {I4,I3,I2,I1,I0} ] (low 32)
  CARRY4 : c0 = CI|CYINIT ; for i: O[i]=S[i]^c ; CO[i]=c=(c if S[i] else DI[i])
  DSP    : signed/unsigned slice multiply, truncated to the declared width.
"""

import re


class VModule(object):
    def __init__(self, Wa, Wb, nCols):
        self.Wa, self.Wb, self.nCols = Wa, Wb, nCols
        self.bus_width = {}        # name -> width (bits); scalars => 1
        self.elements = []         # parsed statements
        self.dsp = []              # (base, nb, a_lo,a_hi,a_signed, b_lo,b_hi,b_signed)


def _strip_comments(text):
    out = []
    for line in text.splitlines():
        i = line.find('//')
        out.append(line if i < 0 else line[:i])
    return "\n".join(out)


def parse(path, Wa, Wb, nCols):
    text = _strip_comments(open(path).read())
    mod = VModule(Wa, Wb, nCols)
    mod.bus_width['a'] = Wa
    mod.bus_width['b'] = Wb
    mod.bus_width['r'] = nCols
    # split on ';'
    stmts = [s.strip() for s in text.split(';') if s.strip()]
    for s in stmts:
        s2 = re.sub(r'\s+', ' ', s)
        if s2.startswith('module') or s2.startswith('endmodule') or \
           s2.startswith('input') or s2.startswith('output') or \
           s2.startswith('`') or s2.startswith('#'):
            continue
        # wire declarations (capture widths)
        mw = re.match(r'wire\s+(signed\s+)?(\[(\d+):(\d+)\]\s+)?(.+)$', s2)
        if s2.startswith('wire') and '=' not in s2 and '(' not in s2:
            # pure declaration list, e.g. "wire [3:0] cy_co_0, cy_o_0"
            width = 1
            mwid = re.match(r'wire\s+(signed\s+)?\[(\d+):(\d+)\]\s+(.+)$', s2)
            if mwid:
                width = int(mwid.group(2)) - int(mwid.group(3)) + 1
                names = mwid.group(4)
            else:
                names = re.match(r'wire\s+(.+)$', s2).group(1)
            for nm in names.split(','):
                mod.bus_width[nm.strip()] = width
            continue
        # DSP pattern (assignment wires with '=')
        if s2.startswith('wire') and '=' in s2 and '(' not in s2.split('=')[0]:
            _parse_wire_assign(mod, s2)
            continue
        if s2.startswith('(* use_dsp'):
            _parse_wire_assign(mod, s2)
            continue
        if s2.startswith('assign'):
            m = re.match(r'assign\s+(.+?)\s*=\s*(.+)$', s2)
            mod.elements.append(('assign', m.group(1).strip(), m.group(2).strip()))
            continue
        if s2.startswith('LUT6_2'):
            mod.elements.append(_parse_lut(s2, two=True))
            continue
        if s2.startswith('LUT6'):
            mod.elements.append(_parse_lut(s2, two=False))
            continue
        if s2.startswith('CARRY4'):
            mod.elements.append(_parse_carry4(s2))
            continue
    return mod


def _parse_wire_assign(mod, s2):
    # forms:
    #  wire signed [h:0] base_a = EXPR
    #  (* use_dsp = "yes" *) wire signed [h:0] base_p = E1 * E2
    #  wire [nb-1:0] base = base_p[nb-1:0]
    s = re.sub(r'\(\*.*?\*\)\s*', '', s2)
    m = re.match(r'wire\s+(signed\s+)?(\[(\d+):(\d+)\]\s+)?(\w+)\s*=\s*(.+)$', s)
    signed = bool(m.group(1))
    width = (int(m.group(3)) - int(m.group(4)) + 1) if m.group(2) else 1
    name = m.group(5)
    rhs = m.group(6).strip()
    mod.bus_width[name] = width
    mod.elements.append(('assign', name, rhs, signed))


def _ports(s2):
    d = {}
    for k, v in re.findall(r'\.(\w+)\(([^)]*)\)', s2):
        d[k] = v.strip()
    return d


def _parse_lut(s2, two):
    init = int(re.search(r"INIT\(64'h([0-9A-Fa-f]+)\)", s2).group(1), 16)
    p = _ports(s2)
    ins = [p.get('I%d' % i, "1'b0") for i in range(6)]
    if two:
        return ('lut62', init, ins, p.get('O5', ''), p.get('O6', ''))
    return ('lut6', init, ins, p.get('O', ''))


def _parse_carry4(s2):
    p = _ports(s2)
    return ('carry4', p['CO'], p['O'], p['CI'], p['CYINIT'], p['DI'], p['S'])


# --------------------------------------------------------------------------- #
#  evaluation (unified bus model with per-bit "known" tracking)
# --------------------------------------------------------------------------- #
class _Sim(object):
    def __init__(self, mod, a, b):
        self.mod = mod
        self.bus = {'a': a, 'b': b}
        self.known = {'a': set(range(mod.Wa)), 'b': set(range(mod.Wb))}

    def width(self, name):
        return self.mod.bus_width.get(name, 1)

    def set_bit(self, name, idx, val):
        cur = self.bus.get(name, 0)
        self.bus[name] = (cur & ~(1 << idx)) | ((val & 1) << idx)
        self.known.setdefault(name, set()).add(idx)

    def set_bus(self, name, val, width):
        self.bus[name] = val & ((1 << width) - 1)
        self.known[name] = set(range(width))

    # ---- known? ----
    def tok_known(self, tok):
        tok = tok.strip()
        if re.match(r"^\d+'b[01]+$", tok) or tok in ("1'b0", "1'b1"):
            return True
        if tok.startswith('{') and tok.endswith('}'):
            return all(self.tok_known(p) for p in _split_concat(tok[1:-1]))
        m = re.match(r'^\$signed\((.+)\)$', tok)
        if m:
            return self.tok_known(m.group(1))
        m = re.match(r'^(\w+)\[(\d+):(\d+)\]$', tok)
        if m:
            nm, hi, lo = m.group(1), int(m.group(2)), int(m.group(3))
            kn = self.known.get(nm, set())
            return all(i in kn for i in range(lo, hi + 1))
        m = re.match(r'^(\w+)\[(\d+)\]$', tok)
        if m:
            return int(m.group(2)) in self.known.get(m.group(1), set())
        # bare name
        if tok in self.bus or tok in self.known:
            kn = self.known.get(tok, set())
            return all(i in kn for i in range(self.width(tok)))
        return False

    # ---- value ----
    def val(self, tok):
        tok = tok.strip()
        ms = re.match(r'^\$signed\((.+)\)$', tok)
        if ms:
            return self.val(ms.group(1))
        if tok.startswith('{') and tok.endswith('}'):
            v, w = 0, 0
            for part in _split_concat(tok[1:-1]):
                pv, pw = self.val(part)
                v = (v << pw) | (pv & ((1 << pw) - 1))
                w += pw
            return v, w
        m = re.match(r"^(\d+)'b([01]+)$", tok)
        if m:
            return int(m.group(2), 2), int(m.group(1))
        if tok in ("1'b0", "1'b1"):
            return (1 if tok == "1'b1" else 0), 1
        m = re.match(r'^(\w+)\[(\d+):(\d+)\]$', tok)
        if m:
            nm, hi, lo = m.group(1), int(m.group(2)), int(m.group(3))
            return (self.bus.get(nm, 0) >> lo) & ((1 << (hi - lo + 1)) - 1), hi - lo + 1
        m = re.match(r'^(\w+)\[(\d+)\]$', tok)
        if m:
            return (self.bus.get(m.group(1), 0) >> int(m.group(2))) & 1, 1
        return self.bus.get(tok, 0) & ((1 << self.width(tok)) - 1), self.width(tok)

    def bit(self, tok):
        v, _ = self.val(tok)
        return v & 1


def _eval_signed(sim, expr):
    expr = expr.strip()
    m = re.match(r'^\$signed\((.+)\)$', expr)
    inner = m.group(1).strip() if m else expr
    v, w = sim.val(inner)
    return v - (1 << w) if (v >> (w - 1)) & 1 else v


def simulate(mod, a, b):
    sim = _Sim(mod, a, b)
    pending = list(mod.elements)
    while pending:
        still = []
        progress = False
        for el in pending:
            if _try_eval(sim, el):
                progress = True
            else:
                still.append(el)
        if not progress:
            raise RuntimeError("netlist stuck (%d elems); first=%r"
                               % (len(still), still[0]))
        pending = still
    return sim.bus.get('r', 0) & ((1 << mod.nCols) - 1)


def _try_eval(sim, el):
    kind = el[0]
    if kind == 'assign':
        lhs, rhs = el[1], el[2]
        if '*' in rhs:
            a_e, b_e = rhs.split('*')
            if not (sim.tok_known(a_e) and sim.tok_known(b_e)):
                return False
            prod = _eval_signed(sim, a_e) * _eval_signed(sim, b_e)
            sim.set_bus(lhs, prod & ((1 << sim.width(lhs)) - 1), sim.width(lhs))
            return True
        if not sim.tok_known(rhs):
            return False
        signed = len(el) > 3 and el[3]
        m = re.match(r'^(\w+)\[(\d+)\]$', lhs)
        if signed or '$signed' in rhs:
            # signed assignment: sign-extend the source to the wire width
            sval = _eval_signed(sim, rhs)
            sim.set_bus(lhs, sval & ((1 << sim.width(lhs)) - 1), sim.width(lhs))
            return True
        v, w = sim.val(rhs)
        if m:
            sim.set_bit(m.group(1), int(m.group(2)), v & 1)
        else:
            sim.set_bus(lhs, v, sim.width(lhs))
        return True
    if kind == 'lut6':
        _, init, ins, o = el
        if not all(sim.tok_known(t) for t in ins):
            return False
        idx = sum(sim.bit(ins[i]) << i for i in range(6))
        _set_out(sim, o, (init >> idx) & 1)
        return True
    if kind == 'lut62':
        _, init, ins, o5, o6 = el
        if not all(sim.tok_known(t) for t in ins):
            return False
        idx6 = sum(sim.bit(ins[i]) << i for i in range(6))
        idx5 = sum(sim.bit(ins[i]) << i for i in range(5))
        if o6:
            _set_out(sim, o6, (init >> idx6) & 1)
        if o5:
            _set_out(sim, o5, (init >> idx5) & 1)
        return True
    if kind == 'carry4':
        _, co, o, ci, cyinit, di, s = el
        if not (sim.tok_known(ci) and sim.tok_known(cyinit)
                and sim.tok_known(di) and sim.tok_known(s)):
            return False
        c = sim.bit(ci) | sim.bit(cyinit)
        di_v, _ = sim.val(di)
        s_v, _ = sim.val(s)
        o_v = 0
        co_v = 0
        for i in range(4):
            si = (s_v >> i) & 1
            o_v |= (si ^ c) << i
            c = c if si else ((di_v >> i) & 1)
            co_v |= c << i
        sim.set_bus(o, o_v, 4)
        sim.set_bus(co, co_v, 4)
        return True
    raise ValueError(kind)


def _set_out(sim, tok, val):
    m = re.match(r'^(\w+)\[(\d+)\]$', tok)
    if m:
        sim.set_bit(m.group(1), int(m.group(2)), val)
    else:
        sim.set_bit(tok, 0, val)


def _split_concat(s):
    parts, depth, cur = [], 0, ''
    for ch in s:
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
        if ch == ',' and depth == 0:
            parts.append(cur.strip()); cur = ''
        else:
            cur += ch
    if cur.strip():
        parts.append(cur.strip())
    return parts
