#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""Usage: scripts/blank-lines.py FILE...

Sibling bindings of an attrset or let block are separated by a blank line
when their depths differ by two or more, and by none otherwise. A binding's
depth is the deepest nesting of { and [ inside it. Comments above a binding
move with it. Files are rewritten in place; the exit status is 1 when one
changed. Expects nixfmt-formatted input."""

import re
import sys

BINDING = re.compile(r"^( *)(inherit\b|[A-Za-z_\"$][^=]*?\s*=(?!=))")


def strip(line, in_string):
    """The code of a line without strings and comments, and whether a '' string
    is still open at its end."""
    out, i = [], 0
    while i < len(line):
        if in_string:
            if line.startswith("'''", i) or line.startswith("''$", i) or line.startswith("''\\", i):
                i += 3
            elif line.startswith("''", i):
                in_string, i = False, i + 2
            else:
                i += 1
        elif line.startswith("''", i):
            in_string, i = True, i + 2
        elif line[i] == '"':
            i += 1
            while i < len(line) and line[i] != '"':
                i += 2 if line[i] == "\\" else 1
            i += 1
        elif line[i] == "#":
            break
        else:
            out.append(line[i])
            i += 1
    return "".join(out), in_string


def analyse(lines):
    """Per line: (code, inside a '' string at its start)."""
    res, in_string = [], False
    for line in lines:
        code, after = strip(line, in_string)
        res.append((code, in_string))
        in_string = after
    return res


def depth(codes):
    stack, d, best = [], 0, 0
    for code in codes:
        for i, ch in enumerate(code):
            if ch == "{" and i > 0 and code[i - 1] == "$":
                stack.append(False)
            elif ch in "{[":
                stack.append(True)
                d += 1
                best = max(best, d)
            elif ch in "}]" and stack:
                if stack.pop():
                    d -= 1
    return best


def indent(line):
    return len(line) - len(line.lstrip(" "))


def trim_block_edges(lines):
    """No blank line just inside an opening or before a closing bracket."""
    info = analyse(lines)
    keep = []
    for i, line in enumerate(lines):
        if not line.strip() and not info[i][1]:
            prev = next((info[j][0].rstrip() for j in range(i - 1, -1, -1) if lines[j].strip()), "")
            nxt = next((lines[j].strip() for j in range(i + 1, len(lines)) if lines[j].strip()), "")
            if prev.endswith(("{", "[", "(")) or nxt.startswith(("}", "]", ")")):
                continue
        keep.append(line)
    return keep


def fix(text):
    lines = trim_block_edges(text.split("\n"))
    info = analyse(lines)
    changed = True
    while changed:
        changed = False
        info = analyse(lines)
        n = len(lines)
        for i in range(n):
            code, in_str = info[i]
            if in_str or not lines[i].strip() or lines[i].strip().startswith("#"):
                continue
            m = BINDING.match(lines[i])
            if not m:
                continue
            ind = len(m.group(1))
            # end of this binding: last line before the next line at this indent or less
            j = i + 1
            while j < n and (info[j][1] or not lines[j].strip() or indent(lines[j]) > ind):
                j += 1
            # a closing line at the same indent (`};`, `];`, `''`) still belongs to it
            while j < n and lines[j].strip() and indent(lines[j]) == ind and not info[j][1] \
                    and not BINDING.match(lines[j]) and not lines[j].strip().startswith("#"):
                if lines[j].strip()[0] not in "}])'":
                    break
                j += 1
            end = j - 1
            while end > i and not lines[end].strip():
                end -= 1
            # next sibling, possibly preceded by comments and blank lines
            k = end + 1
            gap_start = k
            while k < n and not lines[k].strip():
                k += 1
            c = k
            while c < n and lines[c].strip().startswith("#") and indent(lines[c]) == ind:
                c += 1
            if c >= n or not lines[c].strip() or indent(lines[c]) != ind or not BINDING.match(lines[c]) or info[c][1]:
                continue
            # extent of the next sibling
            e = c + 1
            while e < n and (info[e][1] or not lines[e].strip() or indent(lines[e]) > ind):
                e += 1
            while e < n and lines[e].strip() and indent(lines[e]) == ind and lines[e].strip()[0] in "}])'":
                e += 1
            d1 = depth(info[x][0] for x in range(i, end + 1))
            d2 = depth(info[x][0] for x in range(c, e))
            want_blank = abs(d1 - d2) >= 2
            has_blank = k > gap_start
            if want_blank != has_blank:
                if want_blank:
                    lines[gap_start:k] = [""]
                else:
                    del lines[gap_start:k]
                changed = True
                break
    return "\n".join(lines)


status = 0
for path in sys.argv[1:]:
    with open(path) as f:
        text = f.read()
    new = fix(text)
    if new != text:
        with open(path, "w") as f:
            f.write(new)
        print(f"blank lines fixed: {path}")
        status = 1
sys.exit(status)
