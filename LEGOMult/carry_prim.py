# -*- coding: utf-8 -*-
"""carry_prim.py -- portable hard-carry-chain primitive for the RTL emitters.

The compressor library of this work is expressed over two abstract resources:
a 6-input LUT that may be fractured into two 5-input outputs, and one bit of
hard carry chain.  Both exist in every recent AMD fabric; only the number of
carry bits packaged into one primitive changes:

    7-series / Spartan-7 / Artix-7 / Kintex-7 / Virtex-7   CARRY4   (4 bits)
    UltraScale, UltraScale+                                CARRY8   (8 bits)
    Versal (AI Core / Prime / Premium)                     CARRY8   (8 bits)

Retargeting the generator across these families is therefore a change of chain
*granularity*, not of the ILP: the compressor models, the heap state and both
objectives are untouched, and only the chunking of a logical chain into
primitive instances differs.  This module isolates that difference.

Port mapping
------------
CARRY4 .CO[3:0] .O[3:0] .CI .CYINIT .DI[3:0] .S[3:0]
CARRY8 .CO[7:0] .O[7:0] .CI .CI_TOP  .DI[7:0] .S[7:0]

CARRY8 has no CYINIT: on 7-series exactly one of CI/CYINIT may be driven, and
the UltraScale+/Versal equivalent is to drive CI.  emit_carry() accepts both and
folds them for CARRY8.  CARRY_TYPE is pinned to "SINGLE_CY8" so that one
instance is one eight-bit chain and .CI_TOP is tied low.
"""

_WIDTH = 4

_PRIMS = {
    4: {"name": "CARRY4", "params": "", "ci_top": False},
    8: {"name": "CARRY8", "params": '#(.CARRY_TYPE("SINGLE_CY8")) ',
        "ci_top": True},
}

# Device-family prefix -> carry-chain width.  Matched against the lowercased
# Vivado part name, longest prefix first.
_FAMILY_WIDTH = (
    ("xcvc", 8), ("xcvm", 8), ("xcvp", 8), ("xcve", 8),   # Versal
    ("xcku", 8), ("xcvu", 8), ("xczu", 8), ("xcau", 8),   # UltraScale(+)
    ("xcu", 8),                                            # UltraScale boards
    ("xc7", 4), ("xa7", 4), ("xq7", 4),                    # 7-series
    ("xcs", 4),                                            # Spartan-7 variants
)


def set_carry_width(width):
    """Select the carry primitive granularity (4 = CARRY4, 8 = CARRY8)."""
    global _WIDTH
    if width not in _PRIMS:
        raise ValueError("unsupported carry width %r (expected 4 or 8)" % width)
    _WIDTH = width
    return _WIDTH


def set_carry_for_part(part):
    """Select the carry primitive from a Vivado part name, e.g. 'xcvc1902-...'.

    Unrecognised parts keep the current setting, so an unknown device never
    silently produces a netlist for the wrong fabric."""
    if not part:
        return _WIDTH
    p = str(part).strip().lower()
    for prefix, w in _FAMILY_WIDTH:
        if p.startswith(prefix):
            return set_carry_width(w)
    return _WIDTH


def carry_width():
    return _WIDTH


def carry_name():
    return _PRIMS[_WIDTH]["name"]


def n_chunks(span):
    """Number of primitive instances needed for a `span`-bit logical chain."""
    w = _WIDTH
    return (span + w - 1) // w


def msb_index():
    """Index of the carry-out bit that feeds the next instance's CI."""
    return _WIDTH - 1


def emit_carry(f, inst, co, o, ci, cyinit, d_terms, s_terms):
    """Write one carry-primitive instance.

    `d_terms` / `s_terms` are lists of signal strings, LSB first, of length
    carry_width() (callers pad with "1'b0").  `ci` and `cyinit` follow the
    7-series convention that at most one of them is driven; for CARRY8 they are
    folded onto .CI and .CI_TOP is tied low.
    """
    w = _WIDTH
    if len(d_terms) != w or len(s_terms) != w:
        raise ValueError("expected %d DI/S terms, got %d/%d"
                         % (w, len(d_terms), len(s_terms)))
    prim = _PRIMS[w]
    d_concat = "{ %s }" % ", ".join(reversed(d_terms))
    s_concat = "{ %s }" % ", ".join(reversed(s_terms))
    if prim["ci_top"]:
        # CARRY8: no CYINIT; whichever of CI/CYINIT is driven becomes CI.
        ci_eff = ci if ci.strip() != "1'b0" else cyinit
        f.write("  %s %su_%s (\n"
                "    .CO(%s), .O(%s),\n"
                "    .CI(%s), .CI_TOP(1'b0),\n"
                "    .DI(%s), .S(%s));\n"
                % (prim["name"], prim["params"], inst, co, o,
                   ci_eff, d_concat, s_concat))
    else:
        f.write("  %s %su_%s (\n"
                "    .CO(%s), .O(%s),\n"
                "    .CI(%s), .CYINIT(%s),\n"
                "    .DI(%s), .S(%s));\n"
                % (prim["name"], prim["params"], inst, co, o,
                   ci, cyinit, d_concat, s_concat))


def decl_bus(f, *names):
    """Declare one or more carry-width buses."""
    f.write("  wire [%d:0] %s;\n" % (_WIDTH - 1, ", ".join(names)))
