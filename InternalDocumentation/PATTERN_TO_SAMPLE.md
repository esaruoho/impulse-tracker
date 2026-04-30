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

### What we don't yet have (P2/P3)
- **Hot-swap to WAVDRV.** The driver init/uninit lifecycle is in
  `IT_MUSIC.ASM` — we'd need to find `Music_LoadDriver` (or equivalent),
  cache the current driver name, swap in `ITWAV.DRV`, render, then swap
  back. Risk: any sample data the active driver caches in card RAM
  (GUS, AWE32) gets dropped.
- **WAV-load-into-sample.** `Music_AssignSampleToInstrument:Far` is
  declared in `IT_DISK.ASM:69`, body unfound. Standalone-WAV parsing
  may live in an `IT_D_*.INC` we haven't located. Needs another
  Explore pass before P3.
- **Sample/instrument allocation.** `Music_AllocateSample` declared at
  `IT_DISK.ASM:59`; body unfound. Same Explore pass.

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

## Open questions before P2/P3 commit
1. Where is `Music_LoadDriver` (or whatever swaps drivers at runtime)?
   Driver Setup screen must call something.
2. Does `IT.EXE` flush sample data from card RAM on driver swap? If
   yes, we need to reload after the round-trip.
3. Where does the WAV-format parser live? Some `IT_D_*.INC`?
4. Schism's `name[23]=0xFF; name[24]=pattern` marker — would we use
   the equivalent of IT's sample-name field for the same trick?

References:
- Schism: `~/work/schismtracker/schism/disko.c`,
  `~/work/schismtracker/schism/page_patedit.c`,
  `~/work/schismtracker/player/csndfile.c`
- IT: `IT_PE.ASM`, `IT_G.ASM:377`, `IT_MUSIC.ASM:5665+`, `SoundDrivers/WAVDRV.ASM:645`
