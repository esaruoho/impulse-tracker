---
name: impulse-tracker
description: Development skill for Jeffrey Lim's Impulse Tracker DOS source — TASM/TLINK assembly tracker. Fork (esaruoho/impulse-tracker) adds external MIDI sync (Start/Stop/Continue + F8 Clock), driver-level F8-FF passthrough across 16 sound drivers, Ctrl-O WAV render + auto-import + Quicksave routing + Shift-Ctrl-O no-import, F3 loader keyjazz hang fix via MIDISyncLoaderSuppress, Alt-R Replicate at Cursor (Paketti port), F2-F2 configurable default pattern length, F11 order-list power tools (Ctrl-O/Shift-Ctrl-O/Ctrl-G/Shift-G render, Alt-D clone+auto-insert+cursor-advance, Alt-E extend, M toggle, cursor-key edge gestures), Shift-Enter F9 bulk-load all module samples, F12 Samples→Instruments envelope preservation, Quicksave folder, F12 directory pickers (Module/Sample/Instrument/Quicksave rows all Enter-pickable via unified D_PickDir_Common helper), MIDI Monitor (Shift-F1), IT.CFG ForkExt block for persisted settings, Multi-WAV (Shift-Alt-M per-pattern + F10 WAV/MWAV buttons for whole-song single/per-channel render, with user-typed filename honoring), new K_TranslateCondition11 for Shift+Alt keymap combos. VRAM debug markers established as standard hard-hang triage tool.
domain: repository-specific
version: 1.3.0
generated: 2026-05-20
source_repo: https://github.com/esaruoho/impulse-tracker
upstream_repo: https://github.com/jthlim/impulse-tracker
source_platform: github
tags: [assembly, tasm, dos, tracker, midi, mpu-401, 16-bit, ems, dosbox-x]
triggers:
  keywords:
    primary: [impulse-tracker, IT.EXE, jthlim, jeffrey lim]
    secondary: [tracker, tasm, mpu-401, dosbox, midi sync, start clock, vram marker, keyjazz hang, replicate at cursor, paketti]
---

# Impulse Tracker Development Skill

> Fork of jthlim/impulse-tracker at esaruoho/impulse-tracker. Upstream is read-only ("no active development, and changes/fixes will not be merged other than issues preventing build" — README). Work on the fork.

## Repository Overview

Full Impulse Tracker 2.15 source, BSD-3-Clause. Originally released 2014 on Bitbucket alongside Jeffrey Lim's "20 Years of Impulse Tracker" blog series. TASM 4.1 / TLINK 3.01 / Borland MAKE 4.0 + DOS target. 16-bit real-mode segmented assembly with 386 extensions (`.386P`). Builds `IT.EXE` plus a set of `.DRV` sound drivers loaded at runtime.

## User-Facing Keyboard Reference (from IT.TXT — DO NOT GUESS)

