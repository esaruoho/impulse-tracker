# Report Card — F3/F4 loader keyjazz keeps the song playing

> Source: `features/loader-keyjazz-hang.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone auditioning samples against a playing song from the loader browser, I want previewing or loading a sample to NOT stop playback, So that I can hear a candidate sample in the mix without the song halting and without IT hanging on a half-loaded sample header.

**Grades:** @build-verified × 7 · @runtime-untested × 6 · @shipped × 6 · @stock × 1

**Scenarios: 7**


---


## 1. (pre-fork) keyjazz / load in the browser used to kill the song

`@stock @build-verified`


- Given the user is auditioning or loading a sample in the F9 file browser
- When a preview note is played or a sample is loaded (pre-fork)
- Then the entire song stops -- the defect


## 2. Keyjazz preview in the browser silences only the preview voice

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a song is playing and the user is in the sample-loader file browser
- When the user keyjazzes a note to preview a sample
- Then only the preview voice for sample slot 99 is silenced; the song keeps playing

<sub>cite: IT_DISK.ASM LoadSample -- preview load uses zero-based slot 99. · IT_MUSIC.ASM Music_SilenceSampleVoices -- only matching zero-based slot · commit a44c41b</sub>


## 3. Preview waveform redraw reads the freshly loaded preview slot

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the user has entered the sample-loader browser from F3
- When the user selects a sample and presses a key to preview it
- Then the loader waveform area is redrawn from the freshly loaded preview sample
- And it does not show stale pattern/numeric glyphs in the waveform rectangle

<sub>cite: IT_DISK.ASM LoadSample calls D_DrawWaveForm after loading zero-based</sub>


## 4. Loading a sample silences only that slot, song continues

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a song is playing
- When the user presses Enter on a sample file to load it into a slot
- Then only that slot's voices are silenced; the song does not stop

<sub>cite: IT_MUSIC.ASM Music_ReleaseSample passes the zero-based release slot</sub>


## 5. The MIDI-sync mixer path is gated against a half-loaded header

`@shipped @build-verified @runtime-untested @hw-untested`


- Given an external MIDI clock/sync is driving playback during a load
- When a sample reload is in progress (MIDISyncLoaderSuppress set)
- Then the MIDI-sync mixer path is suppressed until the load completes (no hang)

<sub>cite: IT_K.ASM MIDISyncLoaderSuppress=1 while loading (MIDI_SetLoaderSuppress),</sub>


## 6. Loader preview defaults away from pattern channel 01

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the pattern is playing on channel 01
- When the user keyjazz-previews a sample in the loader browser
- Then the preview is played on displayed channel 64 by default
- And it does not overwrite the pattern event currently sounding on channel 01

<sub>cite: IT_DISK.ASM D_PostLoadSampleWindow calls I_GetPlayChannel before · IT_I.ASM PlayChannel defaults to 63 (displayed channel 64);</sub>


## 7. MIDI notes can keyjazz the sample loader preview

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the user is in the sample-loader file browser
- When an external MIDI note-on arrives
- Then the highlighted sample is loaded into preview slot 99 and auditioned
- And MIDI note-off or velocity-zero silences only that preview slot

<sub>cite: IT_DISK.ASM LSWindowKeys maps MIDI Note On/Off to LSWindow_MIDINote · IT_DISK.ASM LSWindow_MIDINote uses PE_TranslateMIDI, loads preview</sub>

