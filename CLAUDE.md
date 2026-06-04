# CLAUDE.md — Impulse Tracker (esaruoho fork) Development Guide

> Fork of [jthlim/impulse-tracker](https://github.com/jthlim/impulse-tracker) at [esaruoho/impulse-tracker](https://github.com/esaruoho/impulse-tracker). Upstream is read-only ("no active development, and changes/fixes will not be merged other than issues preventing build" — README). Feature work happens on this fork.

This file is a development guide for both human contributors and AI coding assistants working in this repository. It covers how to build `IT.EXE` and the sound drivers locally, the source-tree layout, the MIDI input architecture (including the MIDI System Real-Time start/stop sync added in this fork), and the contribution workflow. **Vendor-neutral agents (Codex, Cursor, Aider, …) should start at [`AGENTS.md`](AGENTS.md)**, which carries the same non-negotiables and points back here for detail.

## Repository Overview

Full Impulse Tracker 2.15 source, BSD-3-Clause. Originally released 2014 on Bitbucket alongside Jeffrey Lim's "20 Years of Impulse Tracker" blog series. TASM 4.1 / TLINK 3.01 / Borland MAKE 4.0 + DOS target. 16-bit real-mode segmented assembly with 386 extensions (`.386P`). Builds `IT.EXE` plus a set of `.DRV` sound drivers loaded at runtime.

## Report Cards & Self-Maintaining Docs (`features/` + git hooks)

**Testing the fork — `./test-impulse-tracker`** (repo-anchored; runs from any directory). This is THE way to verify the fork on real hardware or in DOSBox: it launches the interactive runner (`features/hwtest.py`) over every fork scenario not yet `@hw-verified`, records works / failed (+ how) / skip, flips passes to `@hw-verified` in the cards, and writes `features/HW-FAILURES.md` — the focused worklist of what didn't work. Derived test matrices: `features/STATUS.md` (per-card) and `features/HARDWARE-TEST.md` (per-scenario red-line checklist), both generated from card tags.

This repo documents its own behaviour with **report cards** — Gherkin `.feature` files in `features/`, one per behaviour cluster (e.g. `f11-order-list.feature`, `midi-in-multitimbral.feature`). Each card is the durable understanding-store: Given/When/Then scenarios, each cited to its source proc + line + commit, graded with tags (`@stock` upstream / `@shipped` fork / `@build-verified` / `@hw-untested`). The schema is `GHERKIN-FEATURE-WIKI-PATTERN.md`. **When you change a documented behaviour, update its card in the same motion — don't let it drift.**

Each card carries a **triad**: the `.feature` (the spec/claims), a sibling `*.session.md` (the conversation that spawned it — the "vibe diff"), and a `RESULT-LOG` (what actually shipped: dated commit/PR lines). The triad makes the wiki rebuildable straight from git.

**Authoring loop when you build or change a behaviour** (do all of it in the same motion as the code — don't ask permission, don't defer):

1. Edit code → build in DOSBox-X (`Error/Warning = None`, `IT.EXE` links).
2. Commit + push the code (direct to `main`; the `pre-commit` hook stamps the RESULT-LOG of any card whose `# WATCH:` symbols you touched).
3. Emit / update the **triad**: the `.feature` (graded Gherkin scenarios, each cited to proc + line + commit), the `<name>.session.md` (the spawning conversation, incl. wrong turns — faithful, not flattering, with a "How to get back" block), and a back-link comment `; FEATURE-CARD >> features/<name>.feature` at the innards.
4. Enrol the card in `features/INDEX.md` (the commit ↔ card map).
5. Regenerate the human-readable reference: `python3 features/print-card.py --readme` writes **`features/README.md`** (one section per card: *what it does* + *how it does it*), and `--all` refreshes the per-card `features/dist/` printouts. `features/README.md` is **generated — never hand-edit it**; edit the card and regenerate.
6. Grade honestly: `@build-verified` once it assembles/links; only `@runtime-verified` after you (or the user) actually ran `IT.EXE` and watched it. Untested is `@runtime-untested` — never claim verified you didn't run.

`features/print-card.py` is the tool: `--readme` (regenerate the README), `--all` (per-card dist outputs), or a path list (one card). No deps, Apple-native python3.

**The Gherkin `.feature` house style** — a `#`-comment banner (the report-card metadata), then standard Gherkin. Copy this skeleton; match an existing card (e.g. `sample-amplify-keeps-playback.feature`) for the full banner:

```gherkin
# =============================================================================
# WIKI PAGE / REPORT CARD: <one-line title>
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# WHAT THIS CARD SPAWNS:  codespace (files/procs) · thinkspace (the .session.md)
#                         · areaspace (what it owns / must NOT touch)
# Report-card legend (tags): @stock @shipped @build-verified @runtime-verified
#                            @runtime-untested @hw-untested @todo
# Source files linked back to this card (grep "features/<name>"):
#   IT_X.ASM - <proc / what>
# Commit log:   <hash>  <subject>
# SESSION:      features/<name>.session.md
# RESULT:       Feature delivery <hash> (direct to main, no PR); card authored <hash>
# WATCH: Proc1 Proc2 Proc3      <- symbols the git hooks watch to auto-stamp this card
# =============================================================================

Feature: <behaviour title>
  As a <role>, I want <capability>, So that <benefit>.

  @shipped @build-verified @runtime-untested
  Scenario: <ONE behaviour, ONE verifiable outcome>
    # cite: IT_X.ASM SomeProc (~line NNN) — what satisfies the claim ; commit <hash>
    Given <the starting state>
    When <the single action>
    Then <the concrete, verifiable outcome — not "it works">
    And <a further outcome>
```

Rules of the style: **one Scenario = one behaviour** (no 10-`And` grab-bags); **every Scenario carries a grade tag**; **every claim cites proc + line + commit** in a `# cite:` line; the `Then` is a *strong* criterion you can verify and walk away from (`Then only the preview voice falls silent, song keeps playing` — not `Then it works`); keep step phrasing consistent across cards so the vocabulary stays cross-referenceable. The reasoning behind the style is in `GHERKIN-FEATURE-WIKI-PATTERN.md`.

The RESULT-LOG keeps itself current via **version-controlled git hooks in `.githooks/`**:

- `pre-commit` stamps cards whose WATCHed symbols are in the *staged* diff and `git add`s the card so the note rides into the same commit (the everyday direct-to-main path).
- `post-merge` does the same for merges / PRs (records the merge SHA + PR number).
- `report-card-stamp.sh` is the shared engine. Mapping is **by symbol** (each card's `# WATCH:` line lists the procs it cites), so touching an unrelated part of a shared file like `IT_G.ASM` doesn't tag every card. `features/` and `.githooks/` are excluded from the scanned diff so a card can't self-tag.

**ONE-TIME SETUP PER CLONE (REQUIRED — git won't auto-run committed hooks):**

```
git config core.hooksPath .githooks
```

Run that once after cloning (e.g. on the Mac Mini). Without it the cards still work as docs, but they stop self-updating. Verify with `git config core.hooksPath` (should print `.githooks`). Full detail: `.githooks/README.md`.

## User-Facing Keyboard Reference (from IT.TXT — DO NOT GUESS)

**Source of truth:** `ReleaseDocumentation/IT.TXT` and the IRQ-level handler in `IT_K.ASM`. If a key isn't listed here and isn't in `IT.TXT`, look it up before mentioning it to the user. Hallucinated key bindings (e.g. claiming "Space" is the play key, or calling Ctrl-O "module load" when it's WAV render) waste the user's time and erode trust. This has happened more than once. **Do not guess.**

### Transport (global)

| Key | What it does | Source |
|-----|--------------|--------|
| **F5** | Play song from start | `IT.TXT:395`; `IT_K.ASM:1902` comment "F5 equivalent" |
| **F6** | Play song from current order | User-confirmed; pairs with F5 per tracker convention |
| **F7** | Play from playback mark | `IT.TXT:1074` ("subsequent playback will occur when you press F7") |
| **F8** | Stop playback | `IT.TXT:395`; `IT_K.ASM:725` — IRQ-level, scancode `42h` → `Music_Stop` |
| **Ctrl-F6** | Play pattern from current row | `IT.TXT:1072` |
| **Ctrl-F7** | Set / clear playback mark | `IT.TXT:1073-1076` |
| **Right-Ctrl** | Play song from DOS Shell | `IT.TXT:265` (opt-in via config option "C") |
| **Right-Alt** | Stop playback from DOS Shell | `IT.TXT:264` |

### Screen navigation (global)

| Key | What it does | Source |
|-----|--------------|--------|
| **F1** | Help screen | `IT.TXT:1747` |
| **F2** | Pattern editor (second press inside = Pattern Edit Config) | `IT.TXT:426, 437` |
| **F3** | Sample list (Ctrl-F3 accesses Sample library from anywhere) | `IT.TXT:1816` |
| **F4** | Instrument list (Ctrl-F4 accesses Instrument library from anywhere) | `IT.TXT:1817` |
| **F9** | Load module file picker | `IT.TXT:387` |
| **F10** | Save module (Save As). Fork: Alt-W = Quicksave to memorized folder, Shift-Alt-W = memorize folder. | code (IT_DISK.ASM Glbl_F10) |
| **F11** | Order list / channel panning & volume | `IT.TXT:1221, 1747` |
| **F12** | Song variables / configuration. Fork: Quicksave directory row added. | `IT.TXT:659, 1748` |
| **Shift-F1** | (fork) MIDI Monitor; also hosts the MIDI Sync toggle since commit `7163709` | fork |
| **Ctrl-F2** | Bulk pattern length editor for consecutive patterns | `IT.TXT:438` |
| **Alt-F10** | Solo current channel | `IT.TXT:1803` |

### Pattern editor

| Key | What it does | Source |
|-----|--------------|--------|
| **4** | Play note under cursor | `IT.TXT:1070` |
| **8** | Play entire row | `IT.TXT:1071` |
| **Space** | Enter previous data for current column. **NOT a play key.** | `IT.TXT:1069, 1800` |
| **`.`** | Erase data at cursor | `IT.TXT:1068` |
| **Grey +/-** | Next / previous pattern | `IT.TXT:1058-1059` |
| **Shift-Grey +/-** | ±4 patterns | `IT.TXT:1060-1061` |
| **Ctrl-Grey +/-** | Next / previous pattern by order list | `IT.TXT:1062-1063, 1825` |
| **Alt-R** | (fork) Replicate at Cursor (Paketti port) | commit `aaada5e` |
| **Shift-Alt-R** | Original Alt-R = "Clear all track views" | commit `aaada5e` |
| **Alt-Q / Alt-A** | Transpose semitone up / down | `IT.TXT:1134, 1105` |
| **Alt-P** | Block Paste at cursor | `IT_PE.ASM:632` (key word `1900h`) |
| **Alt-C** | Block Copy | `IT_PE.ASM:636` |
| **Ctrl-C** | Toggle centralise cursor | `IT_PE.ASM:640` |
| **Ctrl-O** | (fork) Render Pattern to WAV + auto-import as next sample. **NOT module load.** Module load is on F9. | `IT_PE.ASM:629` → `PEFunction_RenderPattern` in `IT_MUSIC.ASM` |
| **Ctrl-Backspace** | 10-stage Undo | `IT.TXT:1054` |
| **Alt-Enter** | Store current pattern | `IT.TXT:1092` |
| **Alt-Backspace** | Restore stored pattern | `IT.TXT:1093` |
| **Alt-Delete / Insert** | Remove / insert an entire row | `IT.TXT:1065-1066` |
| **Alt-B / Alt-E** | Mark top-left / bottom-right of block | `IT.TXT:1096-1097` |

### Loader screens (after F9)

| Action | Path | Status as of `a44c41b` |
|--------|------|------------------------|
| **Enter** on a folder | enter sample-loader file browser (`D_PostLoadSampleWindow`) | unchanged |
| **Keyjazz inside file browser** | → `LoadSample(99)` for preview | **No longer kills song playback** (was: brute `Music_Stop`; now: `Music_SilenceSampleVoices(99)` — only the preview voice falls silent) |
| **Enter** on a sample file | `LSWindow_EnterSample` → `LoadSample(currentSlot)` | **No longer kills song playback** (was: two `Music_Stop` calls; now: target-slot voices silenced only) |
| **Enter** on a module file | `D_PostFileLoadWindowLink` → `D_LoadModuleHeader` (IT_DISK.ASM:4172) | Still calls `Music_Stop` — intentional (loading a new song stops the current one) |
| **Enter** on an instrument file (bulk) | `LIWindow_Enter5` (IT_DISK.ASM:10160) | Still calls `Music_Stop` — intentional (reshuffles many sample slots at once) |

### Honesty protocol for keybindings

If asked about a key that isn't in this table:

1. `grep -an "Ctrl.*X\|Alt.*X\|F\b" ReleaseDocumentation/IT.TXT` (substitute the key)
2. If not in IT.TXT: search keyword tables in `IT_PE.ASM` / `IT_K.ASM` / `IT_M.ASM`. The Alt/Ctrl modifier codes are documented in the skill's "Keymap Dispatch & Modifier Disambiguation" section.
3. If still not found, say so plainly: *"Key word `XXXXh` isn't bound in any dispatcher I can find. Can you confirm the exact key?"*

**Never invent a key.** Every fabricated binding undermines the rest of the response.

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

## Mixer & Slave Channel Layout (from MIX.INC + IT_MUSIC.ASM)

**Important:** `SoundDrivers/MIX.INC` (1014 lines) and `MIXWAV.INC` (1065 lines) are the actual mixer source. They get included into each sound driver at assembly time. The `.MMX` / `.3DN` extensions are object files, not source, but the source is right here in the tree. Read `MIX.INC` before reasoning about voice rendering, page mapping, or "what does the mixer do when X."

### Constants (`IT_MUSIC.ASM:211-213`)

| Symbol | Value | Notes |
|--------|-------|-------|
| `HOSTCHANNELSIZE` | 80 bytes | Per-channel host slot in `HostChannelInformationTable` |
| `SLAVECHANNELSIZE` | 128 bytes | Per-voice slave slot in `SlaveChannelInformationTable` |
| `MAXSLAVECHANNELS` | 256 | Slave pool size — 64 master × up to 4 NNA per channel |
| `NONOTE` | `0FDh` | Empty pattern event note byte |

### Slave channel struct (`SlaveChannelInformationTable`, 128 bytes per slave)

Authoritative offsets observed in both MIX.INC (mixer side) and IT_MUSIC.ASM (control side). DS:SI points to the slave entry; ES typically holds `SongDataArea` when crossing into sample-header fields via `[SI+34h]`.

| Offset | Width | Name / EQU (in MIX.INC) | Purpose |
|--------|-------|--------------------------|---------|
| `[SI+00h]` | Word | flags | **Bit 0 = active**; **`200h` = voice-off** (sample finished, NNA cut, or manually stopped). Mixer writes `200h` at MIX.INC:79/90/323 when it terminates a voice. `Music_StopChannels`, `Music_Stop`, and the new `Music_SilenceSampleVoices` all use the same `200h` value. **This is the canonical "voice is off" sentinel.** |
| `[SI+02h]` | DWord | `STEPVALUE` | 16.16 fixed-point pitch step per output sample |
| `[SI+0Bh]` | Byte | `DIRECTIONFLAG` | Ping-pong loop direction |
| `[SI+2Ch]` | DWord | `OLDPOSITION` | Last frame's sample position (for ramping?) |
| `[SI+30h]` | Word | InsOffset | Pointer to instrument header in SongDataArea |
| `[SI+32h]` | Word | Nte&Ins | Note byte (low) + instrument byte (high) |
| `[SI+34h]` | Word | Sample header ptr | Offset into SongDataArea of the sample-header struct. **Mixer rereads this every Mix call via `PrepareSampleSegment` — do not assume cached pointers.** |
| `[SI+36h]` | Byte | Sample slot | 1-based sample number, 1..99. **`100` = MIDI slave** (filter trick: sample slots can't collide with the MIDI sentinel). |
| `[SI+38h]` | Word | HCOffset | Host channel offset back-reference |
| `[SI+3Ah]` | Byte | HCN | Host Channel Number (0..63). **Bit 7 = disowned** (channel was reassigned via NNA) |
| `[SI+3Eh]` | Word | Filter cutoff | `0FFh` = default / unset |
| `[SI+40h]` | DWord | `LOOPSTART` | Loop start, in samples |
| `[SI+44h]` | DWord | `LOOPEND` | Loop end, in samples |
| `[SI+48h]` | Word | `CURRENTPOSITIONERROR` | Fractional position (low 16 of 16.16) |
| `[SI+4Ch]` | DWord | `CURRENTPOSITION` | Integer position (high 32 of 16.16) |

Remaining bytes (up to 128) hold envelope state, volume ramps, NNA chain pointers, etc. — extend this table when you observe new offsets in working code.

### Sample header struct (pointed to by `[SI+34h]`, lives in `SongDataArea`)

Authoritative offsets observed across `IT_MUSIC.ASM` (`Music_GetSampleLocation`, `Music_ReleaseSample`) and `MIX.INC` (`PrepareSampleSegment`).

| Offset | Width | Purpose |
|--------|-------|---------|
| `[BX+12h]` | Byte | **Sample flags.** Bit 0 = sample exists (gates `Music_GetSampleLocation` — returns Carry if clear). Bit 1 = 16-bit (Zero-flag set in GetSampleLocation if cleared). |
| `[BX+14h..2Eh]` | bytes | Sample name (26 chars) and filename area |
| `[BX+30h]` | DWord | Sample length in samples |
| `[BX+48h]` | Byte | **MemoryType.** 0 = none, 1 = conventional RAM, 2 = EMS. Mixer's `PrepareSampleSegment` reads `[BX+48h]` as a DWord into the triplet below in one instruction. |
| `[BX+49h]` | Byte | NumPages (for EMS) |
| `[BX+4Ah]` | Word | **SampleLocation** — either EMS handle (MemoryType=2) or conventional base segment (MemoryType=1) |

### Mixer state cache (per-driver, in driver's CS, from `MIX.INC:27-47`)

Read & repopulated by `PrepareSampleSegment` on every Mix call — **not cached across calls.**

| Symbol | Width | Purpose |
|--------|-------|---------|
| `MixBlockSize` | DWord | Bytes to mix this call |
| `MixFunction` | Word | Pointer to current Mix routine |
| `MemoryType` | Byte | Refetched from `[SampleHeader+48h]` each call |
| `NumPages` | Byte | EMS page count |
| `SampleLocation` | Word | EMS handle or conventional base seg |
| `EMSPageFrame` | Word | Cached frame segment for EMS mapping |
| `LastPage` | Word | Last mapped EMS page (`0FFFFh` = none cached) |

### Mixer entry & voice-off semantics

Mixer driver loop walks `SlaveChannelInformationTable`. For each slave:

1. Test `[SI]` bit 0 (active) — skip if clear.
2. Call `PrepareSampleSegment` → reads `[ES:[SI+34h]+48h]` triplet fresh.
3. Run one of `MixNoLoop` / `MixForwardsLoop` / `MixPingPongLoop` based on sample flags.
4. On sample-end, mixer writes `Word Ptr [SI], 200h` itself.

**Consequence for sample reload:** Setting `Word Ptr [SI] = 200h` externally puts the voice in the same state the mixer puts it in at natural sample-end. Next pattern hit on that slot allocates a fresh slave normally. The mixer's lack of caching across mix calls means there's no "stale pointer race" — header mutation is visible on the next call.

**Used by:**
- `Music_Stop` (`IT_MUSIC.ASM:6618`) — sets `200h` on all slaves via `Music_Clear2` loop.
- `Music_StopChannels` (`IT_MUSIC.ASM:6565`) — sets `200h` on all slaves with MIDI handling first.
- `Music_SilenceSampleVoices` (`IT_MUSIC.ASM`, commit `a44c41b`) — sets `200h` only on slaves matching a given sample slot. Strict subset of the above two.

### Where to put new mixer-side flags

If you need the mixer to behave differently for some condition (e.g. a fade-out, a "reloading" gate), you generally have three options:

1. **Per-slave flag in `[SI]`** — cheapest. Pick an unused bit in the flags word. Mixer is `Test Byte Ptr [SI], 1` to enter; add a second test if needed.
2. **Per-slot flag in the sample header `[BX+12h]`** — already gates `Music_GetSampleLocation`. Bit 0 clear → mixer can't refetch pages, voice effectively silenced after next page boundary.
3. **Mixer global in driver's CS** — like `MemoryType` / `LastPage`. Useful for "pause all rendering" or "suspend until flag clear" patterns. Cost: every driver needs the addition (16 sound drivers in `SoundDrivers/`).

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
