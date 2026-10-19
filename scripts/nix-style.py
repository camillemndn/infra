#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages (ps: [ ps.tree-sitter ps.tree-sitter-grammars.tree-sitter-nix ])"
"""Usage: scripts/nix-style.py FILE...
Sorts the bindings of every attribute set: `inherit` lines first, then
`enable`, then the others by name; a set holding `imports` or `options` keeps
`imports`, `options`, the rest, `config`. `let` bindings keep their order.
Comments above a binding, or after it on its last line, move with it.
Then sibling bindings are separated by a blank line when one of them spans
several lines, and by none otherwise; no blank line sits just inside brackets.
Rewrites nixfmt-formatted files and exits 1 if any changed."""

import re
import sys
import warnings

import tree_sitter
import tree_sitter_nix

with warnings.catch_warnings():
    warnings.simplefilter("ignore", DeprecationWarning)
    NIX = tree_sitter.Language(tree_sitter_nix.language())

PARSER = tree_sitter.Parser(NIX)
ITEMS = ("binding", "inherit", "inherit_from")
SETS = ("attrset_expression", "rec_attrset_expression")


def first_name(item):
    attrpath = item.child_by_field_name("attrpath")
    return attrpath.named_children[0].text.decode().strip('"')


def sort_key(item, module):
    if item.type != "binding":
        return (0, "")
    path = item.child_by_field_name("attrpath").text.decode().replace('"', "")
    name = first_name(item)
    if path == "enable":
        return (1, "")
    if module and name in ("imports", "options"):
        return (2 if name == "imports" else 3, "")
    if module and name == "config":
        return (5, "")
    return (4, path)


def starts_line(lines, row, col):
    return not lines[row][:col].strip()


def sort_once(text):
    """Sorts the first unsorted attribute set; returns the new text or None."""
    lines = text.split("\n")
    tree = PARSER.parse(text.encode())
    stack = [tree.root_node]
    while stack:
        node = stack.pop()
        stack.extend(reversed(node.children))
        if node.type != "binding_set" or node.parent.type not in SETS:
            continue
        items = [c for c in node.children if c.type in ITEMS]
        if len(items) < 2:
            continue
        names = {first_name(i) for i in items if i.type == "binding"}
        module = bool(names & {"imports", "options"})
        order = sorted(range(len(items)), key=lambda k: sort_key(items[k], module))
        if order == list(range(len(items))):
            continue

        # One item per line range, each starting its line.
        rows = [(i.start_point.row, i.end_point.row) for i in items]
        if any(rows[k][0] <= rows[k - 1][1] for k in range(1, len(rows))):
            continue
        if not all(starts_line(lines, i.start_point.row, i.start_point.column) for i in items):
            continue

        # Between two items there are only comments and blank lines: the
        # comments, with the blank lines among them, belong to the next item.
        opening = node.parent.start_point.row
        if rows[0][0] <= opening:
            continue
        blocks = []
        previous = opening
        for start, end in rows:
            between = range(previous + 1, start)
            if not all(not lines[r].strip() or lines[r].lstrip().startswith(("#", "/*", "*")) for r in between):
                break
            filled = [r for r in between if lines[r].strip()]
            blocks.append((filled[0] if filled else start, end))
            previous = end
        else:
            first, last = blocks[0][0], blocks[-1][1]
            new = []
            for k in order:
                a, b = blocks[k]
                new.extend(lines[a : b + 1])
            return "\n".join(lines[:first] + new + lines[last + 1 :])
    return None


def sort_bindings(text):
    for _ in range(10000):
        new = sort_once(text)
        if new is None:
            return text
        text = new
    raise RuntimeError("sorting did not settle")


BINDING = re.compile(r" *(inherit\b|[\w\"$'-][^=]*?=(?!=))")


def blank_lines(lines):
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
    new = "\n".join(blank_lines(sort_bindings(text).split("\n")))
    if new != text:
        open(path, "w").write(new)
        print("restyled:", path)
        changed = True
sys.exit(changed)
