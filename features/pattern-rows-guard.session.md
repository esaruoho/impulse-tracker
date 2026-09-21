# Session — pattern-rows-guard (the ad_stim.it freeze)

Faithful, not flattering. This is the vibe-diff for `pattern-rows-guard.feature`.

## How to get back
- Transcript: this Claude Code session in `/Users/esaruoho/work/impulse-tracker`
- Date: 2026-09-21
- Resume: `claude --resume <id>` (session id in the transcript header)

## The request
Esa saved `ad_stim.it` (29 KB) on the XP/DOS SMB network drive today. Loading it in
the fork threw "crash warning: pattern size mismatch: fix: remove: corrupted data"
and the app **completely froze**. He asked to (1) make + retain the direct SMB
connection, (2) recover the file, and then (3) fix BOTH the save bug and the freeze,
build, push to GitHub, and deploy the build to the XP network drive.

## Connection (retained in DEPLOY-TO-XP.md)
- The old doc said login `fleet` / `Lackluster1!`. That failed at the connection
  level. Esa corrected: **user `esaruoho`, password EMPTY** (just Enter).
- GUI `open smb://` fails headlessly (needs Finder focus). `mount_smbfs
  '//esaruoho:@192.168.32.50/netdrive' <mp>` mounts SMB1 to XP SP3, rc=0.

## The file (what was actually wrong)
Parsed the IT header: Ord 7, Ins 22, Smp 22, Pat 16, Cwt=0x2354 (the fork's v2.354
stamp -> the fork wrote this file). Order list `[0,2,2,+++,1,1,---]` -> uses pats
0,1,2. All 22 instruments (IMPI) and 22 samples (IMPS, real names: mefis/f!, k303,
george) intact. Six pattern headers were malformed with **rows=0**: pats 0,5,6,7,8,15.
Pattern 0 (packlen=0 rows=0) is referenced by order[0], so it detonated on load.
Pats 8 and 15 had packlen=160 rows=0 resv=0x000B0000 (garbage). Real music lives in
pat 1 (192 rows), pat 2 (96), pat 12 (48) -- matching Esa's "192 max, only a few".

Recovery: set the six broken offset-table entries to 0 (IT's "empty pattern"
sentinel, same as pats 3,4,9,10,11,13,14 already were). 12 bytes changed. Shipped as
`AD_STIM2.IT` on E:\ root; original `AD_STIM.IT` kept as backup.

## Root cause (the mechanism)
`DecodePattern` (IT_PE.ASM): `LodsW` rows -> `Mov CX,AX / Dec AX / Mov MaxRow,AX`.
For rows=0: `Dec 0 -> 0FFFFh`, so MaxRow=65535. With packlen=0 there was no bounds
check, so the `LodsB` channel reader ran into the next pattern's bytes and the row
`Loop` underflowed CX from 0 to 65535 -> ~65536 rows, DI += 320 each -> ran far past
PatternDataArea -> memory trash. The "Pattern Size Mismatch" dialog (Sub SI / Cmp)
only fires AFTER the damage, so the app was already hung. This is the "512 rows"
phantom Esa saw in the editor.

`EncodePattern` writes `rows = MaxRow+1`. So if MaxRow was ever 0FFFFh, it wrote
rows=0 -> a self-propagating corruption between save and load.

## The fix (both boundaries; invariant = 1..256 rows)
- DecodePattern: `And AX,AX / JZ DecodePatternEmpty` (rows==0 -> empty 64-row,
  MaxRow=63, clear data, skip decode) and `Cmp AX,256 / clamp` for absurd counts.
- EncodePattern: `Inc CX / JNZ / Mov CX,64 / Mov MaxRow,63` so a stored pattern can
  never carry rows=0.

Defense in depth: I could not pin down which fork feature (order-list Alt-D clone,
F2 default-length, tiling) first produced MaxRow=0FFFFh, so the guard enforces the
invariant at both the encode boundary (can't create it) and decode boundary (can't
be frozen by it) regardless of origin. This is the safer call than editing the
format-save path blind on a memory-constrained real-mode EXE.

## Grade
`@build-verified` — TASM 4.1 assembles IT_PE.asm with Error/Warning None; TLINK 3.01
links IT.EXE (482680 bytes). NOT yet run: `@runtime-untested @hw-untested`. Esa to
confirm by loading the ORIGINAL corrupt `AD_STIM.IT` with the new IT.EXE and seeing
it open (as empty pat 0) instead of freezing.
