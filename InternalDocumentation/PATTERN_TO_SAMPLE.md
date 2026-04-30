# Pattern-to-Sample (Ctrl-O) — Design Notes

This document captures the architecture for the planned Ctrl-O "render
current pattern into a new sample slot" feature, based on a reverse-
engineering pass over the equivalent feature in [SchismTracker](https://github.com/schismtracker/schismtracker)
(`/Users/esaruoho/work/schismtracker` at commit `d2c8a49e`).

## Phased rollout

| Phase | Scope | Status |
|-------|-------|--------|
| **P1** | Bind Ctrl-O in pattern editor → calls existing pattern-render path (same as F6). When the user is running the WAV-writer driver (`ITWAV.DRV`), this writes `<song>.NNN`. When running a real audio driver, it just plays the pattern. | ✅ Implemented |
| **P2** | Auto-swap to WAVDRV → render → swap back to user's previous driver. Removes the requirement to be "in WAV mode" first. | Planned |
| **P3** | After render: load the resulting `<song>.NNN` PCM into the next free sample slot, optionally create an instrument that points at it, and tag the sample so re-renders are detected. | Planned |

## Schism reference implementation

### Key binding
- **File:** `schism/page_patedit.c:4147-4151`
- **Key:** `SCHISM_KEYSYM_o` (or fallback `SCHISM_KEYSYM_b`)
- **Modifier:** `SCHISM_KEYMOD_CTRL` (gated by `pattern_editor_handle_ctrl_key`)
- **Shift modifier** toggles "split mode" (per-channel multi-sample export)
- **Handler:** `song_pattern_to_sample(int pattern, int split, int bind)` in
  `schism/disko.c:1136`

### Algorithm (from `disko.c:1136-1179`)

```c
void song_pattern_to_sample(int pattern, int split, int bind) {
    // 1. Validate
    if (pattern < 0 || pattern >= MAX_PATTERNS) return;

    // 2. Detect already-linked: a sample is "bound" to pattern N if
    //    name[23] == 0xFF && name[24] == N. If found, abort.
    for (n = 1; n < MAX_SAMPLES; n++) {
        song_sample_t *samp = song_get_sample(n);
        if (samp->name[23] == 0xFF && samp->name[24] == pattern) {
            status_text_flash("Pattern %d already linked to sample %d", ...);
            return;
        }
    }

    // 3. Choose destination: current selected sample slot (default 1)
    int samp = sample_get_current() ?: 1;

    // 4. Confirm if non-empty, otherwise render directly
    if (current_song->samples[samp].data == NULL) {
        pat2smp_single(ps);
    } else {
        dialog_create(DIALOG_OK_CANCEL,
                      "This will replace the current sample.",
                      pat2smp_single, ...);
    }
}
```

### Render core (`disko_writeout_sample`, `disko.c:646-690`)

The actual offline render:

1. Lock audio playback
2. Shadow-copy `current_song` → `dwsong`
3. Stub MIDI sink (`_disko_midi_out_raw`) so MIDI Out doesn't fire
4. Reset OPL FM state
5. `csf_loop_pattern(&dwsong, pattern, 0)` — sets `SONG_PATTERNLOOP` and
   places playhead at row 0 of the target pattern
6. Set mixer flags `SNDMIX_DIRECTTODISK | SNDMIX_NOBACKWARDJUMPS`
7. Streaming render loop:
   ```c
   do {
       size_t n = csf_read(&dwsong, buf, sizeof(buf));
       disko_write(&ds, buf, n * bps);
       if (ds.length >= MAX_SAMPLE_LENGTH * bps) {
           ds.length = MAX_SAMPLE_LENGTH * bps;  // ~3 min @ 44k
           dwsong.flags |= SONG_ENDREACHED;
       }
   } while (!(dwsong.flags & SONG_ENDREACHED));
   ```
8. `close_and_bind` (`disko.c:597-644`):
   - Destroys old sample data: `csf_destroy_sample(...)`
   - Sets `length`, `c5speed`, default volume/pan
   - `csf_read_sample()` parses raw PCM into the sample struct (handles
     8/16/24/32-bit, mono/stereo, LE/BE)
9. Names the sample `"Pattern %03d"` and (if `bind`) sets the
   `name[23]=0xFF; name[24]=pattern` link marker
10. `set_page(PAGE_SAMPLE_LIST)` to focus the new sample

### Helpers worth knowing
- `csf_first_blank_sample(song, start)` — `player/csndfile.c:395`. Returns
  the lowest free slot ≥ `start`.
- `csf_first_blank_instrument(song, start)` — `csndfile.c:405`.
- `MAX_SAMPLES` = 100, `MAX_PATTERNS` = 240 (per Schism). IT itself uses
  100 sample + 100 instrument slots; pattern count 0–199.

### Constraints Schism takes that we should mirror
- Ctrl-O renders **only the current pattern**, not a selection.
- Default destination is the **currently focused sample slot**. Use a
  confirmation dialog when overwriting non-empty data.
- The "bind" marker (`name[23]=0xFF; name[24]=pattern`) prevents
  duplicate renders. Handy if the user mashes Ctrl-O.
- Schism does **not** create an instrument by default. Sample only.
  This is an obvious P3 deviation we may keep or abandon.

## Mapping to IT.EXE assembly

### What we already have
- **WAVDRV.ASM `Poll`** — receives `AX=Playmode (1=pattern, 2=song)`,
  `BX=pattern_number`. Already constructs `<song>.NNN` filename and
  writes a proper RIFF .WAV. **No driver changes needed for any phase.**
- **`Glbl_F6`** in `IT_G.ASM:377` — calls `I_ClearTables`,
  `PE_GetCurrentPattern`, then `Music_PlayPattern` with `CX=0`. When
  WAVDRV is the active driver, this is the entire P1 flow.
- **Pattern editor key dispatch table** — `PEFunctions` at
  `IT_PE.ASM:354`. Modifier byte `1` + cooked Ctrl-letter ASCII (e.g.
  `0Ah` for Ctrl-J at line 666, `14h` for Ctrl-T at line 682). Ctrl-O =
  ASCII `0Fh`. Ctrl-O is currently unbound.

### What we now have (after a deep dive — 2026-04-30)

**Driver hot-swap path (P2 unblocked):**

| Symbol | Location | Contract |
|--------|----------|----------|
| `Music_LoadDriver` | `IT_MUSIC.ASM:3429` | Given `DS:DX = filename`. Opens the `.DRV`, validates the IT-driver header signature, allocates a conventional-RAM segment with `Int 21h AH=48h`, reads driver code + 16 bytes of variables + the 17-slot driver function pointer table. CF clear on success. |
| `Music_ClearDriverTables` | `IT_MUSIC.ASM:3393–3425` | Resets the 17 driver function pointers to no-op stubs (`NoFunction`/`NoFunction2`). Called before each driver load. |
| `DriverName` | `IT_MUSIC.ASM:438` | `DD 0` — far pointer (offset:segment) to the *currently loaded* driver's filename string. Read this to cache before the WAV swap; pass it back via `Music_LoadDriver` to restore. |
| `Music_SetSoundCardDriver` | `IT_MUSIC.ASM:6606` | Stores `DS:SI` into `DriverName`. |
| `StartDriverFunctions` | `IT_MUSIC.ASM:681–705` | The 17 function pointers IT calls into the active driver (DD each): `DriverDetectCard`, `DriverInitSound` (+8), `DriverReinitSound`, `DriverUninitSound` (+12), `DriverPoll` (+16), `DriverSetTempo`, `DriverSetMixVolume`, `DriverSetStereo`, `DriverLoadSample` (+32), `DriverReleaseSample`, `DriverResetMemory`, `DriverGetStatus`, `DriverSoundCardScreen`, `DriverGetVariable`, `DriverSetVariable`, `DriverMIDIOut`, `DriverGetWaveform`. |
| `Music_SoundCardLoadAllSamples` | declared `IT_PE.ASM:74` | After loading a driver, re-uploads every sample to the new driver via that driver's `DriverLoadSample`. Means the WAV swap is **safe** for sample data: IT keeps canonical sample bytes in main RAM + EMS; the active driver's card RAM is just a cache. |

**Render life cycle inside WAVDRV:** `Poll` with `AX=1, BX=pattern` creates `<song>.NNN`; subsequent `Poll AX=1` calls write PCM; first `Poll AX=0` after the pattern ends closes the file. So "render complete" is observable from the host as "song stopped + WAVDRV's FileHandle was non-zero, now zero".

**WAV-load-into-sample path (P3 unblocked):**

| Symbol | Location | Contract |
|--------|----------|----------|
| `D_GetSampleInfo` | `IT_D_INF.INC:353` (the 772-line format-detection router) | Identifies file format by magic bytes. WAV detection inlined at lines 856–1000 (no `IT_D_WAV.INC`). For WAV: writes IT-internal sample descriptor (length, c5speed, format flags) into the per-slot record. Format codes: 5 = 8-bit WAV, 6 = 8-bit stereo, 7 = 16-bit. C5 speed read from WAV header at offset `+18h` (44100 typically). |
| `Music_AllocateSample` | `IT_MUSIC.ASM:3008–3106` | `AX = sample number (0-based)`, `EDX = length in bytes`. Returns `ES:DI = allocated buffer` (`ES = 0` on failure). Uses DOS conventional alloc (`Int 21h AH=48h`) for small samples; falls back to EMS pages for ≥1024 bytes. Implicitly calls `Music_ReleaseSample` first to clear any existing data in that slot. |
| `Music_AssignSampleToInstrument` | `IT_MUSIC.ASM:6672–6766` | `BX = sample number (1-based)`. Returns `AX = instrument index (1-99)`, `CF = 1` on failure. Searches instruments 1–99 for an empty slot (all-zeros 80-byte header). Fills all 120 MIDI notes of the instrument's note-map at offset `+20h` to point at sample `BX`. Copies sample name → instrument name. **No separate "fill instrument note-map" helper needed — this proc does it all.** |
| Sample slot count | `IT_MUSIC.ASM:5418–5455` (`Music_GetNumberOfSamples`) | 100 slots (1–99 used; 0 reserved). Empty-slot detection: `RepE CmpsB` of 80-byte sample header against zero template. |
| `Music_SoundCardLoadSample` | declared `IT_PE.ASM:73` | After populating a sample slot, call this to push the new sample to the active driver's card RAM. |

**Calling-convention summary for P3 sequence:**

```
1. Save Cx (current sample/instrument focus) for status display
2. Free a sample slot index by scanning 1..99 for empty SampleHeader
   (or just pick slot N+1 where N = current sample selection)
3. Read <song>.NNN header into the 60000h buffer
4. ES:DI := DiskDataArea + (slot * 96)
   BX := slot * 96
   Call D_GetSampleInfo  ; Populates ES:DI with parsed metadata
5. AX := slot, EDX := length-in-bytes (from descriptor)
   Call Music_AllocateSample  ; Returns ES:DI = sample buffer
6. Read PCM data from <song>.NNN into ES:DI (skip RIFF header)
7. BX := slot
   Call Music_AssignSampleToInstrument  ; Auto-creates instrument
   ; Returns AX = instrument index (or CF=1 if all 99 instruments used)
8. Call Music_SoundCardLoadSample  ; Upload new sample to active card
9. Set info-line message: "Pattern N -> sample S, instrument I"
```

**Open question — destination filename + directory.** WAVDRV's
`WAVDirectory` (in `WAVDRV.ASM`) is configurable via the driver's
config screen. To find the rendered file from P3, we either:
(a) read WAVDirectory from the driver's variable area (the 16-byte
slot read by `Music_LoadDriver`),
(b) query via `DriverGetVariable` (offset +52),
(c) hardcode "current directory" assumption (works if user hasn't
changed WAV output directory).

