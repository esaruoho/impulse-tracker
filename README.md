# Impulse Tracker — esaruoho fork (v2.354)

> Active fork of [jthlim/impulse-tracker](https://github.com/jthlim/impulse-tracker).
> Upstream is read-only ("no active development, and changes/fixes will not be
> merged other than issues preventing build"). New features land here on
> [esaruoho/impulse-tracker](https://github.com/esaruoho/impulse-tracker).
> Current version: **2.354** — `(C) 1995-2000 Jeffrey Lim, (C) 2026 Esa Juhani Ruoho`.
> See [Changelog](#changelog) for week-by-week history and [Fork Changes](#fork-changes-v2354) for the v2.354 feature set.

Full source code for Impulse Tracker, including sound drivers, network drivers,
and some supporting documentation

This was originally released on BitBucket in 2014 alongside an article series
titled "20 years of Impulse Tracker", but BitBucket sunset mercurial
repositories, and so this is now made available on GitHub.

- [First Article](https://roartindon.blogspot.com/2014/02/20-years-of-impulse-tracker.html)
- [Second Article](https://roartindon.blogspot.com/2014/03/20-years-of-impulse-tracker-part-2.html)
- [Third Article](https://roartindon.blogspot.com/2014/10/20-years-of-impulse-tracker-part-3.html)
- [Fourth Article](https://roartindon.blogspot.com/2014/12/20-years-of-impulse-tracker-part-4.html)

Note that this repository is purely sharing what used to be -- there is no
active development, and changes/fixes will not be merged other than issues
preventing build.

## Changelog

Newest first. Five weeks of active development since the fork resumed on 2026-04-22. Commit hashes link to the fork's `main` branch.

### 2026-05-18 — Playback-safe sample reload, dual MIDI toggles, envelope dataloss fix

- **`f10e961`** — Envelope preset save accepts Shift-1..Shift-9 (the original Alt-1..Alt-0 still works). Load with 0..9 in the envelope edit screen. Presets persist in `IT.CFG` automatically. The feature was already wired up in upstream (`ENABLEPRESETENVELOPES=1`); only the modifier was widened.
- **`4e4eb9a`** — Sample→Instrument mode-switch prompt ("Initialise instruments?") now defaults focus to **No**, so accidental Enter no longer wipes envelopes via `Music_ClearAllInstruments`. OK is still one Tab away if you actually want to re-init.
- **`731e168`** — **MIDI Transport (FA/FB/FC)** toggle added on Shift-F1 alongside the existing **MIDI Sync (F8 Clock)** toggle. Independent gates: turn off transport response while keeping tempo sync, or vice versa. Solves Logic 5.5.1's clock jitter making IT fluctuate 121-136 BPM around a 125 BPM target.
- **`a44c41b`** — New `Music_SilenceSampleVoices Far` proc in `IT_MUSIC.ASM`. Loading a sample (Enter on the sample list, or keyjazz preview inside the F9 file browser) no longer brute-stops the whole song — it silences only the slave channels currently reading the target slot. Mixer's `Word Ptr [SI] = 200h` sentinel is documented and reused; the same primitive is folded into `Music_ReleaseSample` for safety.
- **`16d89da`**, **`e3e6940`** — `CLAUDE.md` gains a User-Facing Keyboard Reference table grounded in `IT.TXT` line numbers, and a Mixer & Slave Channel Layout section drawn from `SoundDrivers/MIX.INC` and `IT_MUSIC.ASM`. Future contributors stop guessing offsets and key bindings.

### 2026-05-13 — Release workflow

GitHub Actions release pipeline that produces a DOS-installable ZIP on dispatch.

- **`2eb6088`** default version 2.354 + overwrite-existing-release behaviour.
- **`e4fafa6`** simplify dispatch UI to a single version input.
- **`400ea5b`** fix `.DRV.DRV` double-extension when source extension was uppercase.
- **`c599007`** swap in TLINK 3.01 at runtime (the GitHub-runner toolchain ships TLINK 7.1).
- **`fe1df01`** dump diagnostics + upload logs on driver-build failure.
- **`141893b`** handle lowercase `.drv` / `.net` artifacts from DOSBox-X on Linux.
- **`62e6991`** replace heredoc with echo block to fix YAML indent.
- **`8d80eff`** initial `release.yml` — DOS-installable zip workflow.

### 2026-05-12 — Alt-R Replicate at Cursor (Paketti port), F3 loader hang fix

- **`0afd402`** — `SKILL.md`: architectural reference companion to `CLAUDE.md`, lives at `~/.claude/skills/impulse-tracker/`.
- **`aaada5e`** — Alt-R row-0 boundary: when cursor is at row 0, tile row 0 down the whole pattern instead of no-op. **Shift-Alt-R** now hosts the original Alt-R "Clear all track views" behaviour via runtime modifier disambiguation through `K_IsKeyDown`.
- **`d506486`** — **Alt-R = Replicate at Cursor** in the pattern editor. Port of the Paketti / zTrackerPrime feature: takes rows `0..cursor-1` as the source chunk and tiles them down to `MaxRow`. Mirror semantics (empty events copy verbatim). Undo slot 23. Networked to peers via `NetworkPatternBlock`.
- **`64fa1ce`** — F3 loader keyjazz hard hang fixed. `MIDISend`'s FA/FB/FC callbacks are suppressed during `LoadSample → Music_PlaySample` via the new `MIDISyncLoaderSuppress` flag, set/cleared by Far helpers from `IT_DISK.ASM`. Closes the race where an external clock's MIDI Start, buffered during `Music_Stop`'s Cli window, would re-enter playback mid-sample-load and trash EMS pointers.
- **`ec91331`** — Loader keyjazz path instrumented with VRAM markers (`D_DebugMark` cols 30-39) before the targeted fix. Markers stay in tree.

### 2026-05-04 — MIDI sync hardening, monitor, driver fixes

- **`3537c0d`** — Ctrl-O WAV leave/import paths instrumented with VRAM markers (`WAV_DebugMark` cols 1-28). Establishes the standard hard-hang triage primitive.
- **`78fb72d`**, **`4ebf849`** — All 16 sound drivers with MIDI-in (`GUSMIXDR`, `IWDRV`, `SB16*`, `AWE32*`, `ES1868`, etc.) stop filtering MIDI System Real-Time bytes (`F8-FF`). The pre-fork filter dropped every byte ≥ `0xF0` intending to skip SysEx, but caught Start/Stop/Continue/Clock too. The pure `MIDIDRV.ASM` was always clean.
- **`95f628a`** — Shift-F1 MIDI screen now shows live RT-byte counters (Start / Continue / Stop / Clock + last-RT-byte and DOS-tick of last RT message). Diagnostic for "are bytes even arriving."
- **`7163709`** — MIDI Sync toggle moved from Alt-F12 to a Shift-F1 button. Alt-F12 collided with the F5 spectrum analyzer.
- **`8ca7078`** — F12 Module Directory field's Enter now opens F9 as a directory picker (sets a transient flag so the save handler returns the picked dir instead of loading the highlighted file).
- **`8f11aa6`** — F12 directory inputs translate `/` to `\` so muscle-memory Unix slashes don't break.
- **`ad5d840`** — MIDI Sync now default ON. Alt-F12 hotkey added (later moved to Shift-F1 button).
- **`2051b90`** — README documents the v2.354 feature set (MIDI sync, P3 render, quicksave, build infra).
- **`7df9edf`** — Tracker version bumped to **2354h**. Esa Juhani Ruoho 2026 copyright line added.
- **`34b725d`** — `.gitignore` covers `CACHE.ITS` and rendered `004_*.001` sample dumps so working trees stay clean.

### 2026-05-01 — Pattern-to-Sample (P3), quicksave, F4↔F3, MIDI clock tempo sync

The bulk of the feature work. P3 in particular went through ~20 iterations in a single day.

- **`7fd1abc`** — F12 config screen: Quicksave directory input row.
- **`6464e15`** — Quicksave folder: **Alt-W** saves there, **Shift-Alt-W** memorizes target.
- **`0c02662`**, **`d13a849`**, **`81c78aa`**, **`9bd18d1`**, **`64b853b`**, **`bb5e5ea`**, **`09d7e7d`**, **`f136a7b`**, **`e3f5815`**, **`b0690a4`**, **`ce3fb79`**, **`3a626b4`**, **`4d5e9da`**, **`9ed42ed`**, **`1d7910e`** — P3 ("Pattern-to-Sample") hardening pass: 1 MB safety cap, configurable loop-on-render, IMPS filename field, cwd reentrancy gate, WAV validation, unique `REN<NNN>.<PPP>` filenames, target-slot calculation, alloc-fail cleanup, granular failure messages, page-counter / off-by-one fixes, auto-select imported sample, status-message timing.
- **`af03f96`** — Ctrl-O auto-imports the rendered pattern as a new sample.
- **`089119a`** — Ctrl-O toggles the active driver to `ITWAV.DRV` to do the render (P2a).
- **`35732c3`** — Ctrl-O renders current pattern, phase 1 (no auto-import yet).
- **`e4c9b4a`** — P2/P3 deep-dive findings document.
- **`fc92c77`** — `.gitattributes` locks `*.ASM` / `*.INC` to ISO-8859-1 + CRLF so modern editors don't UTF-8-mangle the CP437 box-drawing characters.
- **`0a82cb3`**, **`03b0a6d`** — MIDI Clock 0xF8 external tempo sync (24 PPQ → DOS-tick-delta → BPM). Default off; sanity-filtered against absurd deltas.
- **`9d626b0`**, **`672273b`** — F4 → F3 cursor translation. Pressing F3 from the instrument list jumps the sample cursor to the sample bound to the currently-highlighted instrument (note 60 first, then scan all notes), with bounds checks.
- **`1b2bcf1`** — Skip-stubs for 13 sound-driver build batches that need TASM32 or have missing sources.

### 2026-04-30 — TLINK 3.01 unlock + first Ctrl-O render

- **`be79b3c`** — TLINK 3.01 unlock. The `zajo/TASM` mirror ships TLINK 7.1, which rejects every sound driver with `Fatal: No program entry point`. Dropping in TLINK 3.01 (1990) builds all 42 drivers + `IT.EXE` + `ITIPX.NET` in ~57 seconds inside DOSBox-X.
- **`5bd73ed`** — `CLAUDE.md`, `BUILDALL.BAT`, and `buildall.conf.sample` for one-shot full rebuilds on a modern Mac.

### 2026-04-22 / 04-23 — CI + the original MIDI Start/Stop intercept

- **`1fa031c`** — GitHub Actions workflow: build `IT.EXE` and all drivers via DOSBox-X under xvfb on every push/PR, with TASM/TLINK/MAKE reassembled from 13 base64 secrets.
- **`ec42bd1`** — Seed commit. `IT_K.ASM` `MIDISend` intercepts `0xFA` (Start) and `0xFC` (Stop) System Real-Time bytes, routing them to `Music_PlaySong` / `Music_Stop`. Every sound driver with a MIDI-in hook gains transport sync at the single host-side intercept point. Everything else in this changelog grew from this one proc.
- **`aa311f5`** — `.gitignore` for macOS `.DS_Store` files.

## Pre-Requisite Software

To build Impulse Tracker, you will need:

- Turbo Assembler v4.1

- Turbo Link v3.01

- Borland MAKE v4.0

- A DOS environment

Once you have these, building IT.EXE should be just a single call to `MAKE`

Sound drivers are build individually via M\*.BAT files inside the SoundDrivers
subdirectory

## Building on macOS / Linux (esaruoho fork)

This fork (`esaruoho/impulse-tracker`) builds `IT.EXE` **and all 42+ drivers**
cross-platform via DOSBox-X. The required Borland binaries are not
redistributable, but two public GitHub mirrors cover the toolchain:

- **TASM 4.1 + Borland MAKE 4.0** from [zajo/TASM](https://github.com/zajo/TASM).
  The 16-bit DPMI variant `TASMX.EXE` is required for `IT_MDATA.asm` (the stock
  `TASM.EXE` runs out of memory on its large data tables); rename `TASMX.EXE`
  to `TASM.EXE` in your toolchain directory.
- **TLINK 3.01** from [nolanvenhola/zeliard2026](https://github.com/nolanvenhola/zeliard2026)
  at `3_Assembly/tasm/tool/tasm201/TLINK.EXE` (53,510 bytes, 1990 Borland).
  Skip the TLINK 7.1 that ships with `zajo/TASM` — it rejects driver objects
  with `Fatal: No program entry point`. TLINK 3.x links both `IT.EXE` and every
  driver without modification. (Alternate source:
  [darkhani/kstools](https://github.com/darkhani/kstools).)

Drop both into `tools-local/` (gitignored) and run `BUILDALL.BAT` from the repo
root inside DOSBox-X. The `buildall.conf.sample` file ships a working DOSBox-X
config — copy it to `buildall.conf` (also gitignored), then:

```
dosbox-x -conf buildall.conf -fastlaunch -exit -nogui -nomenu
```

Total wall time: ~57 seconds on an M1 Mac. Outputs: `IT.EXE` (462 KB), 42
sound drivers (`IT*.DRV`), `ITIPX.NET`, plus `MAKE.LOG`, `DRV_SND.LOG`,
`DRV_NET.LOG`.

See [CLAUDE.md](CLAUDE.md) for full architecture / patch / contribution
documentation.

GitHub Actions CI: see `.github/workflows/build.yml`. Requires the toolchain
to be uploaded as 13 base64-chunked repo secrets `TASM_TOOLCHAIN_B64_01`
through `TASM_TOOLCHAIN_B64_13` (single-secret 48 KB limit forces chunking).
Bundle TASM, TASMX (renamed to TASM), MAKE, **and TLINK 3.01** into the ZIP.

## Fork Changes (v2.354)

Why fork at all: Impulse Tracker 2.15 (the last upstream release) is a beautifully
finished DOS tracker, but it's MIDI-out-only (no external sync), it can't render
its own patterns to disk as samples for resampling/chopping, and a few
modern-workflow conveniences (quick-save folder, F4↔F3 cursor parity) are
missing. This fork adds those without changing the on-disk `.IT` file format.

The version field embedded in saved `.IT` files (`SWITCH.INC` →
`TRACKERVERSION`) is **2354h**, distinguishing files written by this build from
upstream-2.15 (`0215h`) and from the prior fork interim (`217h`).

### MIDI sync from external clocks (Features 1 + 4)

Upstream IT consumes MIDI input only for live note entry into the pattern
editor. This fork intercepts MIDI System Real-Time messages (`0xF8`/`0xFA`/
`0xFB`/`0xFC`) at the single host-side `MIDISend` proc in `IT_K.ASM`, so
**every sound driver with a MIDI-in hook gains sync without driver
modifications** (Sound Blaster 16's MPU-401 UART, the dedicated MPU-401
driver, etc.).

- `0xFA` MIDI Start  → `Music_PlaySong` from order 0
- `0xFB` MIDI Continue → resumes from current position
- `0xFC` MIDI Stop  → `Music_Stop`
- `0xF8` MIDI Clock (24 ppq) → external tempo sync with delta-time sanity
  filtering. Off by default; enable via the config flag described in
  `IT_MUSIC.ASM`.

`MIDISend` runs in main-loop context (drivers buffer the IRQ-time bytes), so
calling playback procs directly from the intercept is safe.

### Pattern-to-Sample render (Feature 3, "P3")

Upstream renders only via the explicit "Save WAV" disk-writer driver workflow
(switch sound card → render full song → switch back). This fork adds in-place
pattern rendering bound to **Ctrl-O** in the pattern editor:

1. Ctrl-O switches the active sound driver to `ITWAV.DRV`, plays the current
   pattern once (or loops, configurable), and writes a WAV.
2. Render output goes to the user's `SampleDirectory` with a unique
   `REN<NNN>.<PPP>` filename (no overwrites of prior renders).
3. The rendered sample is auto-imported into the next free slot — computed as
   `max(highest sample, highest instrument) + 1` — and the cursor lands on it
   so the next Enter plays it back.
4. Hardening: cwd reentrancy gate, WAV header validation, 1 MB safety cap with
   user warning + length adjust, alloc-fail clears the dirty slot, IMPS
   filename field (+4..+15) populated with the rendered `.NNN`.

### Quick-save folder (Alt-W / Shift-Alt-W + F12 row)

- **Shift-Alt-W** — memorize the current load/save directory as the "Quicksave
  folder."
- **Alt-W** — save the current module to that folder, no prompt, using the
  module's existing filename.
- **F12 config screen** — Quicksave directory is now an editable input row,
  persisted across sessions.

### F4 → F3 cursor translation (Feature 2)

Pressing **F3** from the instrument list (F4) now jumps the sample-list cursor
to the sample bound to the currently-highlighted instrument (note 60 first,
falling back to a scan of all notes), instead of resetting to sample 1.

### Build / CI infrastructure

- **TLINK 3.01 unlock** — drivers refused to link with the modern TLINK 7.1
  shipped by `zajo/TASM` (`Fatal: No program entry point`); switching to
  TLINK 3.01 (1990) builds all 42 drivers + IT.EXE + ITIPX.NET in ~57 s.
- **`BUILDALL.BAT`** at the repo root invokes the main `MAKEFILE.MAK` plus the
  per-subdirectory `BUILDALL.BAT`s under `SoundDrivers/` and `Network/` for a
  one-shot full rebuild.
- **`buildall.conf.sample`** — DOSBox-X config that mounts the repo and
  `tools-local/`, runs `BUILDALL.BAT`, and exits. One-line full-rebuild on
  a modern Mac.
- **GitHub Actions CI** (`.github/workflows/build.yml`) — builds everything on
  push/PR via DOSBox-X under xvfb, with the toolchain reassembled from 13
  base64-chunked repo secrets.
- **`.gitattributes`** locks `*.ASM`/`*.INC` working-tree-encoding to
  ISO-8859-1 + CRLF so modern editors don't UTF-8-mangle the CP437
  box-drawing characters in the original Borland-era source comments.

## Quick File Overview

- IT.ASM:
  Startup routines
- IT_DISK.ASM:
  Disk IO Routines. Uses IT_D\_\*.INC files

- IT_DISPL.ASM:
  Display routines for the Playback Screen (F5)

- IT_EMS.ASM:
  EMS memory handling routines

- IT_F.ASM:
  Collection of functions used by the object model

- IT_FOUR.ASM:
  Fast Fourier routines. Used by the graphic equalizer (Alt-F12).
  Not available on all all sound cards

- IT_G.ASM:
  Global key handler functions

- IT_H.ASM:
  Help Module (F1)

- IT_I.ASM:
  Sample list (F3) and Instrument list (F4) module

- IT_K.ASM:
  Keyboard module

- IT_L.ASM:
  Information line code

- IT_M.ASM:
  Main message loop/dispatcher

- IT_MDATA.ASM:
  Global music variable data

- IT_MMTSR.ASM:
  Sample compression/decompression routines

- IT_MOUSE.ASM:
  Mouse handling code

- IT_MSG.ASM:
  Message editor module (Shift-F9)

- IT_MUSIC.ASM:
  Module playback code. Also uses IT_M_EFF.INC

- IT_NET.ASM:
  Network code

- IT_OBJ1.ASM:
  UI object definitions

- IT_PE.ASM:
  Pattern Editor module (F2)

- IT_S.ASM:
  Screen functions, including character generation

- IT_TUTE.ASM:
  Interactive Tutorial module

- IT_VESA.ASM:
  VESA code for graphic equalizer

- SWITCH.INC:
  High level switches for the program

## Frequently Asked Questions

Q: "What are all those funny characters in the source code?"

A: I wrote the original source code using DOS characters, with characters drawing borders/boxes in
comments in the source code. In the interests of posterity, I have left the code intact as it was.

Q: "Why didn't you use STRUCs or ENUMs" in your ASM source?

A: Simply because I didn't know about them at the time. I wish I did. There's a InternalDocumentation
folder that I've included in the repository that details what some of the magic numbers appearing
through the code might mean.

Q: "Flow in some functions seems to jump all over the place. Why?"

A: The original code was compatible all the way back to an 8086 machine. 8086 would allow you to do
conditional jumps only within +/-128 bytes, so I spent too much time shuffling code around to meet
this restriction. When I shifted away from this 8086 restriction, I never went back to update the
code that was mutilated by it.

## License

BSD 3-clause license can be found in [LICENSE](LICENSE).
