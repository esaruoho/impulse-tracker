# Session — Ctrl-O empty-order-list reboot crash

> The spawning conversation for `ctrl-o-empty-orderlist-crash.feature`. Faithful,
> not flattering — the diagnosis path, including what was ruled out.

## The report (2026-06-23 evening)
Esa: *"good evening. we have issues. i had zero patterns in orderlist, but was
playing a pattern with F6. i pressed CTRL-O. and impulsetracker immediately
crashed and rebooted the whole drive. thats not good."*

A reboot (not a hang) means real-mode DOS hardware took a wild memory access and
triple-faulted. Data-loss severity — treated as a stop-everything bug.

## Diagnosis (read-only, in IT_MUSIC.ASM / IT_PE.ASM)
1. Ctrl-O = `PEFunction_RenderPattern` (IT_PE.ASM:5318) -> `PE_GetCurrentPattern`
   (returns the EDITOR pattern, valid) -> `Music_ToggleWAVRender`.
2. The single-pattern render plays the editor pattern via `Music_PlayPattern`
   (valid), then on leave RESUMES the F6 song: `WAV_DoResumeOnLeave` ->
   `Music_ResumeAfterRender` -> song branch -> `Music_PlayPartSong`.
3. **The leak:** `Music_PlayPartSong` (IT_MUSIC.ASM:9384) does
   `MovZX AX,[DS:BX+100h]` / `Mov CurrentPattern,AX` — reads the order-list byte
   straight into CurrentPattern with **no marker check**. Empty order list =>
   `OrderList[0]=0FFh` => CurrentPattern = 255.
4. **The catastrophe:** next tick `Music_GetPattern(255)` did
   `LEA SI,[63912+EAX*4]` with no bound — 220 bytes past the 200-entry table —
   then `LodsW` dereferenced a wild segment. Real-mode => reboot.
5. **Why F6 alone is safe:** the engine's own order-advance `UpdateData_Song`
   (IT_MUSIC.ASM:~8991) gates with `Cmp CL,200 / JB valid` and handles 0FEh/0FFh.
   The resume-after-render shortcut bypasses that gate. That asymmetry is the bug.

## Decision
Fix the **sink, not just the source**: bound-check `Music_GetPattern` with the
same `>=200` threshold the engine uses, falling back to the existing safe
`EmptyPattern`. One chokepoint, every invalid-pattern path protected, hot-path
cost is a single compare+branch. The leak source (`Music_PlayPartSong` storing a
marker as CurrentPattern) is documented as a `@known-limit` follow-up — the sink
guard already removes the catastrophic outcome.

## Ruled out / not done
- Not a bad render destination (preflight path check already exists).
- Not the editor pattern (always valid 0..199).
- Did NOT harden `Music_PlayPartSong` itself this pass — narrower change, higher
  risk, and the sink guard fully neutralises the reboot. Left as a noted limit.

## Honest grade
`@build-verified` only: `IT_MUSIC.asm` assembled Error/Warning = None and `IT.EXE`
relinked clean in DOSBox-X. **Not** runtime-verified — the crash repro is on real
DOS hardware, which only Esa can confirm. Tagged `@runtime-untested @hw-untested`.

## Second report, same turn — the HANG (a SEPARATE bug)
Esa: *"added 000 pattern, pressed right-arrow, impulsetracker.exe also became
unresponsive ... i need all versions to work (ctrl-o to empty sample slot,
right-arrow in orderlist, shift-arrow -> quicksave folder). dry-run, test, build
and deploy to netdrive/ITNU2026."*

Right-arrow at the order-list edge promotes to a render (PE_OrderList_RightDispatch
-> RenderDispatch -> Music_ToggleWAVRender), so all three gestures share one path.
With a VALID pattern 000 it HUNG (not rebooted) => a second, independent bug.