Option (b) is cleanest and survives user customization.

### MVP for P2 — leveraging existing IT machinery
A less invasive P2 might *not* hot-swap drivers at all, but instead
push the user through a brief modal: "switch to WAV driver to render?
[Y/N]". On Y, change driver via the existing Driver Setup screen
programmatically, render, then prompt to switch back. Less elegant
than Schism's silent flow but matches IT's existing UX paradigms.

### MVP for P3 — file-based, not memory-based
Schism does in-memory PCM. We can do **file-based** instead:
1. WAVDRV writes `<song>.NNN` to disk (already works).
2. After file close, our handler scans the WAV directory.
3. Calls IT's existing F3-load-WAV path with the new filename + a
   target slot index.
4. Optionally calls F4-instrument-create + assigns sample.

Less elegant than Schism's RAM-only flow but reuses existing,
proven IT.EXE codepaths instead of inventing a memory-render
backend.

## Open questions before P2/P3 commit (resolved 2026-04-30)
1. ~~Where is `Music_LoadDriver`?~~ **`IT_MUSIC.ASM:3429`.** `DS:DX = filename`.
2. ~~Does IT.EXE flush sample data from card RAM on driver swap?~~ **No flush
   risk for our use.** IT keeps canonical sample bytes in main RAM/EMS;
   `Music_SoundCardLoadAllSamples` re-uploads them to the new driver.
