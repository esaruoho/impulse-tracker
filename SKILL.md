---
name: impulse-tracker
description: Development skill for Jeffrey Lim's Impulse Tracker DOS source — TASM/TLINK assembly tracker. Fork (esaruoho/impulse-tracker) adds external MIDI sync (Start/Stop/Continue + F8 Clock), driver-level F8-FF passthrough across 16 sound drivers, Ctrl-O WAV render + auto-import (P3), F3 loader keyjazz hang fix via MIDISyncLoaderSuppress, Alt-R Replicate at Cursor (Paketti port), Quicksave folder, F12 Module Directory picker, MIDI Monitor (Shift-F1). VRAM debug markers established as standard hard-hang triage tool.
domain: repository-specific
version: 1.1.0
generated: 2026-05-12
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

### Music_Stop's Cli window (the load-bearing detail)

`IT_MUSIC.ASM` `Music_Stop` does `Cli` at ~line 6625 and holds it through `PopF` at ~line 6750 while:
- walking SlaveChannelInformationTable for MIDI-out STOPNOTE / STOP via `MIDITranslate`
- zeroing HostChannelInformationTable + SlaveChannelInformationTable
- writing MIDIPrograms = 0xFFFF
- calling `Music_InitTempo` + `MIDI_ClearTable`

While that Cli is held, **the CPU's IRQ line is masked but the sound card UART hardware keeps buffering incoming MIDI bytes into its FIFO**. When `PopF` releases interrupts, the driver's Poll routine eventually drains the buffered bytes through `[UARTSend]` → `MIDISend`. Any FA/FC/FB that was buffered during the Cli window fires its callback after the fact.

This is the load-bearing detail behind the **F3 loader keyjazz hard hang**:

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
- `IT_DISK.ASM` `D_PostLoadSampleWindow` keyjazz branch calls `MIDI_SetLoaderSuppress` before `LoadSample`, and the common-exit label `D_PostLoadSampleWindow4` always calls `MIDI_ClearLoaderSuppress` before `Ret` — idempotent so non-keyjazz iterations are cheap.

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

### M_FunctionDivider's modifier codes

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

Alt-letter keys have the scancode in the high byte, 00h low byte (e.g. `1300h` = Alt-R because R scancode is 13h, and Alt suppresses ASCII). The modifiers 2/3/4 are **single-modifier only** — there is no combined Shift+Alt or Ctrl+Alt encoding in the dispatcher.

### The Shift+Alt disambiguation trick

Alt-R and Shift-Alt-R produce the same key word `1300h` (Shift doesn't change R's scancode; Alt already nulls the ASCII). To distinguish them: bind `1300h` to a dispatcher proc that queries the **live** shift state at handler entry via `K_IsKeyDown` (`IT_K.ASM:1526`). Reference: `PEFunction_AltR_Dispatch` in `IT_PE.ASM` (commit `aaada5e`).

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

`K_IsKeyDown` does `Cmp [CS:KeyboardTable+BX], 0` and returns with ZF set if NOT down. So `JNE` after the call jumps when the key IS held. Use the same pattern for any Alt-letter binding that needs Shift-Alt-letter to mean something different.

### Alt-R current binding (since `aaada5e`)

- **Alt-R** → `PEFunction_ReplicateAtCursor` (Paketti-style tile-down)
- **Shift-Alt-R** → `PEFunction_ClearViews` (original Alt-R behavior)

Single keymap entry (`DB 1 / DW 1300h / DW Offset PEFunction_AltR_Dispatch`), dispatcher fans out at runtime.

## Replicate at Cursor (Paketti port, Alt-R)

Algorithm reference: `~/work/ztrackerprime/src/CUI_Patterneditor.cpp:2581` (the C version that defines the semantics). Single-channel operation on the current `Channel`:

- If `Row > 0`: source chunk = rows `0..Row-1`, fill rows `Row..MaxRow` with `dest[j] = source[(j - Row) mod Row]`.
- If `Row == 0`: source chunk = row 0 itself (single row), fill rows `1..MaxRow` with copies of row 0.

Empty source events are copied through verbatim (mirror semantics). No-op if cursor is past `MaxRow` or if the dest range is empty.

Implementation: `PEFunction_ReplicateAtCursor` in `IT_PE.ASM` (commit `d506486`, row-0 boundary in `aaada5e`).

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
| Undo entry | `PE_AddToUndoBuffer` IT_PE.ASM ~11361, tags 1-23 used |
| Network broadcast | `NetworkPatternBlock` IT_PE.ASM:3145 (BL=ch, BH=row, CL=w, CH=h) |
| Alt-R dispatcher | `PEFunction_AltR_Dispatch` (plain → Replicate, shift → ClearViews) |
| VRAM marker procs | `WAV_DebugMark` IT_MUSIC.ASM:3798 (cols 1-28), `D_DebugMark` IT_DISK.ASM (cols 30-39) |
| Driver↔host table | `SoundDrivers/REQPROC.INC` + `IT_MUSIC.ASM:716-742` |
| Last Analyzed | 2026-05-12 |