Diagnosis: the single-pattern render plays via Music_PlayPattern (which LOOPS) and
then spins a synchronous Music_Poll loop until PlayMode==0. The only stop-at-end
mechanism, StopEndOfPlaySection, is declared `DW 0` (IT_MUSIC.ASM:707), read at the
pattern-end (UpdateData_Pattern1) and song-end checks, and **set NOWHERE in the
whole codebase** (`grep` proved it). So the pattern looped forever and the sync loop
ran its 100000-iteration safety cap -> a multi-minute freeze = "unresponsive."
Song-mode render survived only because the order-advance has a double-wrap guard.

Fix: set StopEndOfPlaySection=1 before the single-pattern Music_PlayPattern, clear
it to 0 at WAV_LeavePostImport so normal F5/F6 playback still loops. One pass, stop,
finalize. (Commit 4041e66.)

## Deploy
- Built IT.EXE in DOSBox-X (IT_MUSIC.asm Error/Warning = None; relinked 478015 bytes).
- Deployed to `/Volumes/netdrive/ITNU2026/IT.EXE` (byte-identical to the build); old
  binary preserved as `IT_PREV.EXE`. ITWAV.DRV left as-is (unchanged by the fix).
- NOT runtime/HW-tested by me — the reboot+hang only manifest on Esa's DOS hardware
  with live audio, and driving IT's interactive render headlessly isn't reliable.
  Graded @build-verified / @runtime-untested / @hw-untested. Esa tests on the metal.

## On-hardware test protocol (for Esa)
1. Empty order list + F6 playing + Ctrl-O  -> must NOT reboot (was BUG 1).
2. One pattern 000, cursor on order list, right-arrow  -> must render once, no hang (BUG 2).
3. Shift-right at the order-list edge  -> WAV lands in the Quicksave folder, no import.
4. Plain Ctrl-O in the pattern editor  -> WAV renders AND auto-imports as next sample.
5. After any render, press F5/F6  -> normal looping playback (terminator didn't leak).
   If anything still wedges, the row-0 debug markers + CTRLOLOG.TXT show how far it got.

## Back-and-forth debug logging + deploy runbook (follow-up)
Esa asked to (a) fold the build+deploy handoff into the skill and (b) "enable some
sort of back&forth debug logging." Findings + actions:
- The render dir = Quicksave folder = `E:\ITNU2026` (from IT.CFG.perfect), which the
  Mac sees at `/Volumes/netdrive/ITNU2026`. CTRLOLOG.TXT already lands there =>
  the back&forth channel already existed; the reboot/hang just killed it before flush.
- Added `WAV_LogState` (IT_MUSIC.ASM): a self-contained CTRLOLOG appender emitting an
  `E` (enter/inputs) and `X` (sync-exit/outcome) line per render — pat, pm, sm, mm,
  o0 (OrderList[0], 00FF=empty), se (StopEndOfPlaySection, 0001=terminator armed),
  it (sync iters left, 0000=hit cap=hung). Reuses WAV_WriteStringDSSI / WAV_WriteHexAX.
- Runbook saved as `DEPLOY-TO-XP.md`; SKILL.md got a "Deploy to netdrive/ITNU2026"
  section (target/mount, fast IT.EXE rebuild conf, minimal deploy, IT.CFG.perfect,
  how to read CTRLOLOG `E`/`X` lines). IT.EXE 478223 deployed; perfect IT.CFG deployed.
- Still @build-verified only. Next data point comes from Esa's CTRLOLOG.TXT after a repro.

## How to get back
- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/3471aca0-a5df-4b96-82d0-78eafb943199.jsonl
- Session id: `3471aca0-a5df-4b96-82d0-78eafb943199`
- Resume: `claude --resume 3471aca0-a5df-4b96-82d0-78eafb943199`
- Date: 2026-06-23
- Innards: IT_MUSIC.ASM Music_GetPattern guard (~3504); StopEndOfPlaySection set/clear in Music_ToggleWAVRender; leak source Music_PlayPartSong (~9402)
- RESULT: 128ab04 (reboot guard) + 4041e66 (hang terminator); deployed to netdrive/ITNU2026
