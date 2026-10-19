#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""Usage: scripts/blank-lines.py FILE...
Sibling bindings are separated by a blank line when one of them spans several
lines, and by none otherwise; no blank line sits just inside brackets.
Rewrites nixfmt-formatted files and exits 1 if any changed."""

import re
import sys

BINDING = re.compile(r" *(inherit\b|[\w\"$'-][^=]*?=(?!=))")


def apply(lines):
    inside, after, s = [], [], False
    for l in lines:
        inside.append(s)
        s ^= len(re.findall(r"(?<!')''(?![$'\\])", l)) % 2 == 1
        after.append(s)
    ind = [len(l) - len(l.lstrip()) for l in lines]
    code = [l.split(" #")[0].rstrip() for l in lines]
    real = [i for i, l in enumerate(lines) if l.strip() and not (inside[i] and after[i])]
    nxt = {a: b for a, b in zip(real, real[1:])}
    gap = {}  # last line before a gap -> wanted number of blank lines

    for a, b in nxt.items():
        if after[a]:
            continue
        if code[a].endswith(("{", "[", "(")) or lines[b].lstrip().startswith(("}", "]", ")")):
            gap[a] = 0

    def end(i):
        e = i
        while e in nxt and ind[nxt[e]] > ind[i]:
            e = nxt[e]
        if e in nxt and ind[nxt[e]] == ind[i] and lines[nxt[e]].lstrip()[:1] in "}])'":
            e = nxt[e]
        return e

    for i in real:
        if not BINDING.match(lines[i]):
            continue
        e = end(i)
        c = nxt.get(e)
        while c is not None and lines[c].lstrip().startswith("#") and ind[c] == ind[i]:
            c = nxt.get(c)
        if c is None or after[e] or inside[c] or ind[c] != ind[i] or not BINDING.match(lines[c]):
            continue
        gap[e] = 1 if e > i or end(c) > c else 0

    out = []
    for i, l in enumerate(lines):
        if not l.strip() and not inside[i]:
            prev = max((j for j in real if j < i), default=None)
            if prev in gap:
                continue
        out.append(l)
        if gap.get(i) == 1:
            out.append("")
    return out


changed = False
for path in sys.argv[1:]:
    text = open(path).read()
    new = "\n".join(apply(text.split("\n")))
    if new != text:
        open(path, "w").write(new)
        print("blank lines fixed:", path)
        changed = True
sys.exit(changed)
