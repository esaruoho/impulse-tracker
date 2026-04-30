# CLAUDE.md — Impulse Tracker (esaruoho fork) Development Guide

> Fork of [jthlim/impulse-tracker](https://github.com/jthlim/impulse-tracker) at [esaruoho/impulse-tracker](https://github.com/esaruoho/impulse-tracker). Upstream is read-only ("no active development, and changes/fixes will not be merged other than issues preventing build" — README). Feature work happens on this fork.

This file is a development guide for both human contributors and AI coding assistants working in this repository. It covers how to build `IT.EXE` and the sound drivers locally, the source-tree layout, the MIDI input architecture (including the MIDI System Real-Time start/stop sync added in this fork), and the contribution workflow.

## Repository Overview

Full Impulse Tracker 2.15 source, BSD-3-Clause. Originally released 2014 on Bitbucket alongside Jeffrey Lim's "20 Years of Impulse Tracker" blog series. TASM 4.1 / TLINK 3.01 / Borland MAKE 4.0 + DOS target. 16-bit real-mode segmented assembly with 386 extensions (`.386P`). Builds `IT.EXE` plus a set of `.DRV` sound drivers loaded at runtime.

## Toolchain (from README + MAKEFILE.MAK)

- Turbo Assembler v4.1 (`TASM /m /uT310 /jSMART`)
- **Turbo Link v3.01** — links both `IT.EXE` and every driver
- Borland MAKE v4.0
- DOS (or DOSBox-X / vDosPlus / real hardware)

**Critical: TLINK 3.x, not 7.1.** The public [`zajo/TASM`](https://github.com/zajo/TASM) mirror ships TLINK 7.1, which links `IT.EXE` fine but **rejects every driver** with `Fatal: No program entry point` — driver objects don't declare an entry point because `EXECOM.COM` strips the EXE header at conversion time, and TLINK 7.1 (1996) treats this as fatal where TLINK 3.x (1990) only warned. Use TLINK 3.x and everything builds.

**Public TLINK 3.01 source.** [`nolanvenhola/zeliard2026`](https://github.com/nolanvenhola/zeliard2026) at `3_Assembly/tasm/tool/tasm201/TLINK.EXE` — 53,510 bytes, banner "Turbo Link Version 3.01 Copyright (c) 1987, 1990 Borland International". A second copy lives at [`darkhani/kstools`](https://github.com/darkhani/kstools) (`TLINK.EXE`, 53,414 bytes). Drop either into `tools-local/` (overwriting any TLINK 7.1 from `zajo/TASM`).

**TASMX rename trick.** `IT_MDATA.ASM` has data tables large enough to exhaust real-mode `TASM.EXE`. The 16-bit DPMI variant `TASMX.EXE` (in `zajo/TASM`) handles it. Convention: **rename `TASMX.EXE` to `TASM.EXE`** so the unmodified `MAKEFILE.MAK` (`TASM /m /uT310 /jSMART $*.asm`) picks up the DPMI build.

**Public TASM 4.1 source.** [`zajo/TASM`](https://github.com/zajo/TASM) ships TASM 4.1, TASMX, and Borland MAKE 4.0. Skip its TLINK 7.1 in favour of TLINK 3.01 from the source above.

**Verified build time.** Full `IT.EXE` + 42 sound drivers + 1 network driver = **~57 seconds** in DOSBox-X (`cycles=max`, M1 Mac).

`source.lst` is the link response file consumed by TLINK — do **not** add it to `.gitignore`; the existing `.gitignore` explicitly unignores it.

## Repository Structure

```
impulse-tracker/
├── IT.ASM               — startup
├── IT_M.ASM             — main message loop / dispatcher
├── IT_MUSIC.ASM         — playback engine, driver interface, internal MIDI macros (Zxx/SFx)
├── IT_MDATA.ASM         — global music variable data
├── IT_K.ASM             — keyboard + MIDI INPUT parser (MIDISend / MIDIBufferEmpty)
├── IT_DISPL.ASM         — F5 playback screen
├── IT_DISK.ASM          — disk I/O (+ IT_D_*.INC per-format include files)
├── IT_F.ASM / IT_G.ASM  — object-model helpers / global keys
├── IT_H.ASM             — F1 help
├── IT_I.ASM             — F3 sample list / F4 instrument list
├── IT_L.ASM             — info line
├── IT_MMTSR.ASM         — sample compression
├── IT_MOUSE.ASM         — mouse
├── IT_EMS.ASM           — EMS memory
├── IT_VESA.ASM          — VESA graphics
├── IT_FOUR.ASM          — FFT for Alt-F12 EQ
├── IT_TUTE.ASM          — tutorial
├── IT_NET.ASM           — network module
├── IT_OBJ1.ASM          — object system
├── IT_PE.ASM            — pattern editor
├── IT_S.ASM             — settings/screen helper
├── MAKEFILE.MAK
├── source.lst           — TLINK response file
├── SoundDrivers/        — individual driver sources, each built via M*.BAT
│   ├── MIDIDRV.ASM      — MPU-401 MIDI-only driver (the one that accepts MIDI input)
│   ├── SB16DRV.ASM, GUS*, ES*, AWE32*, GOLD16, etc.
│   └── REQPROC.INC      — IT↔driver procedure table (UARTSend, UARTBufferEmpty, Update, ...)
├── Network/             — network driver sources
├── Tutorial/ VSound/ Keyboard/
├── ReleaseDocumentation/  (IT.TXT, MIDI.TXT, ITTECH.TXT, ...)
└── InternalDocumentation/ (CHANNEL/CONFIG/MMTECH/NETWORK/OBJECT.TXT)
```

## Building `IT.EXE` Locally

There are three realistic paths. Option A is the recommended one for active development on a modern host.

### Option A — DOSBox-X with TASM/TLINK/MAKE inside DOS (recommended)

1. Install DOSBox-X: `brew install dosbox-x` (macOS) or `apt-get install dosbox-x` (Debian/Ubuntu).
2. Obtain Turbo Assembler 4.1, Turbo Linker 3.01, and Borland MAKE 4.0. These are Borland/Embarcadero property and are not redistributable here. Common sources: original Borland CDs or archived Borland releases. (TASM is **not** part of Embarcadero's "Antique Software" releases — only Turbo C/Pascal — so TASM still requires an original copy.)
3. Place the toolchain executables (`TASM.EXE`, `TLINK.EXE`, `MAKE.EXE`, plus their support files) somewhere DOSBox-X can mount as a separate drive.
4. Mount the repo directory as `C:` and the toolchain as `T:`, then build:
   ```
   mount c /path/to/impulse-tracker
   mount t /path/to/tasm-toolchain
   set PATH=T:\;%PATH%
   c:
   make -f MAKEFILE.MAK
   ```
5. Sound drivers build individually from `SoundDrivers/` via the per-driver `M*.BAT` files, e.g. `MSB16.BAT` for Sound Blaster 16, `MMIDI.BAT` for the pure MPU-401 MIDI driver, `MGUS.BAT` for Gravis Ultrasound, etc. Each batch file invokes TASM on the relevant driver source, links via TLINK, then runs the bundled `EXECOM.COM` to convert the resulting `.EXE` to a `.DRV` that `IT.EXE` loads at runtime, and copies the `.DRV` up to the repo root.

Round-trip iteration time on a modern Mac is a few seconds per build.

### Building everything at once

Three convenience batch files are included for full rebuilds inside DOSBox-X / DOS:

| Script                       | What it does                                                       |
|------------------------------|--------------------------------------------------------------------|
| `BUILDALL.BAT` (repo root)   | `make -f MAKEFILE.MAK`, then both driver `BUILDALL.BAT`s           |
| `SoundDrivers/BUILDALL.BAT`  | `for %%B in (M*.BAT) do call %%B` — every sound driver             |
| `Network/BUILDALL.BAT`       | Same pattern for network drivers (`*.NET`)                         |

Run `BUILDALL.BAT` from the repo root with TASM/TLINK/MAKE on `PATH`. `EXECOM.COM` is shipped inside `SoundDrivers/` and `Network/`, so no extra tooling is needed.

> **Status:** Verified working end-to-end with TLINK 3.01 in `tools-local/`. Builds `IT.EXE` (462,082 bytes), 42 sound drivers (`*.DRV` in repo root), and `ITIPX.NET` in ~57 seconds.

A `buildall.conf.sample` is included for one-shot DOSBox-X local builds. Copy it to `buildall.conf` (gitignored — paths are machine-specific) and run:

```
dosbox-x -conf buildall.conf -fastlaunch -exit -nogui -nomenu
```

It mounts the repo as `C:`, `tools-local/` as `T:`, runs `BUILDALL.BAT`, and writes `MAKE.LOG`, `DRV_SND.LOG`, `DRV_NET.LOG`, and `BUILDALL.STAT`.

> **DOSBox-X shell quirks** to be aware of when iterating: COMMAND.COM does not understand `2>&1` (it creates a literal file called `&1`), and `>` redirects on a parent `call` do not propagate into the called batch's nested `for / call` chain. The driver `BUILDALL.BAT`s work around this by managing their own log redirect (`>> ..\DRV_SND.LOG`) instead of relying on the parent. The `.gitignore` covers stray redirect artifacts (`&1`, `copy`, `*.LOGcd`).

### Option B — Cross-assemble with JWasm/UASM + wlink

TASM syntax is close-but-not-identical to MASM. The source uses `.386P`, mixed-case TASM mnemonics (`Proc` / `EndP` / `Segment` / `Assume`), `/jSMART` (smart-Call), and TLINK-specific options (`/3 /s /v`). A straight JWasm build will fail without preprocessor massaging. Viable, but a project in itself; Option A is the path of least resistance.

### Option C — Run a pre-built `IT.EXE` in DOSBox-X

The original compiled `IT215.EXE` runs fine under DOSBox-X today. Useful if you don't need to patch the source.

### CI build (GitHub Actions)

`.github/workflows/build.yml` builds `IT.EXE` and every driver on every push/PR to `main` by:

1. Installing `dosbox-x` and `xvfb` on Ubuntu.
2. Reassembling a chunked, base64-encoded TASM toolchain ZIP from 13 repo secrets named `TASM_TOOLCHAIN_B64_01` … `TASM_TOOLCHAIN_B64_13` and unpacking it into `tools/` (gitignored).
3. Running DOSBox-X headlessly under `xvfb-run`, mounting the repo as `C:` and `tools/` as `T:`, then invoking `make -f MAKEFILE.MAK`, `SoundDrivers\BUILDALL.BAT`, and `Network\BUILDALL.BAT` in sequence.
4. Uploading `IT.EXE`, all `*.DRV`, all `*.NET`, and the build logs as artifact `IT-EXE-<sha>`.

To enable CI in your own fork: split a ZIP of your TASM toolchain into base64 chunks of ≤48KB each and store them as the 13 secrets above. The workflow fails fast with a clear message if the secrets are absent.

### Toolchain hygiene — what NOT to commit

The TASM/TLINK/MAKE binaries are Borland/Embarcadero property and must never end up in this repository. The `.gitignore` is set up defensively to make accidental contamination very hard:

| Pattern             | Why                                                          |
|---------------------|--------------------------------------------------------------|
| `*.EXE` `*.exe`     | Catches `TASM.EXE`, `TLINK.EXE`, `MAKE.EXE`, plus build output `IT.EXE` |
| `*.OBJ` `*.obj`     | Assembler intermediates                                      |
| `*.LST` `*.lst`     | Assembler listings (note: `!source.lst` is unignored — it's a TLINK response file, not a listing) |
| `*.MAP` `*.map`     | Linker maps                                                  |
| `*.DRV` `*.drv`     | Compiled sound drivers (rebuilt from source)                 |
| `*.NET` `*.net`     | Compiled network drivers (rebuilt from source)               |
| `*.MMX` `*.3DN`     | Mixer variants                                               |
| `tools/`            | Where CI unpacks the proprietary toolchain ZIP               |
| `tools-local/`      | Convention for local-machine toolchain installs              |
| `BUILD_ST.TXT` `MAKE.LOG` `MDATA.LOG` `DIAG*.LOG` | DOSBox-X build artifacts |
| `&1` `D.TXT` `DRV.LOG` `DRV_DONE.TXT` | Stray DOS redirect droppings           |

If you keep your toolchain inside the repo working tree, put it in either `tools/` or `tools-local/`. Both are ignored. Do **not** drop `TASM.EXE` into the repo root — while `*.EXE` is gitignored, the TASM directory contains other files (e.g. `TASM.CFG`, `TASMX.HLP`) that aren't covered by the patterns. Use a subdirectory.

## MIDI Architecture

### What exists today

Impulse Tracker is **MIDI-out centric**. MIDI input has historically been used for entering notes into the pattern editor from an attached MIDI keyboard. This fork adds **MIDI System Real-Time** handling so external sequencers can start/stop song playback (commit `ec42bd1`).

The data path for **incoming** MIDI bytes:

```
MPU-401 IRQ (or Poll)
   └── SoundDrivers/<driver>.ASM: IRQ buffers byte → Poll drains in main loop
         Call [CS:UARTSend]            ← callback filled by IT.EXE
                │
                ▼
IT_K.ASM  Proc MIDISend Far
   - System Real-Time bytes (0xFA/0xFB/0xFC) → Music_PlaySong / Music_Stop
   - Bit 7 set → store in MIDIStatusByte (running-status)
   - Bit 7 clear → accumulate into MIDIDataByte1/2
```

The driver↔host contract is declared in `SoundDrivers/REQPROC.INC` (table of function pointers IT fills in) and populated in `IT_MUSIC.ASM` (`DriverRequiredFunctions`, around lines 716–742). The slots of interest map `UARTBufferEmpty` → `MIDIBufferEmpty` and `UARTSend` → `MIDISend`. **Every sound driver with a MIDI-in hook funnels received bytes through this one `MIDISend` in `IT_K.ASM` — it is the single interception point.**

Playback entry points in `IT_MUSIC.ASM`:

| Proc                  | Args                       | Approx. line |
|-----------------------|----------------------------|--------------|
| `Music_PlayPattern`   | AX=pattern, BX=rows, CX=row| 5665         |
| `Music_PlaySong`      | AX=order                   | 5695         |
| `Music_PlayPartSong`  | AX=order, BX=row           | 5729         |
| `Music_Stop`          | —                          | 5828         |

`StartClock` is an external proc (timer arming) called by `Music_PlaySong`.

### MIDI Real-Time intercept (this fork's patch)

`IT_K.ASM`'s `MIDISend` tests for System Real-Time bytes (0xF8..0xFF) **before** the running-status store, since per the MIDI spec real-time messages must not disturb running status. The current behaviour:

- `0xFA` MIDI Start  → `Music_PlaySong` from order 0
- `0xFB` MIDI Continue → currently aliased to Start (TODO: resume from last-known order/row via `Music_PlayPartSong`)
- `0xFC` MIDI Stop  → `Music_Stop`
- `0xF8` MIDI Clock (24 ppq) → ignored (TODO: external tempo sync)
- `0xF9`, `0xFD`, `0xFE`, `0xFF` → ignored

### Gotchas

1. **`MIDISend` runs in main-loop context, not IRQ context** — on every driver. SB16 and MIDIDRV both receive MIDI bytes at IRQ time but buffer them (SB16: `CheckMIDI` → 256-byte `MIDIBuffer` ring; MIDIDRV: polled status register), then drain via the `Poll Far` export which IT.EXE calls from its main loop. Calling `Music_PlaySong`/`Music_Stop` directly from `MIDISend` is therefore safe.
2. **"Continue" vs. "Start"** — 0xFA Start = from top, 0xFB Continue = from current position. IT already has `Music_PlayPartSong`; a proper `Music_Continue` wrapper should pass the last-known order/row.
3. **0xF8 MIDI Clock (24 ppq)** — door to real external tempo sync. Count 24 clocks per quarter-note and adjust IT's tempo, or tie each clock to one pattern row at a configured PPQ. Significantly more work than Start/Stop/Continue.
4. **SB16 + MIDI sync coexist.** `SoundDrivers/SB16DRV.ASM` provides DMA sample playback AND MIDI-in via the card's MPU-401 UART. Its IRQ handler checks the mixer IRQ status for MIDI-received (bit 2), `CheckMIDI` buffers the byte into the 256-byte ring, and `Poll Far` drains the ring into `[UARTSend]` during the main loop. `DriverFlags = 4`. No driver modifications were needed for the sync patch — only `MIDISend` in `IT_K.ASM`.
5. **User-visible toggle (TODO)** — gate the Real-Time intercept behind a config flag (e.g. `MIDISyncEnable` in `ITMIDI.CFG` or the Driver Setup screen) so users with noisy MIDI cables don't get spurious starts.

### Test plan for MIDI sync

- DOSBox-X can route MIDI to a host CoreMIDI / ALSA endpoint; pair with a host DAW or sequencer sending MIDI Start/Stop via an IAC/virtual MIDI bridge.
- Or: use a hardware sequencer / drum machine sending `FA`/`FC` into the PC's MPU-401.
- Smoke test: load a tune, verify `FA` starts from order 0, `FC` stops, `FB` resumes (currently restarts).

## Contribution Workflow

- `origin` = `esaruoho/impulse-tracker` (this fork)
- `upstream` = `jthlim/impulse-tracker` (read-only)
- Upstream explicitly rejects PRs except "issues preventing build." Do feature work on this fork's `main` (or feature branches); don't open upstream PRs for features.
- To stay current with upstream build fixes: `git fetch upstream && git merge upstream/main`.

### Commit style

Freeform, imperative, short — matching upstream:

- "Fix missing UpdateSampleLocation"
- "Revert text encoding of WAVDRV.ASM to 437"
- "Clarified the read-only nature of the repo"
- "IT_K.ASM: start/stop song on MIDI System Real-Time messages"

No conventional-commit prefixes.

## Known Contributors

| Handle                | Role                                                |
|-----------------------|-----------------------------------------------------|
| @jthlim (Jeffrey Lim) | Author of Impulse Tracker, sole upstream maintainer |
| @cs127                | External contributor (PR #3, #6 — build/typo fixes) |
| @esaruoho             | Fork owner                                          |

## Quick Reference

| Item                  | Value                                                       |
|-----------------------|-------------------------------------------------------------|
| Primary Language      | Assembly (TASM 4.1 syntax, 16-bit + .386P)                  |
| Default Branch        | main                                                        |
| License               | BSD-3-Clause                                                |
| Upstream              | jthlim/impulse-tracker (read-only)                          |
| Fork                  | esaruoho/impulse-tracker                                    |
| Local build (IT.EXE)  | `MAKE -f MAKEFILE.MAK` inside DOSBox-X                      |
| Local build (all)     | `BUILDALL.BAT` from repo root inside DOSBox-X               |
| CI build              | `.github/workflows/build.yml` (DOSBox-X on Ubuntu + xvfb)   |
| Sound driver builds   | `SoundDrivers/M*.BAT` per driver, or `SoundDrivers/BUILDALL.BAT` |
| Network driver builds | `Network/M*.BAT` per driver, or `Network/BUILDALL.BAT`      |
| `.EXE` → `.DRV` tool  | `EXECOM.COM` (shipped in `SoundDrivers/` and `Network/`)    |
| MIDI-in entry point   | `IT_K.ASM` — `Proc MIDISend Far` (~line 1766)               |
| Playback entry        | `IT_MUSIC.ASM:5695` `Proc Music_PlaySong Far`               |
| Driver↔host table     | `SoundDrivers/REQPROC.INC` + `IT_MUSIC.ASM` ~lines 716–742  |
