# Report Card — WAV render keeps the music going (fast pattern render + MIDI-clock resume)

> Source: `features/wav-render-keep-playback.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone rendering a pattern to WAV while a tune plays, I want the render to barely interrupt playback and the song to resume, So that bouncing a pattern doesn't kill my groove for seconds at a time.

**Grades:** @build-verified × 4 · @runtime-untested × 4 · @shipped × 4

**Scenarios: 5**


---


## 1. A single-pattern render runs faster than realtime (brief freeze)

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a song is playing
- When the user triggers a single-PATTERN render (Shift-Right at the order edge)
- Then the pattern renders as fast as the CPU can mix -- a brief freeze
- And NOT a silence as long as the pattern would take to play in realtime

<sub>cite: IT_MUSIC.ASM WAV_PlayDone -> WAV_SyncRenderLoop: tight Music_Poll loop · SoundDrivers/WAVDRV.ASM Poll mixes on demand (no timer/DMA wait) · commit 702727c</sub>


## 2. Whole-song render stays realtime

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a whole-song WAV render (F10 WAV/MWAV)
- When it runs
- Then it stays realtime (timer-paced), unchanged by the fast-pattern path

<sub>cite: WAV_PlayDone gates on WAV_SongMode; song mode (Music_PlaySong arms a</sub>


## 3. A song that was playing resumes after the render, on the next MIDI clock

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a song was playing when the render started
- When the render finishes and the live driver is back
- And an external MIDI clock (or Start/Continue) arrives
- Then playback resumes from the saved order/row

<sub>cite: IT_MUSIC.ASM render enter snapshots WAV_ResumeArmed + CurrentOrder/Row · IT_K.ASM MIDISendRTClock calls Music_ResumeAfterRender</sub>


## 4. No resume if nothing was playing

`@shipped @build-verified @runtime-untested @hw-untested`


- Given playback was stopped when the render started
- When the render finishes and clocks arrive
- Then nothing auto-starts (resume is armed only if a song was playing)

<sub>cite: WAV_ResumeArmed is only set when PlayMode != 0 at render enter</sub>


## 5. True simultaneous live-audio + render is NOT done

`@known-limit`


- Given IT's single audio engine
- When a render runs
- Then live audio cannot literally continue DURING the render
- And this feature gives "brief freeze + resume after" as the achievable best

<sub>cite: render unloads the live driver (Music_UnloadDriver) -- one active</sub>

