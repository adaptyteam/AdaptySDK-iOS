#!/usr/bin/env python3
"""Generate our vendored Kingfisher tree from a pristine upstream checkout.

Transform (verified byte-exact against the 8.9.0 drop, modulo 3 known
one-line artifacts of the previous cruder sed):
  1. `open class`  -> `final class`
  2. `public|open internal(set)` -> (removed)
  3. `public`/`open` declaration modifiers -> (removed), comments untouched
Skips Documentation.docc and Info.plist (not vendored).
"""
import re
import sys
from pathlib import Path

UPSTREAM = Path(sys.argv[1])  # .../kf-upstream/Sources
OURS = Path(sys.argv[2])      # .../Sources.MediaCache/Kingfisher

OPEN_CLASS_RE = re.compile(r'(^\s*|\s)open\s+class\b')
INTERNAL_SET_RE = re.compile(r'(^\s*|\s)(?:public|open)\s+internal\(set\)\s+')
MODIFIER_RE = re.compile(
    r'(?P<prefix>^\s*|\s)(?:public|open)\s+'
    r'(?=(?:static|class|final|func|var|let|init|enum|struct|protocol|extension|'
    r'typealias|subscript|convenience|required|weak|unowned|lazy|dynamic|override|'
    r'indirect|mutating|nonmutating|actor|associatedtype|private|internal|package)\b)'
)

def strip_visibility(text: str) -> str:
    out_lines = []
    for line in text.split('\n'):
        stripped = line.lstrip()
        if stripped.startswith('//') or stripped.startswith('*'):
            out_lines.append(line)
            continue
        line = OPEN_CLASS_RE.sub(r'\1final class', line)
        line = INTERNAL_SET_RE.sub(r'\1', line)
        prev = None
        while prev != line:
            prev = line
            line = MODIFIER_RE.sub(lambda m: m.group('prefix'), line)
        out_lines.append(line)
    return '\n'.join(out_lines)

ups_files = {p.relative_to(UPSTREAM) for p in UPSTREAM.rglob('*.swift')
             if 'Documentation.docc' not in p.parts}
our_files = {p.relative_to(OURS) for p in OURS.rglob('*.swift')}

written = same = 0
for rel in sorted(ups_files):
    content = strip_visibility((UPSTREAM / rel).read_text())
    target = OURS / rel
    if target.exists() and target.read_text() == content:
        same += 1
        continue
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content)
    written += 1
    print(f"wrote {rel}")

for rel in sorted(our_files - ups_files):
    print(f"REMOVED upstream, deleting: {rel}")
    (OURS / rel).unlink()

print(f"\n{written} written, {same} unchanged, {len(our_files - ups_files)} deleted")