**Source of truth:** `ReleaseDocumentation/IT.TXT` and the IRQ-level handler in `IT_K.ASM`. If a key isn't listed here and isn't in `IT.TXT`, look it up before mentioning it to the user. Hallucinated key bindings (e.g. claiming "Space" is the play key, calling Ctrl-O "module load" when it's WAV render) waste the user's time and erode trust. This has happened more than once. **Do not guess.**

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
| **F2** | Pattern editor (second press inside = Pattern Edit Config). Fork: dialog's "Number of rows in pattern" value persists into IT.CFG as `DefaultNewPatternLength`; future empty patterns inherit it. | `IT.TXT:426, 437`; `IT_G.ASM` Glbl_F2_1 |
| **F3** | Sample list (Ctrl-F3 accesses Sample library from anywhere) | `IT.TXT:1816` |
| **F4** | Instrument list (Ctrl-F4 accesses Instrument library from anywhere) | `IT.TXT:1817` |
| **F9** | Load module file picker | `IT.TXT:387` |
| **F10** | Save module (Save As). Fork: Alt-W = Quicksave to memorized folder, Shift-Alt-W = memorize folder. | code (IT_DISK.ASM Glbl_F10) |
| **F11** | Order list / channel panning & volume. Fork: extensive new keymap entries — see "F11 Order List Fork Ops" section below. | `IT.TXT:1221, 1747` + fork |
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
| **Ctrl-O** | (fork) Render Pattern to WAV + auto-import as next sample. File lands in **Quicksave folder** (cross-machine handoff target), not Sample dir. Pre-flight chdir validation: bad Quicksave path aborts cleanly. **NOT module load.** Module load is on F9. | `IT_PE.ASM:629` → `PEFunction_RenderPattern` → `Music_ToggleWAVRender` |
| **Shift-Ctrl-O** | (fork) Render Pattern to WAV in Quicksave folder, **no auto-import**. File written for cross-machine pickup, no IT sample slot consumed. | `PEFunction_RenderPattern` shift-aware dispatcher; `WAV_NoImport` + `WAV_SessionNoImport` flags in `IT_MUSIC.ASM` |
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
| **Shift-Enter** on a module file row | (fork) `LSWindow_ShiftEnter` (IT_DISK.ASM) | Bulk-loads every sample from the module into consecutive slots from cursor. In instrument mode, also auto-assigns each via `Music_AssignSampleToInstrument`. Wraps the whole loop in `MIDI_SetLoaderSuppress` so FA/FB/FC bytes buffered during per-call `Music_SilenceSampleVoices` Cli windows cannot restart playback into a half-loaded slot. Skips empty source slots, stops at slot 99. |

### Honesty protocol for keybindings

If asked about a key that isn't in this table:

1. `grep -an "Ctrl.*X\|Alt.*X\|F\\b" ReleaseDocumentation/IT.TXT` (substitute the key)
2. If not in IT.TXT: search keyword tables in `IT_PE.ASM` / `IT_K.ASM` / `IT_M.ASM`. The Alt/Ctrl modifier codes are documented in [Keymap Dispatch & Modifier Disambiguation](#keymap-dispatch--modifier-disambiguation) below.
3. If still not found, say so plainly: *"Key word `XXXXh` isn't bound in any dispatcher I can find. Can you confirm the exact key?"*

**Never invent a key.** Every fabricated binding undermines the rest of the response.

## Toolchain (From README + MAKEFILE.MAK)

- Turbo Assembler v4.1 (`TASM /m /uT310 /jSMART`)
- Turbo Link v3.01 (`tlink /3 /s /v @source.lst`)
- Borland MAKE v4.0
- DOS (or DOSBox-X / vDosPlus / real hardware)

`source.lst` is the link response file (do NOT ignore it — `.gitignore` explicitly unignores it).

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
├── IT_S.ASM             — ?
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

## Build: `IT.EXE` on a modern Mac

Two realistic paths:

### Option A — DOSBox-X with TASM/TLINK/MAKE inside DOS (recommended, closest to original)

1. `brew install dosbox-x`
2. Obtain Turbo Assembler 4.1, Turbo Linker 3.01, Borland MAKE 4.0. These are Borland/Embarcadero property; they're widely available in archived form but not free to redistribute. Common sources: the user's own old Borland CDs, the Embarcadero "Antique Software" releases (TASM is not part of those — only Turbo C/Pascal — so TASM still requires an original license or archived copy).
3. Mount the repo directory in DOSBox-X, set PATH to the TASM/TLINK/MAKE `BIN`, and:
   ```
   C:\> cd IT
   C:\IT> MAKE -f MAKEFILE.MAK
   ```
4. Sound drivers build individually from `SoundDrivers/` via `M*.BAT` (e.g. `MSB16.BAT` for Sound Blaster 16).

### Option B — Cross-assemble with JWasm/UASM (Masm-syntax clones) + wlink

TASM syntax is close-but-not-identical to MASM. The source uses `.386P`, mixed-case TASM mnemonics (`Proc` / `EndP` / `Segment` / `Assume`), `/jSMART` (smart-Call), and TLINK-specific options (`/3 /s /v`). A straight JWasm build will fail without preprocessor massaging. Viable, but a project in itself; Option A is the path of least resistance.

### Option C — Run a pre-built `IT.EXE` in DOSBox-X

Not what you asked, but worth noting: the original compiled `IT215.EXE` runs fine under DOSBox-X today. Only do this if you don't need to patch the source.

**My recommendation for your "I want to build IT.exe" goal:** Option A inside DOSBox-X. Once the round-trip edit→`MAKE`→run-in-DOSBox-X loop works, iterating on patches (including the MIDI sync one below) is minutes per cycle.

## MIDI Architecture (current state)

Impulse Tracker upstream is MIDI-out centric. MIDI input was originally used only for note entry. **The fork now also implements external MIDI sync** — Start/Stop/Continue + F8 Clock-derived tempo — by intercepting System Real-Time bytes inside `MIDISend`. Default ON since `ad5d840`, toggleable on the Shift-F1 MIDI Monitor screen.

The data path for **incoming** MIDI bytes:

```
MPU-401 IRQ (or Poll)
   └── SoundDrivers/<driver>.ASM: IRQ buffers byte (FIFO)
         Poll Far → drains ring buffer → Call [CS:UARTSend]
                │
                ▼
IT_K.ASM (current line ~1839)  Proc MIDISend Far
   - System Real-Time intercept first (0xF8..0xFF) — must not disturb
     running status per MIDI spec
       - FA Start    → Music_KBPlaySong   (suppressed if loader busy)
       - FB Continue → Music_KBPlaySong   (suppressed if loader busy)
       - FC Stop     → Music_Stop         (suppressed if loader busy)
       - F8 Clock    → MIDIClockCount++, every 24 → derive BPM from
                         DOS-tick delta, call Music_SetTempoFromClocks
                         (gated by MIDISyncEnable)
       - F9, FD-FF   → ignored
   - All RT bytes bump MIDIMon_* counters for the Shift-F1 monitor
   - Bit 7 set (non-RT)  → store in MIDIStatusByte (running-status)
   - Bit 7 clear         → accumulate into MIDIDataByte1/2
```

The driver↔host contract is declared at **`SoundDrivers/REQPROC.INC`** (table of function pointers IT fills in) and populated in `IT_MUSIC.ASM` (`DriverRequiredFunctions`, ~lines 716-742). Slot 23/24 map `UARTBufferEmpty`→`MIDIBufferEmpty` and `UARTSend`→`MIDISend`. **Every sound driver with a MIDI-in hook funnels received bytes through this one `MIDISend` in `IT_K.ASM` — single interception point.**

Critical timing fact: **`MIDISend` runs in main-loop context, not IRQ.** The driver IRQ buffers MIDI bytes; main-loop Poll drains them. Therefore `Music_KBPlaySong` / `Music_Stop` are safe to call directly from `MIDISend` — they're not preempting the mixer IRQ.

Playback entry points (in `IT_MUSIC.ASM`):
- `Music_PlaySong` (AX=order)  — line 5695
- `Music_PlayPartSong` (AX=order, BX=row) — line 5729
- `Music_PlayPattern` (AX=pattern, BX=rows, CX=row) — line 5665
- `Music_Stop` — line 5828
- `StartClock` — external proc (timer arming), already called by `Music_PlaySong`

### Sync intercept — landed

The Start/Stop/Continue/Clock intercept landed across commits `ec42bd1` (initial), `ad5d840` (default-ON + Alt-F12 toggle, later moved to Shift-F1 in `7163709`), `0a82cb3` + `03b0a6d` (F8 Clock tempo sync with delta sanity check), `95f628a` (Shift-F1 monitor counters). Driver-level F8-FF passthrough fixes across 16 drivers in `4ebf849` + `78fb72d`. See current `IT_K.ASM` MIDISend (~line 1839) for the live structure. The proc is too long now to inline here — read it from source.

### Gotchas

1. **`MIDISend` is called from main-loop context, not IRQ context — on every driver.** Verified by reading SB16DRV.ASM and MIDIDRV.ASM: both drivers receive MIDI bytes at IRQ time but buffer them (SB16: `CheckMIDI` → 256-byte `MIDIBuffer` ring; MIDIDRV: polled status register), then drain via the `Poll Far` export (`SB16DRV.ASM:2297`, `MIDIDRV.ASM:406`) which IT.EXE calls from its main loop. `[UARTSend]` → `MIDISend` (IT_K.ASM:1766) therefore runs in main-loop context. **Calling `Music_PlaySong`/`Music_Stop` directly from `MIDISend` is safe.** (The flag-defer pattern in `IT_M.ASM` is still architecturally cleaner, but not required for correctness.)
2. **"Continue" vs. "Start":** 0xFA Start = from top, 0xFB Continue = from current position. IT already has `Music_PlayPartSong`; a `Music_Continue` wrapper would pass the last-known order/row. If you don't care, alias Continue to Start for v1.
3. **0xF8 MIDI Clock (24 ppq):** optional feature-creep, but this is the door to real external tempo sync. You'd count 24 clocks per quarter-note and adjust IT's tempo, or tie each clock to one pattern row at a configured PPQ. Significantly more work — do Start/Stop/Continue first.
4. **SB16 + MIDI sync coexistence — DRIVER MODIFICATIONS REQUIRED.** `SoundDrivers/SB16DRV.ASM` provides both DMA sample playback AND MIDI-in via the card's MPU-401 UART. IRQ handler checks the mixer IRQ status for MIDI-received (bit 2) and calls `CheckMIDI`, which buffers bytes into a 256-byte `MIDIBuffer` ring; `Poll Far` drains the ring into `[UARTSend]` during the main loop.
   **HOWEVER**: `CheckMIDI` (and the equivalent inline poll path in `GUSMIXDR.ASM` / `IWDRV.ASM`) historically dropped EVERY byte ≥ 0xF0 before buffering — meant to filter SysEx, but caught System Real-Time (`F8` Clock, `FA` Start, `FB` Continue, `FC` Stop) too. This is fixed in the fork as of 2026-05-04 across 16 drivers (commits `4ebf849` + `78fb72d`). The fix pattern is `Cmp AL, 0F8h / JAE <pass> / Cmp AL, 0F0h / JAE <end> / <pass>:`. If you see a new MIDI-input driver added to the tree, audit its CheckMIDI / poll path for the same `Cmp AL, 0F0h / JAE` pattern near a `Call [UARTSend]` and apply the same fix. **The pure `MIDIDRV.ASM` (MPU-401 only) has no filter and was always sync-clean.**
5. **User-visible switch:** Add an "External MIDI Sync" toggle in `ITMIDI.CFG` or the Driver Setup screen, otherwise users with noisy MIDI cables will get unwanted starts. Gate the new logic behind `Cmp Byte Ptr [MIDISyncEnable], 0 / JZ MIDISend_NotRT`.

### Test plan

- DOSBox-X has a MIDI routing option; pair with a host DAW sending MIDI Start/Stop via an IAC/virtual MIDI bridge.
- Or: use a hardware sequencer / drum machine (your usual suspects) sending `FA`/`FC` into the PC's MPU-401.
- Smoke: load a tune, verify `FA` starts from order 0, `FC` stops, `FB` resumes.

## Contribution Workflow

- `origin` = `esaruoho/impulse-tracker` (your fork)
- `upstream` = `jthlim/impulse-tracker` (read-only)
- Upstream explicitly rejects PRs except "issues preventing build." Do feature work on your fork's `main` (or feature branches), don't bother opening upstream PRs.
- To stay current with upstream build fixes: `git fetch upstream && git merge upstream/main`.

## Commit Style (upstream)

Freeform, imperative, short: "Fix missing UpdateSampleLocation", "Revert text encoding of WAVDRV.ASM to 437", "Clarified the read-only nature of the repo". No conventional-commit prefixes.

## Known Contributors

| Handle | Role |
|--------|------|
| @jthlim (Jeffrey Lim) | Author of Impulse Tracker, sole maintainer |
| @cs127 | External contributor (merged PR #3, #6 — build/typo fixes) |
| @esaruoho | You — fork owner |

## Hangs & Concurrency

### Music_Stop's Cli window (the key detail)

`IT_MUSIC.ASM` `Music_Stop` does `Cli` at ~line 6625 and holds it through `PopF` at ~line 6750 while:
- walking SlaveChannelInformationTable for MIDI-out STOPNOTE / STOP via `MIDITranslate`
- zeroing HostChannelInformationTable + SlaveChannelInformationTable
- writing MIDIPrograms = 0xFFFF
- calling `Music_InitTempo` + `MIDI_ClearTable`

While that Cli is held, **the CPU's IRQ line is masked but the sound card UART hardware keeps buffering incoming MIDI bytes into its FIFO**. When `PopF` releases interrupts, the driver's Poll routine eventually drains the buffered bytes through `[UARTSend]` → `MIDISend`. Any FA/FC/FB that was buffered during the Cli window fires its callback after the fact.

This is the key detail behind the **F3 loader keyjazz hard hang**:

1. Song playing (mixer voices active), external MIDI clock streaming.
2. F3 → Enter sample loader, keyjazz a note.
3. `D_PostLoadSampleWindow` (`IT_DISK.ASM` keyjazz branch) → `LoadSample(99)` → calls `Music_Stop` (`IT_DISK.ASM:7090`-ish).
4. `Music_Stop` holds Cli. UART buffers FA from the external clock at a bar boundary.
5. `Music_Stop` returns, Cli released. Driver Poll drains FA → `MIDISend` → `Music_KBPlaySong`. **Playback restarts while `LoadSample` is mid-file-read into slot 99.**
6. Restarted mixer reads a pattern note on slot 99, follows half-written sample header into invalid EMS pages. `Int 3` (sample-pointer-refresh trampoline at `IT_MUSIC.ASM:6375`, `Music_UpdateSampleLocation`) fires. `Music_GetSampleLocation` tries to map EMS for a bogus length. Mixer IRQ spins. Hard hang, no soft reset.

### The fix: MIDISyncLoaderSuppress

Commit `64fa1ce`. Gate `MIDISend`'s RT-branch callbacks behind a flag set by `IT_DISK.ASM` around the `LoadSample → Music_PlaySample` critical section. While set:
- RT counters still tick (Shift-F1 monitor stays live)
- `MIDISendRTStart` / `MIDISendRTContinue` / `MIDISendRTStop` skip the `Music_KBPlaySong` / `Music_Stop` callbacks
- F8 Clock handling still runs (it doesn't restart playback)

Plumbing:
- `MIDISyncLoaderSuppress DB 0` in `IT_K.ASM` Keyboard segment, declared `Global`.
- Two Far helpers in `IT_K.ASM`: `MIDI_SetLoaderSuppress` / `MIDI_ClearLoaderSuppress`. Each does `Push CS / Pop DS / Mov Byte Ptr [flag], 1|0` and `Pop DS / Ret`. Keeps `IT_DISK.ASM` out of cross-segment data access.
- `IT_DISK.ASM` `D_PostLoadSampleWindow` keyjazz branch calls `MIDI_SetLoaderSuppress` before `LoadSample`, and the common-exit label `D_PostLoadSampleWindow4` always calls `MIDI_ClearLoaderSuppress` before `Ret` — safe to call when not in keyjazz, so non-keyjazz iterations are cheap.

### Why this class of hang doesn't repro on DOSBox-X

DOSBox-X without an external MIDI source streaming clock bytes can't reproduce this hang. The race requires real buffered FA/FC bytes arriving during the Cli window. Without external clock, the loader keyjazz path is innocent. **Document this when triaging: "user reports hang on real hardware, can't repro on DOSBox-X" is a strong signal that an environment-specific concurrent input stream is part of the picture.**

### When you suspect a similar race elsewhere

Audit pattern: search for `Cli` blocks in `IT_MUSIC.ASM` / sound drivers, identify what they protect, then ask "if a MIDI byte buffered during this window, would the post-PopF dispatch into `MIDISend` re-enter state we just tore down?" The fix shape is the same in each case: a scoped suppress flag, set/clear via Far helpers, gated where `MIDISend` would otherwise call back.

## VRAM Debug Markers (standard hard-hang triage)

For hard hangs where the screen redraw machinery is dead, IT uses a direct B800h text-buffer poke as the diagnostic primitive — established in commit `3537c0d` (Ctrl-O WAV leave hang investigation) and replicated in `ec91331` (F3 loader keyjazz hang). The proc is ~20 lines:

```
Proc <Module>_DebugMark Near
        Push    AX / BX / ES
        Movzx   BX, AL              ; AL = col on row 0
        ShL     BX, 1
        Mov     AL, AH              ; AH = ASCII char
        Push    AX
        Mov     AX, 0B800h
        Mov     ES, AX
        Pop     AX
        Mov     AH, 4Fh             ; bright white on red
        Mov     [ES:BX], AX
        Pop     ES / BX / AX
        Ret
EndP
```

Existing instances: `WAV_DebugMark` in `IT_MUSIC.ASM:3798` (Ctrl-O markers cols 1-28), `D_DebugMark` in `IT_DISK.ASM` (loader keyjazz markers cols 30-39). When adding a new diagnostic, **use a fresh column range** so multiple investigations don't trample each other.

### Discipline rules

1. **Markers ship FIRST when a bug is non-deterministic or environment-dependent.** Speculative patches in IRQ-adjacent assembly risk worse hangs than the one being chased. Markers are read-only VRAM pokes — zero risk.
2. **Wrap each marker in PushF/PopF if any subsequent JC/JZ depends on the carry/zero flag.** The marker proc itself uses ShL which clobbers CF. Sites that follow `Int 21h` / `JC <err>` need the PushF/PopF wrapper.
3. **One letter per stage; document the marker map in the commit message.** "Last visible char = stage that wedged" is the protocol. The user reads the screen on hang and reports the letter; the fix follows.
4. **The markers stay in the tree even after the fix lands.** They cost a few bytes and zero runtime; the next layer of bug (if any) shows up the same way. Remove only when actively confusing.

## Pattern Editor Data Layout

For any pattern-data-touching feature (block ops, replicate, transpose, fill, etc.):

| Item | Value |
|------|-------|
| Pattern data segment | `PatternDataArea` (DW in Pattern segment data) — `Mov DS, PatternDataArea` |
| Row stride | **320 bytes** (= 64 channels × 5) |
| Channel stride | **5 bytes** (one event) |
| Byte offset for (row, channel) | `row * 320 + channel * 5` |
| Event size | 5 bytes: note, instrument, volume, command, command-data |
| Empty event | note=`NONOTE` (0FDh), instrument=0FFh, vol/cmd/data = 0 |
| Cursor row | `Row DW 0` in Pattern segment data |
| Cursor channel | `Channel DW 0` (0-based, 0..63) |
| Pattern length | `MaxRow DW ?` (= length-1; e.g. 63 for a 64-row pattern) |
| Block selection | `BlockMark DW`, `BlockLeft / BlockTop / BlockRight / BlockBottom DW` |
| Last cursor instrument | `LastInstrument DB` in IT_PE.ASM (F3/F4 cursor tracks this) |
| Constants | `NONOTE EQU 0FDh` |

### Undo

`PE_AddToUndoBuffer Far` in `IT_PE.ASM` (~line 11361) takes `DI = opaque category tag`. Snapshots the whole pattern into EMS or near-mem. Existing tags **1-22 are taken** (grep `^[[:space:]]*Mov[[:space:]]+DI,[[:space:]]*[0-9]+\s*$` in IT_PE.ASM for the table). Tag 23 was first used by `aaada5e` (Replicate at Cursor). Tag is purely a slot identifier — no name table indexes it.

### Network broadcast

After modifying any block region, call `NetworkPatternBlock Near` (`IT_PE.ASM:3145`) with `BL=channel, BH=row, CL=width, CH=height`. Inert when `NETWORKENABLED` is off; when on, sends the modified region to peers. Reference: `PEFunction_BlockHalve` (`IT_PE.ASM:6273`) shows the calling convention.

### Pattern segment register conventions

`IT_PE.ASM` starts with `Assume CS:Pattern, DS:Nothing`. Before switching `DS` to `PatternDataArea`, read all needed `Row` / `Channel` / `MaxRow` / `BlockTop` etc. into registers — once DS is `PatternDataArea`, those variables need a CS: override (`Cmp CX, CS:MaxRow`). Use BP for loop-invariant values; it's preserved through `Mul` (only DX is clobbered as the high half of the product).

## Keymap Dispatch & Modifier Disambiguation

### M_FunctionDivider's modifier codes (PE keymap, table 1)

`IT_M.ASM:168` (`M_FunctionDivider Far`) walks a key dispatch table. First byte per entry:

| DB | Meaning | Test |
|----|---------|------|
| 0 | direct compare against CX | (none) |
| 1 | key word compare against DX | (none) |
| 2 | Alt | `Test CH, 60h` |
| 3 | Ctrl | `Test CH, 18h` |
| 4 | Shift | `Test CH, 6` |
| 5 | capital-key compare | (alpha mask) |
| 6 | MIDI message | (special) |

Alt-letter keys have the scancode in the high byte, 00h low byte (e.g. `1300h` = Alt-R because R scancode is 13h, and Alt suppresses ASCII). The PE keymap's modifiers 2/3/4 are single-modifier only.

### IT_K.ASM scancode → key-word translation (table 2, upstream)

The K_TranslateKey3 chain in `IT_K.ASM:1314+` decides what 16-bit key word the keyboard ISR emits to the rest of IT. Conditions 0..10 in the original source:

| BL | Condition | Active when |
|----|-----------|-------------|
| 0  | keypress (any) | CH bit 0 only (no shift/ctrl/alt/caps) |
| 1  | Caps-on → check shift | (caps path) |
| 2  | no-shift | shift NOT held |
| 3  | Shift held | `CH & 6` set |
| 4  | Ctrl held | `CH & 18h` set, no shift |
| 5  | Alt held (either side) | `CH & 60h` set, no shift/ctrl |
| 6  | Left Alt | `CH & 20h` set, no shift/ctrl/right-alt |
| 7  | Right Alt | `CH & 40h` set, no shift/ctrl/left-alt |
| 8  | NumLock-on | (numlock path) |
| 9  | NumLock-off | (no numlock) |
| 10 | Alt + numeric (KeyPadValue) | Alt + digit aggregator |

**Critical upstream gotcha — Shift+Alt does NOT match Condition 5.** Condition 5's test is `Test CH, Not 61h` then `Test CH, 60h` — the first test REJECTS the entry if any bit outside `61h` (= Alt + Caps mask) is set. Shift bits (2, 4) fail that test, so when Shift is held *with* Alt, no Condition matches and **no key word is emitted at all**. This invalidates the older "Shift-Alt-R produces the same 1300h" hypothesis that lived in this skill before 2026-05-20 — testing on dosbox-x in `dosbox-test/` confirmed Shift-Alt-M produces nothing through the upstream dispatcher.

### Fork extension: Condition 11 = Shift + Alt (added 2026-05-20, `9fb5ac1`)

`IT_K.ASM` now extends K_TranslateKey3 with:

```
K_TranslateCondition11:                 ; Shift + Alt (any Alt side)
                                        ; CH bits: 1=R-shift, 2=L-shift,
                                        ;          20=L-alt, 40=R-alt,
                                        ;          1=Caps (mask Not 67h).
                Test    CH, Not 67h     ; reject if Ctrl/Insert/etc. held
                JNZ     K_TranslateKey3
                Test    CH, 6           ; shift must be held
                JZ      K_TranslateKey3
                Test    CH, 60h         ; alt must be held
                JZ      K_TranslateKey3
                Jmp     K_TranslateKeyEnd
```

…and a `DB 11; DW 3232h` row on the M scancode (line 555+) so Shift-Alt-M emits the fork-extension key word `3232h`. The PE keymap (`IT_PE.ASM`) binds `3232h` to `PEFunction_StartMultiWAVKey` which calls `Music_StartMultiWAV`.

**Why 3232h?** It's a fork-extension code that doesn't collide with anything in the upstream key-word space. Pattern: pick `<scancode><scancode>h` so the relationship to the source scancode is visible at a glance. Re-use the same convention for any future Shift-Alt-X binding.

### The Shift+Alt LIVE-state alternative (Alt-R style)

For combos where the upstream key word already matches (rare — see the gotcha above) OR where you want a single entry: bind a single key word to a dispatcher proc that queries the **live** shift state at handler entry via `K_IsKeyDown` (`IT_K.ASM:1526`). Reference: `PEFunction_AltR_Dispatch` in `IT_PE.ASM` (commit `aaada5e`).

```
Proc PEFunction_AltR_Dispatch Far
        Mov  BX, 02Ah                ; Left Shift scancode
        Call K_IsKeyDown
        JNE  <shift_branch>
        Mov  BX, 036h                ; Right Shift scancode
        Call K_IsKeyDown
        JNE  <shift_branch>
        Jmp  <plain_alt_branch>
<shift_branch>:
        Jmp  <other_handler>
EndP
```

`K_IsKeyDown` does `Cmp [CS:KeyboardTable+BX], 0` and returns with ZF set if NOT down. So `JNE` after the call jumps when the key IS held.

**This dispatcher pattern only works if the key word actually fires** — which means upstream Conditions 0..10 must match. For Shift-Alt-letter, that requires Condition 11 (fork) OR a key whose scancode IT_K.ASM treats as Alt-only regardless of Shift state. The original Alt-R commit assumed both Alt-R and Shift-Alt-R produced 1300h; that assumption was wrong (see gotcha above) and Shift-Alt-R only began working in `9fb5ac1` once Condition 11 + Shift-Alt-letter entries landed.

### Alt-R current binding (since `aaada5e`)

- **Alt-R** → `PEFunction_ReplicateAtCursor` (Paketti-style tile-down)
- **Shift-Alt-R** → `PEFunction_ClearViews` (original Alt-R behavior). Requires Condition 11 + a `DB 11; DW <code>h` row on the R scancode to actually fire — TODO add this entry; currently Shift-Alt-R appears bound but never dispatches.

### Alt-M / Shift-Alt-M current binding (since `9fb5ac1`)

- **Alt-M** (`DB 1; DW 3200h`) → `PEFunction_BlockMix` (upstream behaviour)
- **Shift-Alt-M** (`DB 1; DW 3232h`) → `PEFunction_StartMultiWAVKey` → `Music_StartMultiWAV` (fork: per-channel render of current pattern)

Two separate keymap entries — the Alt-R single-entry-dispatcher pattern doesn't apply because plain Alt-M and Shift-Alt-M emit DIFFERENT key words via the Condition 5 / Condition 11 split.

## Replicate at Cursor (Paketti port, Alt-R)

Algorithm reference: `~/work/ztrackerprime/src/CUI_Patterneditor.cpp:2581` (the C version that defines the semantics). Single-channel operation on the current `Channel`:

- If `Row > 0`: source chunk = rows `0..Row-1`, fill rows `Row..MaxRow` with `dest[j] = source[(j - Row) mod Row]`.
- If `Row == 0`: source chunk = row 0 itself (single row), fill rows `1..MaxRow` with copies of row 0.

Empty source events are copied through verbatim (mirror semantics). No-op if cursor is past `MaxRow` or if the dest range is empty.

Implementation: `PEFunction_ReplicateAtCursor` in `IT_PE.ASM` (commit `d506486`, row-0 boundary in `aaada5e`).

## Multi-WAV / Whole-Song Export (since `9fb5ac1`)

Three entry points, one state machine, three filename strategies.

### Entry points

| Trigger | Where | Mode | Filename |
|---------|-------|------|----------|
| **Shift-Alt-M** | F2 keymap (PE) | per-channel render of *current pattern* | auto: `<PFX><CHAN>.<PPP>` |
| **F10 "WAV" button** | `IT_OBJ1.ASM` SaveFormat=4 | whole song to single WAV | user-typed (e.g. `song.wav` → `SONG.WAV`) |
| **F10 "MWAV" button** | `IT_OBJ1.ASM` SaveFormat=5 | whole song per channel | user-typed + 2-digit channel suffix (e.g. `song.wav` → `SONG01.WAV` … `SONG<NN>.WAV`) |

### State machine (`IT_MUSIC.ASM`)

```
Music_StartMultiWAV (or Music_StartFullSongMWAV with SongFlag=1)
   ↓ backup MuteChannelTable → WAV_MultiSavedMutes
   ↓ WAV_MultiMode = 1, WAV_MultiChannel = 0FFh
   ↓ Call WAV_MultiAdvance
WAV_MultiAdvance
   ↓ Inc WAV_MultiChannel
   ↓ skip if muted in original mix (WAV_MultiSavedMutes[chan] != 0)
   ↓ pattern-mode only: skip if PE_ChannelIsEmpty (no playable notes
   ↓                    in PatternDataArea — only counts notes 0..119)
   ↓ song-mode: SKIP the emptiness check; only mute decides
   ↓ Call WAV_MultiKickChannel
WAV_MultiKickChannel
   ↓ solo channel (MuteChannelTable: all 1 except target = 0)
   ↓ re-arm WAV_NoImport = 1 (leave-mode clears it)
   ↓ re-arm WAV_SongMode = WAV_MultiSongFlag
   ↓ if WAV_UserBase non-empty: WAV_BuildChannelFilename for THIS chan,
   ↓                            re-arm WAV_UserFilenameSet
   ↓ Call Music_ToggleWAVRender (= enter mode)
Music_PlaySong (or Music_PlayPattern) runs
Music_Poll watches PlayMode for transition to 0
   ↓ WAV_FinalizeDelay counts up 3 frames after PlayMode=0
   ↓ Call Music_ToggleWAVRender (= leave mode)
   ↓ Multi check: if WAV_MultiMode, Call WAV_MultiAdvance → next channel
```

The chain self-terminates when WAV_MultiChannel reaches 64. `WAV_MultiFinish` restores the saved mute table, clears flags, posts status.

### Esc abort

`Music_Poll` polls `K_IsKeyDown(01h)` (Esc scancode) every tick — when the user holds Esc during a multi-WAV sweep, `WAV_MultiMode` is cleared and the saved mute state is restored immediately. The in-flight render finishes normally (since the chain only resets the "next channel" pointer, not the current render). Use `K_IsKeyDown`, NOT `Int 16h AH=01h` — IT's own dispatcher consumes the keyboard queue before `Music_Poll` runs.

### `WAV_SongMode` flag

When set, `Music_ToggleWAVRender`'s enter-mode path swaps `Music_PlayPattern` for `Music_PlaySong(0)` so the whole song plays from order 0 instead of a single pattern. Filename extension in song-mode is `.WAV` (not the 3-digit pattern number). Cleared on leave-mode; re-armed per kick in `WAV_MultiKickChannel`.

### `WAV_UserFilenameSet` flag

Set by `D_CopyUserFilenameToFileName` (in `IT_DISK.ASM`) before the F10 save path kicks the render. Tells `Music_ToggleWAVRender` to skip the auto-rename block (which would otherwise stamp `WAV_RenderBasename` over the user's typed filename in `FileName`). Also drives `RenderedFilename` to mirror `FileName` so the post-render status message reflects reality. Cleared on leave-mode; re-armed per kick in `WAV_MultiKickChannel` via `WAV_BuildChannelFilename`.

### Filename construction

- **Auto-naming** (Shift-Alt-M without F10 user input, or upstream Ctrl-O): `<PFX><NNNN>.<PPP|.WAV>` where `<PFX>` is the first 3 chars of the song name uppercased + sanitized, `<NNNN>` is the 4-digit render counter, `<PPP>` is the pattern number for single-pattern renders or `.WAV` for song-mode.
- **User-named** (F10 WAV button): copy `SaveFileName` straight into `FileName` and skip the auto-rename. `song.wav` → `SONG.WAV`.
- **User-named, per-channel** (F10 MWAV button): `WAV_BuildChannelFilename` parses `WAV_UserBase`, truncates the base to 6 chars if needed, inserts the 2-digit 1-based channel number before the `.`, defaults extension to `.WAV` if none in base. `song.wav` → `SONG01.WAV`, `SONG02.WAV`, …, `SONG<NN>.WAV`.

### Why song-mode bypasses `PE_ChannelIsEmpty`

`PE_ChannelIsEmpty` scans `PatternDataArea`, which is the *editor's currently-loaded pattern only*. For Shift-Alt-M (current-pattern mode), that's the right buffer. For whole-song MWAV, the song plays many patterns and a channel that's empty in pattern 0 can still have notes in pattern 17 — using the editor buffer would wrongly skip those channels. Decoding every pattern in the orderlist to do a song-wide emptiness check is deferred; song-mode currently skips only on `WAV_MultiSavedMutes` (user's saved mute state).

### F10 dispatch fixes (also in `9fb5ac1`)

Three places needed teaching about SaveFormat 4 / 5 — and missing any one of them silently routes WAV/MWAV through the IT-module save path (so `song.wav` saves as IT-2.354 with a `.WAV` extension):

- `D_SaveModule` (filename-Enter path): append `.WAV` if `SaveFormat in {4,5}`, else `.IT` / `.S3M`.
- `D_PostFileSaveWindow3` (actual save dispatcher reached via `D_SaveModule`'s Jmp): `SaveFormat == 4` → `Music_StartFullSongWAV`, `== 5` → `Music_StartFullSongMWAV`.
- `D_SaveSong` (Ctrl-S Quicksave path): same dispatch as above.

If WAV/MWAV ever silently saves as a module again, check those three sites first.

### Diagnostic-when-it-fails

- Status message says "Saved pat NNN as `<filename>`" but the file isn't there → check `D_GotoRenderDirectory`'s cd target (Quicksave folder if non-empty, else SampleDirectory, else cwd) — the file lives there.
- MWAV renders only 1 or 2 files → in song-mode this is correct iff only 1-2 channels have notes that survive the empty-check. In pattern-mode, this points at a `PE_ChannelIsEmpty` mismatch (the editor is on a different pattern than the user expects).
- MWAV renders all 64 files → `WAV_MultiSongFlag` got stuck; check the leave-mode clearing path.
- MWAV files overwrite each other (only 1 file ends up on disk with the last channel's audio) → `WAV_UserBase` lost its first byte (= dispatch path failed to call `Music_SetUserBase`), the per-channel filename build was skipped.

## Regression Bisect — "Oh no I committed a booboo"

When a feature that used to work suddenly hangs/breaks, walk the commit history of the actually-changed files, not the whole repo log:

```bash
git log --oneline -- <suspect-file.asm>
```

For each candidate commit, inspect the diff for real code changes — **not encoding noise**:

```bash
git show --stat <commit>                          # size signal
git show <commit> -- <file> \
  | LC_ALL=C grep -E '^[+-]' \
  | grep -vE '^[+-]{3}|^[+-][[:space:]]*$|^[+-];'  # strip headers, blanks, comments
```

### The encoding-noise trap

`.gitattributes` (commit `fc92c77`) locks `*.ASM` and `*.INC` to ISO-8859-1 + CRLF, but commits made by tools/agents that don't honor `.gitattributes` re-encode the cp437 box-drawing characters (`╔ ═ ╗ ║ ╚ ╝ ─ │ ┌` etc) into UTF-8 replacement sequences. The actual code is untouched but `git show --stat` reports hundreds of insertions/deletions because every comment-header line "changed."

**Example:** Commit `3537c0d` reports 265 insertions / 168 deletions. Filtering the diff to non-comment, non-header, non-blank lines reveals the actual change is the `WAV_DebugMark` proc + ~20 marker call sites — maybe 80 lines. The rest is round-trip encoding damage.

Always filter diffs before drawing bisect conclusions. A massive `--stat` against a "fix typo" commit message almost certainly means encoding noise, not hidden behavior change.

### "Did you identify the regressing commit?" — honest accounting

If static audit shows **no fork commit modified the path in question**, say so plainly. Don't fabricate a culprit. The honest answer is often:

> "Audited every fork commit touching <file>. None edited the suspect proc. The only indirect candidates are <list>, and the next repro / marker letter will tell us which."

Per CLAUDE.md's "completion-framing-is-lying" rule: naming a regressing commit you can't verify destroys debugging trust more than admitting uncertainty.

## Diagnostic-vs-Fix Discipline

For hard hangs in IRQ-adjacent assembly, the protocol is two-step:

1. **First commit: instrumentation only.** VRAM markers around every plausible wedge site. Ship, user repros, reports last visible letter.
2. **Second commit: targeted fix at the wedge site.** Markers stay in for future regressions.

Do **not** combine "I think this fixes it + here's some markers in case it doesn't" into one commit. The instrumentation has a clean rollback story; the speculative fix doesn't. When the letter on the screen confirms the wedge, the fix becomes obvious and small. Until then, anything labeled "fix" is a guess.

This discipline applies specifically to environment-dependent bugs (e.g. only repros with external MIDI clock running). For DOSBox-X-reproducible bugs you can iterate normally — the loop is fast enough to skip the marker phase.

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

## F11 Order List Fork Ops (since `1a7aa16` / `90cfd04`)

Six new key bindings on the F11 order list screen, all keyed off the "active
pattern" abstraction — engine's `CurrentPattern` if `PlayMode != 0`, else the
order-cursor's pattern byte at `SongData+256+Order`. Resolution helper:
`PE_OrderList_ResolvePattern` (Near in IT_PE.ASM), returns `AX = pattern,
CF=0` or `CF=1` if no valid pattern (cursor on `0xFE` skip / `0xFF`
end-of-list marker while stopped).

### Keymap additions to OrderListKeys (`IT_PE.ASM`):

| Entry | Modifier code | Key word | Handler | What |
|-------|---------------|----------|---------|------|
| Plain `G` | 5 (capital) | `'G'` | `PE_OrderList_GDispatch` | Tail-jumps to original `PE_PostOrderList24` (goto pattern) when shift NOT held; else falls into render-import path. Tail-jump preserves caller state (AX=Order, ES=SongData, DS=Pattern). |
| Plain `M` | 5 (capital) | `'M'` | `PE_OrderList_ToggleMuteWipe` | Toggles `ClonePatternMuteWipe` flag with info-line confirmation. |
| Ctrl-O | 1 (key) | `0Fh` | `PE_OrderList_RenderDispatch` | Shift-aware via K_IsKeyDown(2Ah/36h). Shift held → arms `WAV_NoImport`; else clears. Then resolves pattern and `Music_ToggleWAVRender`. |
| Ctrl-G | 1 (key) | `07h` | `PE_OrderList_RenderQuicksave` | Always arms `WAV_NoImport`. Render to Quicksave, no auto-import. |
| Alt-D | 1 (key) | `2000h` | `PE_OrderList_ClonePattern` | Clone active pattern to first free slot. Respects M-toggle. |
| Alt-E | 1 (key) | `1200h` | `PE_OrderList_ExtendPattern` | Extend active pattern in place by doubling rows. Bails if 2*N > 200. |
| Left | 0 (direct) | `1CBh` | `PE_OrderList_LeftDispatch` | At OrderCursor=0: clone (shift = mute-wipe BL=1, plain = verbatim BL=0). Else tail-jumps to `PE_PostOrderList7` (normal wrap). |
| Right | 0 (direct) | `1CDh` | `PE_OrderList_RightDispatch` | At OrderCursor=2: tail-jumps to `PE_OrderList_RenderDispatch` (shift-aware). Else tail-jumps to `PE_PostOrderList9` (normal wrap). |

### Clone pipeline

Three entry points:

- `PE_OrderList_ClonePattern Far` — Alt-D. Reads `ClonePatternMuteWipe` flag
  → BL → jumps to body.
- `PE_OrderList_ClonePatternModal Far` — cursor-key dispatchers set BL
  explicitly (0 = verbatim, 1 = wipe) and jump to body.
- `PE_OrderList_ClonePattern_Body Far` (label `PE_OrdClonePat_Body`) — actual
  implementation; latches BL into `CS:[PE_CloneWipeMode]` static byte at
  entry so the wipe choice survives across `PE_SaveCurrentPattern` /
  `NewPattern` register trashing.

Body sequence:

1. `ResolvePattern` → S (source). `Music_FindFreePattern` → T (target).
2. `PE_SaveCurrentPattern` (save editor's current state back to its slot).
3. Stash original `PatternNumber` into `CS:[PE_CloneOriginalPat]`.
4. `PatternNumber = S`, call `NewPattern` (decodes S into `PatternDataArea`).
5. If `[PE_CloneWipeMode] != 0`: call `PE_OrderList_ApplyMuteWipe`.
6. `PatternNumber = T`, `PatternModified = 1`, call `PEFunction_StorePattern`
   (encodes `PatternDataArea` into slot T's storage).
7. Info line "Pattern cloned to slot N".
8. Restore editor: `PatternNumber = original`, `NewPattern`.

Mid-playback safety: `PEFunction_StorePattern` does ClI/StI bracket around
`Music_ReleasePattern` + `Music_AllocatePattern` + `EncodePattern`, so the
mixer is masked during the buffer swap.

### Mute-wipe semantics (`PE_OrderList_ApplyMuteWipe`)

Iterates `MuteChannelTable` (64 bytes, 1 = muted, 0 = active) via the new
Far accessor `Music_GetMuteChannelTable` (returns ES:DI). For each muted
channel C (offset 0..63):

- Row 0 of column C: writes note-cut event `(0FEh, 0, 0FFh, 0, 0)` — the
  `^^^` marker. Silences any sample still ringing from the previous
  pattern.
- Rows 1..MaxRow of column C: writes empty event
  `(NONOTE=0FDh, 0, 0FFh, 0, 0)`.

Single-row patterns (MaxRow == 0): `PE_OrdWipe_OneRowOnly` fast-path skips
the rows-1..MaxRow loop entirely.

After encode, `GetPatternLength` reflects the smaller compressed size
(wiped channels compress away), so the target slot allocation matches.

### Extend pipeline (`PE_OrderList_ExtendPattern`)

In-place: source pattern S itself is re-encoded with doubled row count.

1. `ResolvePattern` → S. Save editor state. Stash original.
2. Load S into editor buffer via `NewPattern`.
3. Bounds check: `MaxRow > 99` → bail (`ExtendTooLongMsg`), restore editor.
4. Word-copy 320-byte rows 0..MaxRow into rows MaxRow+1..2\*MaxRow+1
   inside `PatternDataArea` (ES = DS = PatternDataArea segment).
5. Update `MaxRow = 2*MaxRow + 1`, `NumberOfRows = MaxRow+1`.
6. `PatternModified = 1`, `PEFunction_StorePattern` saves doubled pattern
   back to S. Mid-playback safe via the ClI bracket.
7. Info line "Pattern extended to N rows".
8. Restore editor's original pattern via `NewPattern`.

### New Music-side helpers

| Proc | What | Source |
|------|------|--------|
| `Music_FindFreePattern Far` | Walks pattern entry table at `SongData+63912` (4 bytes per slot, byte 0 = type, 0=free) for slots 0..199. CF=0/AX=slot on success, CF=1 if all used. | `IT_MUSIC.ASM` |
| `Music_GetMuteChannelTable Far` | Returns `ES:DI` -> 64-byte `MuteChannelTable` (Music segment). | `IT_MUSIC.ASM` |
| `Music_ArmRenderNoImport Far` | Sets `WAV_NoImport = 1` (cross-segment setter). | `IT_MUSIC.ASM` |
| `Music_ClearRenderNoImport Far` | Sets `WAV_NoImport = 0`. | `IT_MUSIC.ASM` |
| `Music_InstrumentHasEnvelopes Far` | AX = instrument#. Compares bytes 130h..554 of the live instrument header (envelope section, 250 bytes) against the default `InstrumentHeader` template. ZF=1 if all match (default-blank), ZF=0 if any byte differs (custom envelope present). | `IT_MUSIC.ASM` |

## F12 Samples → Instruments envelope preservation (since `d8ec842`)

`F_SetControlInstrument` (IT_F.ASM:4831) — the F12 mode-flip handler called
when user toggles Instruments mode ON via the F12 config screen. Previously
called `Music_ClearAllInstruments` unconditionally if the user clicked
"Initialize Instruments = YES", wiping every Vol/Pan/Pitch/Filter envelope.
The `4e4eb9a` fix defaulted the dialog focus to "No" but didn't gate the
destructive path itself; `d8ec842` is the actual gate.

New behaviour: walks 0..98 instruments, calls `Music_InstrumentHasEnvelopes`
per slot. If ZF=0 (envelope bytes differ from default template), the slot is
preserved entirely — no clear, no sample-name copy, no 120-note keymap fill,
no network broadcast. Slots with default envelopes get the original clear +
re-init treatment, so "Initialize Instruments = YES" still does the
expected thing on blank instruments.

## Ctrl-O Render Pipeline (Quicksave routing, path safety, no-import)

### Render destination resolution

New `D_GotoRenderDirectory Far` in IT_DISK.ASM (since `97712ce` / hardened
in `a98a37c`). Priority order:

1. `QuickSaveDirectory` if configured — cross-machine handoff target.
2. `SampleDirectory` if Quicksave is empty — preserves legacy behaviour.
3. Both empty — no-op, render lands in current cwd.

Implementation inlines `Int 21h AH=3Bh` chdir + drive-letter parse rather
than delegating to `D_SetDriveDirectory` (which swallows the chdir error).
Returns CF=0 on success, CF=1 if a path was configured but chdir failed
(invalid drive letter, missing directory, etc.). POP r16 preserves CF, so
the return state survives the proc's register-restore epilogue.

### Pre-flight validation (`Music_ToggleWAVRender` enter-mode)

Try-and-revert pattern: `D_SaveCwd` + `D_GotoRenderDirectory` (with PushF)
+ `D_RestoreCwd` + PopF + JC. If CF=1, jumps to `WAV_PreflightBadPath`
which surfaces "Render aborted: Quicksave folder invalid (check F12)"
WITHOUT touching audio state (Music_Stop / driver swap haven't fired yet).
Sound stays running.

### No-import variant (Shift-Ctrl-O, Ctrl-G in F11, etc.)

Two flags in IT_MUSIC.ASM:

- `WAV_NoImport DB 0` — armed by the dispatcher right before
  `Music_ToggleWAVRender`. Plain Ctrl-O calls `Music_ClearRenderNoImport`,
  Shift-Ctrl-O calls `Music_ArmRenderNoImport`.
- `WAV_SessionNoImport DB 0` — latched at enter-mode (`Mov AL,
  [WAV_NoImport] / Mov [WAV_SessionNoImport], AL`). Consumed in leave-mode
  to gate the `Music_ImportRenderedPattern` call.

The two-flag setup makes Ctrl-O/Shift-Ctrl-O toggles symmetric: pressing
either variant to LEAVE render mode honours whichever variant ENTERED it.

### Re-cd before import open

`Music_ImportRenderedPattern` calls `D_GotoRenderDirectory` once more right
before its `Int 21h AH=3D00h` Open. The driver swap in `WAV_LeaveMode`
(`Music_AutoDetectSoundCard`, `Music_SoundCardLoadAllSamples`) was leaving
cwd in a stale state between WAVDRV's write and the import's read,
masquerading as "cannot open .NNN file". Distinct error label
`WAVI_RenderDirFailed` surfaces if this second cd fails.

### Diagnostic markers (build `18e8da4`)

- **Row 0 col 25-26**: `d` = D_GotoRenderDirectory attempted (re-cd),
  `e` = chdir succeeded.
- **Row 0 col 27**: which WAV header validation rejected the file —
  `R` = RIFF magic at offset 0,
  `W` = WAVE magic at offset 8,
  `P` = PCM format code at offset 20 (expected 1),
  `F` = fmt chunk size at offset 16 (expected 16),
  `+` = all 4 passed.
- **Row 0 col 40-42** (F2 Ctrl-O dispatcher only):
  col 40 `X` = handler entered,
  col 41 `p`/`s` = plain/shift branch,
  col 42 `L`/`R`/`-` = which shift key K_IsKeyDown saw.

`WAV_HoldForMarkers` polls `Int 16h AH=01h` every iteration of its
~15-second timeout loop and breaks on any keystroke (consumed via
`AH=00h`). The hold runs only on import-failure paths so successful
renders return at normal speed.

## F2-F2 Default New-Pattern Length (since `068648f`)

The existing Pattern Edit Config dialog (`O1_PEConfigList`) has a "Number
of rows in pattern" field bound to `NumberOfRows`. After the dialog closes
in `Glbl_F2_1` (IT_G.ASM), the new code latches `NumberOfRows` →
`DefaultNewPatternLength` (DW in IT_PE Pattern segment) and calls
`D_SaveDirectoryConfiguration` to persist immediately.

`NewPattern` (IT_PE.ASM, the F2 pattern-load wrapper) gains a
post-`DecodePattern` hook: `NewPattern_ApplyDefaultLength` reads the
pattern entry table at `SongData+63912+slot*4`. If the type byte is 0
(slot empty → `DecodePattern` just pulled in the static `EmptyPattern`'s
64-row default), `MaxRow` is overridden from `DefaultNewPatternLength`
(clamped 32..200, falls back to 64 if the persisted value is zero —
defensive against an IT.CFG read that returned no bytes).

Allocated patterns (type byte != 0) are NOT touched — their stored
`MaxRow` is preserved.

## IT.CFG layout (with fork extension)

IT.CFG is a binary file read in `D_InitDisk` and written by
`D_SaveDirectoryConfiguration`. Each block is read/written sequentially
with a fixed byte count.

| Offset | Bytes | Block | Source |
|-------:|------:|-------|--------|
| 0 | 211 | SongDirectory + SampleDirectory + InstrumentDirectory + keyboard table | `IT_DISK.ASM:SongDirectory` |
| 211 | 48 | Palette (3*16) | `S_GetPaletteOffset` |
| 259 | 50 | Display window data | `Display_GetDisplayWindowData` |
| 309 | 218 | Pattern config (KeySignature → Flags) | `PE_GetPatternConfigOffset` |
| 527 | 810 | Preset envelopes | `I_GetPresetEnvelopeOffset` |
| 1337 | 70 | QuickSaveDirectory (fork addition) | `IT_DISK.ASM:QuickSaveDirectory` |
| **1407** | **16** | **PE_ForkExtConfig (fork addition since `068648f`)** | `PE_GetForkExtConfigOffset` |

Total: 1423 bytes after fork extension.

### PE_ForkExtConfig block layout (16 bytes)

| Offset | Width | Variable | Purpose |
|-------:|------:|----------|---------|
| 0 | DW | `DefaultNewPatternLength` | 32..200, default 64. New-empty-pattern row count. |
| 2 | DB | `ClonePatternMuteWipe` | 0 / 1, default 1. F11 `M` toggle for Alt-D clone behaviour. |
| 3 | DB | `MIDIStopOnF8PersistOff` | **FORCE-OFF sense**: 0 = "Send MIDI Stop on F8" ON (default), nonzero = OFF. Mirror of the Keyboard-segment `MIDIStopOnF8Enable`; synced at load (`D_InitDisk` → `MIDI_SetF8StopEnable`) and save (`D_SaveDirectoryConfiguration` reads `MIDI_F8StopEnabled`). Since `222962f`. See `features/midi-out-stop-on-f8.feature`. |
| 4..15 | DB 12 Dup(0) | reserved | Future fork extensions land here without IT.CFG breakage. |

Backward compatibility: older IT.CFG files (pre-`068648f`) don't have the
trailing 16 bytes. The read at boot falls short, the static defaults in
IT_PE.ASM (`DefaultNewPatternLength=64`, `ClonePatternMuteWipe=1`,
`MIDIStopOnF8PersistOff=0`) stay in effect, and the next
`D_SaveDirectoryConfiguration` writes IT.CFG with the block appended.
Forward-compatible by design. **The +3 byte uses force-off sense precisely so
that pre-`222962f` IT.CFGs — which wrote that byte as a reserved zero — decode
to ON, not a surprise OFF.**

Accessor: `PE_GetForkExtConfigOffset Far` (IT_PE.ASM), returns
`DS:DX -> PE_ForkExtConfig`.

## Quick Reference

| Item | Value |
|------|-------|
| Source Platform | GitHub |
| Primary Language | Assembly (TASM 4.1 syntax, 16-bit + .386P) |
| Default Branch | main |
| License | BSD-3-Clause |
| Upstream | jthlim/impulse-tracker (read-only) |
| Your fork | esaruoho/impulse-tracker |
| Encoding | `.gitattributes` locks *.ASM/*.INC to ISO-8859-1 + CRLF |
| Local build | `dosbox-x -conf buildall.conf -fastlaunch -exit -nogui -nomenu` (~57s on M1) |
| TASM/TLINK/MAKE | `tools-local/` (TLINK 3.01 required, NOT 7.1 — see CLAUDE.md) |
| MIDI-in entry point | `IT_K.ASM` ~line 1839 `Proc MIDISend Far` (now includes RT intercept) |
| MIDI sync suppress | `MIDISyncLoaderSuppress` (IT_K.ASM Keyboard segment); set/clear via Far helpers |
| Loader keyjazz path | `IT_DISK.ASM` `D_PostLoadSampleWindow` line ~5854 |
| LoadSample proc | `IT_DISK.ASM` ~line 7070-7181, calls `Music_Stop` at ~7090 |
| Music_Stop Cli window | `IT_MUSIC.ASM` ~6625-6750 (do NOT re-enter playback from buffered MIDI) |
| Sample pointer trampoline | `Music_UpdateSampleLocation` `IT_MUSIC.ASM:6375` (vector to Int 3) |
| Pattern data segment | `PatternDataArea` (320 bytes/row, 5 bytes/event) |
| Pattern editor cursor | `Row DW`, `Channel DW`, `MaxRow DW` (IT_PE.ASM data) |
| Order list cursor | `OrderCursor DW` (digit position 0/1/2 inside cell), `Order DW` (row in list) |
| Undo entry | `PE_AddToUndoBuffer` IT_PE.ASM ~11361, tags 1-23 used |
| Network broadcast | `NetworkPatternBlock` IT_PE.ASM:3145 (BL=ch, BH=row, CL=w, CH=h) |
| Alt-R dispatcher | `PEFunction_AltR_Dispatch` (plain → Replicate, shift → ClearViews) |
| Ctrl-O dispatcher | `PEFunction_RenderPattern` (shift-aware: plain = import, shift = Quicksave-only) |
| F11 order-list dispatchers | `PE_OrderList_LeftDispatch` / `RightDispatch` / `GDispatch` / `RenderDispatch` / `RenderQuicksave` / `ClonePattern` / `ClonePatternModal` / `ExtendPattern` / `ToggleMuteWipe` (all in IT_PE.ASM) |
| Active-pattern resolver | `PE_OrderList_ResolvePattern` (Near, returns AX = pattern, CF=ok/fail) |
| Pattern allocator | `Music_AllocatePattern` (SI=slot, DX=byte length); `Music_FindFreePattern` for next free slot |
| Mute table | `MuteChannelTable DB 64 Dup(?)` at `IT_MUSIC.ASM:302`; cross-segment via `Music_GetMuteChannelTable` |
| Empty event template | `EmptyRow DB 64 Dup(NONOTE, 0, 0FFh, 0, 0)` (IT_PE.ASM); note-cut variant = `0FEh` instead of NONOTE |
| Fork persisted config | `PE_ForkExtConfig` 16-byte block in `IT_PE.ASM` (DefaultNewPatternLength + ClonePatternMuteWipe + 13 bytes reserved); accessor `PE_GetForkExtConfigOffset` |
| IT.CFG total size | 1423 bytes (1407 stock + 16 fork ext) |
| VRAM marker procs | `WAV_DebugMark` IT_MUSIC.ASM (cols 1-28 leave, 20-23 import, 25-27 fork validation), `D_DebugMark` IT_DISK.ASM (cols 30-39 loader), `PE_RenderDebugMark` IT_PE.ASM (cols 40-42 dispatcher) |
| Driver↔host table | `SoundDrivers/REQPROC.INC` + `IT_MUSIC.ASM:716-742` |
| WAV render flags | `WAV_RenderMode` (0=idle, 1=rendering), `WAV_NoImport` (armed by dispatcher), `WAV_SessionNoImport` (latched at enter, read at leave) |
| WAV hold proc | `WAV_HoldForMarkers` (IT_MUSIC.ASM), key-dismissable 15s timeout via Int 16h AH=01h |
| Last Analyzed | 2026-05-19 |