3. ~~Where does the WAV-format parser live?~~ **Inlined in `IT_D_INF.INC`
   lines 856–1000.** Entry via `D_GetSampleInfo` at line 353.
4. **Sample-name "bind" marker** — IT's sample-name is 26 chars (verify in
   sample header struct). Schism uses bytes 23–24 specifically because
   they fall in IT's sample-name field. We can use the same trick — set
   `name[23] = 0xFF; name[24] = pattern_num` after the import, and on
   subsequent Ctrl-O scans, look for already-bound samples to avoid
   duplicate renders.

## P2/P3 implementation skeleton

```asm
; PEFunction_RenderPatternToSample - Ctrl-Shift-O (or upgrade Ctrl-O)
;
;   Phase 2: hot-swap to ITWAV.DRV, render, swap back.
;   Phase 3: import the resulting <song>.NNN as a new sample + instrument.

Proc PEFunction_RenderPatternToSample Far

        ; --- Phase 2: driver swap --------------------------------------
        Push    Word Ptr [CS:DriverName]        ; cache offset
        Push    Word Ptr [CS:DriverName+2]      ; cache segment

        Mov     SI, Offset WAVDriverName        ; "ITWAV.DRV", 0
        Push    CS
        Pop     DS
        Mov     DX, SI
        Call    Music_LoadDriver                ; CF=1 means abort + restore
        Jc      RPS_RestoreOriginalDriver

        Call    PE_GetCurrentPattern            ; AX = pattern number
        Mov     BX, AX                          ; pattern -> BX for Music_PlayPattern
        Xor     CX, CX
        Call    Music_PlayPattern               ; WAVDRV catches AX=1 in Poll

        ; --- Wait for render complete (FileHandle goes 0 again) ---------
        ; ... poll [SoundDriverSegment:FileHandle] until 0 ...

        ; --- Phase 2 cleanup: restore original driver -------------------
RPS_RestoreOriginalDriver:
        Pop     ES                              ; original DriverName segment
        Pop     DX                              ; original DriverName offset
        Mov     DS, ES
        Call    Music_LoadDriver

        ; --- Phase 3: import the rendered file --------------------------
        ; ... build "<song>.NNN" filename ...
        ; ... open file, read header into 60000h buffer ...
        ; ... call D_GetSampleInfo to parse WAV ...
        ; ... call Music_AllocateSample ...
        ; ... read PCM into allocated buffer ...
        ; ... call Music_AssignSampleToInstrument ...
        ; ... call Music_SoundCardLoadSample ...
        ; ... set sample name = "Pattern NNN" + bind marker ...
        ; ... display info-line "Pattern N -> sample S, instr I" ...

        Mov     AX, 1
        Ret
EndP

WAVDriverName   DB      "ITWAV.DRV", 0
```

**Risks not yet validated:**
- Does `Music_LoadDriver` correctly tear down the previous driver
  before loading the new one? If not, we need an explicit
  `[CS:DriverUninitSound]` call between the cache-and-load steps.
- What does `Music_PlayPattern` return / when does it return? Sync or
  async? If async, we need a polling loop before the swap-back. If
  sync (blocks until pattern ends), we can swap back immediately
  after.
- Does WAVDRV's `Poll` actually fire when called via the standard
  IT polling loop, or is there a setup step we're missing?

References:
- Schism: `~/work/schismtracker/schism/disko.c`,
  `~/work/schismtracker/schism/page_patedit.c`,
  `~/work/schismtracker/player/csndfile.c`
- IT: `IT_PE.ASM`, `IT_G.ASM:377`, `IT_MUSIC.ASM:5665+`, `SoundDrivers/WAVDRV.ASM:645`
