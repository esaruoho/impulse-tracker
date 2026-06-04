# Session — wav-render-keep-playback

> The thinkspace leg of the `wav-render-keep-playback` triad. Faithful, not flattering.

## The request

Esa, "Feature: Order List Rendering while playback is on" — Shift-Right renders
a pattern to WAV while the song plays, and *"the playback does not get stopped
during this process."* Then he asked for a read-only analysis of how to do it,
and chose **Options 2 + 1**, with the resume **MIDI-triggered**: *"after rendering
has stopped, and there's a midi start clock or a specific timing incoming, then
that means that you can resume playback."*

## The honest constraint (the read-only analysis)

IT has ONE audio engine. The WAV render commandeers it: `Music_ToggleWAVRender`
enter does `Music_Stop` + `Music_UnInitSoundCard` + `Music_UnloadDriver`, loads
the WAV-to-file driver, then plays the pattern into it. So live audio cannot
literally continue DURING the render — there's no second engine. True-simultaneous
(Option 3) is a rewrite (one active driver slot; the mixer voice table
`SlaveChannelInformationTable` is global). Recorded as `@known-limit`, not faked.

But two things ARE achievable, and the analysis found the enabler for each:

- **Option 2 enabler:** `SoundDrivers/WAVDRV.ASM` `Poll` mixes ON DEMAND — no
  timer, no DMA wait; its own header says "called as often as possible." And the
  single-pattern render uses `Music_PlayPattern`, which does NOT arm a timer
  (`StartClock` is only in `Music_PlaySong`). So the render is paced purely by how
  often `Music_Poll` is called. Drive it in a tight loop → faster than realtime.
- **Option 1 enabler:** incoming FA/FB already call `Music_KBPlaySong`
  (IT_K MIDISend). So the MIDI path can drive a resume; just snapshot the position
  and hook a resume into the clock handler too.

## Why the implementation is what it is

- **Fast render only for PATTERN mode.** `WAV_PlayDone` branches on `WAV_SongMode`:
  pattern → tight `Music_Poll` loop until `PlayMode==0`, then a few close Polls so
  WAVDRV flushes/closes the file, then inline `WAV_LeaveMode`. Song mode keeps the
  realtime async path (its `Music_PlaySong` timer would fight a tight loop). The
  tight loop uses the SAME completion signal (`PlayMode==0`) the working async path
  uses, so if async finalizes, the loop finalizes. A safety cap (100000 Polls)
  guards a pathological `Bxx`-to-self loop from an unbounded freeze.

- **Resume snapshots position at enter, fires from the clock.** Before `Music_Stop`
  in the enter path, if `PlayMode != 0`, capture `WAV_ResumeArmed` + `CurrentOrder`
  + `CurrentRow`. `Music_ResumeAfterRender` (Far, in the Music segment) checks
  armed + render-done + stopped, then `Music_PlayPartSong(order,row)` and disarms.
  `MIDISendRTClock` (the F8 handler in IT_K) calls it, gated by the same
  `MIDITransportEnable` + `MIDISyncLoaderSuppress` as FA/FB/FC. So an external clock
  after the render resumes in place; FA/FB still restart from top (and disarm via
  the PlayMode check).

## Honest grades

- `@build-verified`: DOSBox-X BUILDALL, IT_MUSIC.asm + IT_K.asm Error/Warning =
  None, IT.EXE links (477871 bytes).
- `@runtime-untested @hw-untested`: not yet run. Watch on test: (1) Shift-Right
  render during playback = a quick freeze, not a long dropout; (2) with an external
  clock running, the song resumes from where it was after the render; (3) a
  whole-song render still behaves as before.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Session ID: `e86aa106-2936-452b-805c-e3418c03140c`
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`

## Cross-links

- Spec leg: `features/wav-render-keep-playback.feature`
- Siblings: `features/wav-render-reentry-guard.feature`, `features/wav-render-quicksave.feature`
- Feature commit: `702727c`
