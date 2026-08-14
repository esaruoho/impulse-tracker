#!/usr/bin/env python3
"""Regenerate features/KEYMAPS.generated.md straight from the .ASM keymap tables.

Why this exists: every hand-written summary of these tables has gone stale, and on
2026-08-14 a stale one cost a debugging session -- a screen's Shift-<arrow> row was
missing from the summary, so the conclusion "F11 Shift-Right cannot dispatch" was
drawn and the user was told their working feature didn't work. The tables are
trivially machine-readable, so nobody should ever be reading a hand copy again.

Deterministic parsing, no network, no model. Run by features/gen-all.sh and by
.githooks/pre-commit.local whenever a .ASM file is staged.

Table shape being parsed (M_FunctionDivider, IT_M.ASM:168):

    <Name>          Label
                    DB      <modifier code>
                    DW      <key word>
                    DW      Offset <handler>
                    ...
                    DB      0FFh            ; end of list
"""

import os
import re
import sys
import glob
import subprocess

# --- what M_FunctionDivider does with each code (IT_M.ASM:172-240) -----------
CODES = {
    '0': ('direct',   'full CX  -- matches ONLY with no modifier bits set'),
    '1': ('key word', 'DX'),
    '2': ('Alt',      'CX AND 1FFh  (gate: Test CH,60h)'),
    '3': ('Ctrl',     'CX AND 1FFh  (gate: Test CH,18h)'),
    '4': ('Shift',    'CX AND 1FFh  (gate: Test CH,6)'),
    '5': ('capital',  'DX, uppercased'),
    '6': ('MIDI',     'CX AND 0F000h'),
}

# --- key words that are safe to name; anything else is left raw --------------
NAMED = {
    '1C7h': 'Home',   '1C8h': 'Up',      '1C9h': 'PgUp',
    '1CBh': 'Left',   '1CDh': 'Right',   '1CFh': 'End',
    '1D0h': 'Down',   '1D1h': 'PgDn',    '1D2h': 'Insert', '1D3h': 'Delete',
    '10Fh': 'Tab',    '0F00h': 'Shift-Tab',
}
# Alt+letter arrives as <scancode>00h. Scancodes for the letter rows:
ALT_SCAN = {
    0x10: 'Q', 0x11: 'W', 0x12: 'E', 0x13: 'R', 0x14: 'T', 0x15: 'Y',
    0x16: 'U', 0x17: 'I', 0x18: 'O', 0x19: 'P',
    0x1E: 'A', 0x1F: 'S', 0x20: 'D', 0x21: 'F', 0x22: 'G', 0x23: 'H',
    0x24: 'J', 0x25: 'K', 0x26: 'L',
    0x2C: 'Z', 0x2D: 'X', 0x2E: 'C', 0x2F: 'V', 0x30: 'B', 0x31: 'N',
    0x32: 'M',
}


def parse_hex(tok):
    t = tok.strip()
    if re.fullmatch(r"'.'", t):
        return ord(t[1]), t
    m = re.fullmatch(r'([0-9A-Fa-f]+)h', t)
    if m:
        return int(m.group(1), 16), t
    if re.fullmatch(r'\d+', t):
        return int(t), t
    return None, t


def describe(code, keytok):
    """Human name for a key word, or '' when we cannot be certain."""
    val, raw = parse_hex(keytok)
    if val is None:
        return ''
    if raw in NAMED:
        return NAMED[raw]
    if re.fullmatch(r"'.'", raw):
        return f"'{chr(val)}'"
    if code == '3' and 1 <= val <= 26:          # Ctrl+letter
        return f"Ctrl-{chr(val + 64)}"
    if code == '1' and 1 <= val <= 26:          # Ctrl+letter reaching DX
        return f"Ctrl-{chr(val + 64)}"
    if val & 0xFF == 0 and (val >> 8) in ALT_SCAN:
        return f"Alt-{ALT_SCAN[val >> 8]}"
    return ''


