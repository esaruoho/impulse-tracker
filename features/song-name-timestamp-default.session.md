# Session — Blank song name defaults to a creation timestamp

The vibe record (second leg of the triad) for
`features/song-name-timestamp-default.feature`. Faithful, not flattering.

## The request

Esa handed me a Gherkin sketch as the spec:

> Feature: Song has a Timestamped name by default
> Given that ImpulseTracker is started
> And no song is loaded
> When the user sees the Song Name
> Then it is shown as Timestamp (2006-06-04 15:07) automatically
> So the user does not need to see the time and date to be able to save the
> time into the song.

The "2006" in the example was a typo for the current year (2026-06-04). The
intent is unambiguous: a fresh, unnamed song should already carry the moment it
was started, so the date/time is *saved into the song* without the user looking
anything up.

## What I found before touching code (Explore pass)

- **Song Name lives at `SongData:4`**, 26 bytes max. The F12 SongNameInput
  object (IT_OBJ1.ASM ~5502) is a 26-byte text input bound to song-seg offset 4.
- **The boot song is always blank.** IT_MDATA.ASM defines the static SongData
  segment as `"IMPM", 36 Dup(0)` — name bytes are zero at startup. I grepped
  IT.ASM for any command-line module load (`LoadModule`, `CommandTail`, argv-style
  parsing) and found **none** — IT always boots into the blank default song. So
  stamping at startup never races a loaded name.
- **DOS date/time is already read** in IT_DISK.ASM `D_InitDiskNoCDROM` via
  `Int 21h AH=2Ah` (date) and `AH=2Ch` (time) — but only to pack a cache
  timestamp into `Date`/`Time` words. I re-read the clock in my own proc rather
  than depend on that packed format (it's lossy and far away in another module).
- **No reusable "number → 2 ASCII digits" helper** exists; the codebase does
  inline `Div` + `Add AL,'0'`. The WAV render basename builder
  (IT_MUSIC.ASM ~5809) is the nearest prior art. I matched that idiom.
- **Cross-module call mechanism**: defining module does `Global X:Far`, consumer
  does `Extrn X:Far` inside its segment. IT.ASM's Main segment has the Extrn
  block; IT_F.ASM has the F_* Global block.

## Decisions

- **Where the proc lives**: IT_F.ASM, right after `F_NewSong`. F_NewSong already
  `Extrn`s `Music_GetSongSegment` and is *the* place that blanks the song name —
  so the new proc sits next to its sibling and reuses the same segment accessor.
- **Format "YYYY-MM-DD HH:MM"** (16 chars): sortable (ISO-ish), zero-padded,
  fixed width, leaves 10 of 26 bytes free to append a real title. I dropped
  seconds — minute resolution is plenty for "when did I start this", and it keeps
  the string short.
- **Self-guarding on a blank first byte** (`Cmp Byte Ptr [ES:4],0 / JNE done`).
  The feature is "no song is loaded", but making the proc *only* stamp a blank
  name means it's safe to call from anywhere and forward-compatible if a
  command-line load is ever added — a loaded name is never clobbered.
- **Two call sites, both "fresh blank song" moments**:
  1. IT.ASM startup, after `Music_AutoDetectSoundCard`, before the main loop —
     the boot song.
  2. IT_F.ASM `F_NewSong`, immediately after the "Clear song name" `Rep StosW`
     loop — so making a new song re-stamps with the *new* time instead of
     leaving it blank. Same user intent, same value.

## The register dance (the one fiddly part)

`Int 21h AH=2Ah` returns CX=year, DH=month, DL=day. `AH=2Ch` returns CH=hour,
CL=minute (DH=second, unused). The time call clobbers CX and DX, so:

- Read date first, `Push DX` to preserve month/day across the year formatting.
- Year is a *word* (e.g. 2026): `Div BX` by 1000 then 100 (word division, must
  `Xor DX,DX` first since DIV is DX:AX/BX), then the last two digits via 8-bit
  `Div BL` by 10. Two-digit fields (month/day/hour/min) are all `Div BL` by 10,
  then `Add AX,3030h` to ASCII-ify both nibbles at once and `StosW` (AL=tens at
  the low address, AH=units — correct left-to-right order).
- `Push DX` again between month and day because the first `Pop` consumes it.
- Time: `Push CX` to hold hour+minute across the hour formatting.

## Build

DOSBox-X, `make -f MAKEFILE.MAK` only (the change is IT.EXE-side; no driver
touched). Both files: `Error messages: None / Warning messages: None`. TLINK 3.01
linked `IT.EXE` (477,662 bytes). No undefined/unresolved externals — the
Global/Extrn wiring for `F_SetTimestampSongName` resolved.

## Honest grades

- `@build-verified` is real: clean assemble + link in DOSBox-X.
- Everything is `@runtime-untested` and `@hw-untested`. I did **not** launch
  IT.EXE and read the F12 Song Name, and nothing ran on real DOS metal. The
  logic is verified by reading + a clean build only. Flip to `@runtime-verified`
  only after watching a booted IT.EXE show the timestamp on the F12 screen.

## Possible follow-ups (not done)

- The `F_NewSong` stamp only fires on the branch that resets the song message /
  name (gated on `ButtonVariables+12`); other New Song option combinations that
  don't clear the name keep whatever was there — intentional (blank-guard).
- Could offer the same default to the WAV render basename so unnamed-song
  renders inherit the timestamp prefix. Out of scope here.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/2f145369-14b0-48b7-b4cb-1d15255dfcad.jsonl
- Session ID: `2f145369-14b0-48b7-b4cb-1d15255dfcad`
- Resume: `claude --resume 2f145369-14b0-48b7-b4cb-1d15255dfcad`
- Session timestamp: 2026-06-04 ~15:14 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work/impulse-tracker (repo root)

## Cross-links

- Spec leg: `features/song-name-timestamp-default.feature`
- The F12 screen that shows/edits the name: `features/f12-song-variables.feature`
- Feature commit: `87ad1dd`
