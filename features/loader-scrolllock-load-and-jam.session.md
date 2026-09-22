# Session — loader-scrolllock-load-and-jam

Faithful, not flattering. Vibe-diff for `loader-scrolllock-load-and-jam.feature`.

## How to get back
- Repo: /Users/esaruoho/work/impulse-tracker · Date: 2026-09-22
- Resume: `claude --resume <id>`

## The request
Esa: "if i'm on a sample in loadsample, and i press scroll lock. that means, load
the sample, create the instrument, select the instrument, go to the pattern editor
and start jamming. we can do this."

## Context (came right after a mistake)
Immediately prior I broke loader keyjazz by driving a waveform preview through the
full LoadSample on cursor moves; reverted. So this feature was built to be
CONTAINED: a NEW key (Scroll Lock, 146h) that does not modify keyjazz, Enter, or the
cursor keys -- worst case it misfires on Scroll Lock alone.

## The window
The sample-view window is the `ViewSampleWindow` object, post handler
`D_PostViewSampleLibrary` (IT_DISK.ASM:6406), which dispatches `LSViewWindowKeys`
and falls through to the keyjazz handler (D_PostLoadSampleWindow1). So browsing +
jamming both live here -- the right place for the key.

## Building blocks reused (no new mechanism invented)
- Load sample into song: same setup as LSWindow_EnterSample (DS:SI = 96*CurrentSample
  in DiskDataArea, CheckDataArea+2Eh fixup, Music_ReleaseSample(99), PE_GetLastInstrument
  -> LoadSample).
- Force Instrument mode: `Or Byte Ptr [songseg:2Ch], 4` (the exact idiom Glbl_Shift_F4
  uses; bit 2 = instrument-mode flag).
- Make + select instrument: the proven WAV-auto-import block -- PE_GetLastInstrument
  (BX 0-based) -> Music_AssignSampleToInstrument (AX = inst num, CF on fail) ->
  D_SetCurrentInstrument (AX) -> PE_SetLastInstrument.
- Enter editor + Follow: tail-jump PE_ScrollLockFollow (the same handler F3/F4 Scroll
  Lock / Ctrl-F use; ends in Glbl_F2, Far Ret hands AX=5 back to the framework).

New Extrns in IT_DISK: PE_ScrollLockFollow, PE_SetLastInstrument.

## Dispatch-precedence check (the one real risk)
146h is ALSO bound globally to PE_ScrollLockFollow in GlobalKeyList. If GlobalKeyList
were consulted before the window's object post handler, my window binding would be
shadowed and Scroll Lock would just jump to the editor WITHOUT loading. Evidence says
the object post handler wins (keyjazz notes are handled there and work; the F3/F4
comment says 146h was per-list first, "also global" as fallback). If HW test shows
Scroll Lock jumps to the editor but does NOT load the sample, that's the shadow --
fix by binding 146h so the window handler is reached first. Failure mode is benign
(no crash, no keyjazz impact).

## Grade
`@build-verified` -- TASM assembles IT_DISK.asm Error/Warning None; TLINK links
IT.EXE (482824 bytes), both new Extrns resolve. `@runtime-untested @hw-untested`
until Esa confirms on the DOS box: Scroll Lock on a sample loads it, makes+selects
an instrument, and lands in the Pattern Editor with Follow on, ready to jam.

## Follow-up (same day): Scroll Lock became a loader<->editor ping-pong
Esa: "if i was in sample load mode, and i ran scroll lock, and i input some notes,
the scroll lock pressing again will bring me back to sample load mode but on a free
slot." So the Pause/PrintScreen idea was dropped -- Scroll Lock itself round-trips.

Design:
- LSViewWindow_ScrollLock now calls PE_ArmScrollLockRoundTrip before entering the
  editor. No immediate bounce: CurrentMode is still 13 (loader) when
  PE_ScrollLockFollow runs, so it takes the enter-editor path, not the editor branch.
- PE_ScrollLockFollow editor branch (CurrentMode==2) now: if armed -> consume the
  flag, advance the loader destination to the next free slot
  (max(Music_GetNumberOfSamples, Music_GetNumberOfInstruments)+1, cap 99) via
  PE_SetLastInstrument, then Jmp Glbl_LoadSample. If NOT armed -> the original
  Follow-mode toggle, unchanged. Ctrl-F still toggles Follow either way.
- Flag ScrollLockRoundTrip is a CS-relative byte in the Pattern segment; the loader
  arms it through the small Far setter PE_ArmScrollLockRoundTrip (avoids cross-
  segment variable addressing).

Known v1 limit: if you arrive via loader Scroll Lock, then do other work in the
editor and press Scroll Lock expecting a Follow toggle, you'll round-trip instead
(the flag is still armed). Ctrl-F is the always-Follow escape hatch. Build-verified
(IT.EXE 483435); HW-untested.