def tables_in(path):
    """Yield (label, line_no, [(code, key, handler), ...]) for each keymap table."""
    text = open(path, encoding='latin-1').read().replace('\r', '')
    lines = text.split('\n')
    for i, line in enumerate(lines):
        # Most tables are named <Something>Keys, but not all: the PATTERN EDITOR's
        # is PEFunctions, and GlobalKeyList is a List. Matching only *Keys left the
        # single most-asked-about table -- every pattern editor binding -- out of the
        # dump entirely, which is exactly the staleness this script exists to kill.
        m = re.match(r'^(\w*(?:Keys|KeyList|Functions))\s+Label\b', line)
        if not m:
            continue
        label = m.group(1)
        rows, code, key = [], None, None
        for j in range(i + 1, min(i + 400, len(lines))):
            t = lines[j].strip()
            if not t or t.startswith(';'):
                continue
            mdb = re.match(r'DB\s+([^\s;]+)', t)
            if mdb:
                if mdb.group(1) == '0FFh':
                    break
                code, key = mdb.group(1), None
                continue
            mdw = re.match(r'DW\s+([^;]+)', t)
            if mdw and code is not None:
                v = mdw.group(1).strip()
                if key is None:
                    key = v
                else:
                    rows.append((code, key, v.replace('Offset', '').strip()))
                    key = None
        if rows:
            yield label, i + 1, rows


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    try:
        sha = subprocess.run(['git', '-C', root, 'rev-parse', '--short', 'HEAD'],
                             capture_output=True, text=True).stdout.strip()
    except Exception:
        sha = '?'

    found = []
    for path in sorted(glob.glob(os.path.join(root, '*.ASM'))):
        for label, ln, rows in tables_in(path):
            found.append((os.path.basename(path), label, ln, rows))

    out = [
        '# Keymap tables — GENERATED, do not hand-edit',
        '',
        f'Dumped from the .ASM sources at `{sha}` by `features/gen-keymaps.py`.',
        'Regenerated by `features/gen-all.sh` and by the pre-commit hook whenever a',
        '`.ASM` file is staged, so it cannot go stale the way a hand-written summary',
        'does. If a keybinding question comes up, read THIS, not a prose summary.',
        '',
        '## How a row is matched (IT_M.ASM:168-261)',
        '',
        '`CH` = modifier flags, `CL` = key code.',
        '',
        '| code | modifier | value compared |',
        '|------|----------|----------------|',
    ]
    for c, (name, cmp) in CODES.items():
        out.append(f'| {c} | {name} | `{cmp}` |')
    out += [
        '',
        'Consequence worth remembering: **code 0 compares the whole `CX`**, so it only',
        'matches when no modifier is held. Codes 2/3/4 mask with `1FFh`, which is why a',
        'shifted arrow still matches its base key word. To bind both plain and modified',
        'forms of a key, give it **two rows** — one code 0, one code 2/3/4 — which may',
        'point at the same handler.',
        '',
        'Codes 2/3/4 test only their own modifier bit and reject nothing else, so a',
        'code-4 row also matches Ctrl-Shift-<key>.',
        '',
    ]

    for fname, label, ln, rows in found:
        out += [f'## `{label}` — {fname}:{ln}', '',
                '| code | modifier | key | meaning | handler |',
                '|------|----------|-----|---------|---------|']
        for code, key, handler in rows:
            name, _ = CODES.get(code, ('?', '?'))
            out.append(f'| {code} | {name} | `{key}` | {describe(code, key)} | `{handler}` |')
        out.append('')
        # flag keys registered more than once, which is the pattern that was missed
        seen = {}
        for code, key, handler in rows:
            seen.setdefault(key, []).append(code)
        multi = {k: v for k, v in seen.items() if len(v) > 1}
        if multi:
            out.append('Registered more than once (plain + modified forms):')
            out.append('')
            for k, codes in multi.items():
                names = ', '.join(f'{c}={CODES.get(c, ("?",))[0]}' for c in codes)
                out.append(f'- `{k}` — codes {names}')
            out.append('')

    dst = os.path.join(root, 'features', 'KEYMAPS.generated.md')
    open(dst, 'w').write('\n'.join(out) + '\n')
    print(f'gen-keymaps: {len(found)} tables -> features/KEYMAPS.generated.md')
    return 0


if __name__ == '__main__':
    sys.exit(main())
