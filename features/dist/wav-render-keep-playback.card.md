# Report Card — WAV render keeps the music going (fast pattern render + MIDI-clock resume)

> Source: `features/wav-render-keep-playback.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone rendering a pattern to WAV while a tune plays, I want the render to barely interrupt playback and the song to resume, So that bouncing a pattern doesn't kill my groove for seconds at a time.

**Grades:** @build-verified × 6 · @hw-verified × 2 · @runtime-untested × 4 · @runtime-verified × 2 · @shipped × 6

**Scenarios: 7**


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


## 4. Standalone Ctrl-O resumes on its own, with no external clock

`@shipped @build-verified @runtime-verified @hw-verified`


- Given a song was playing and the user presses Ctrl-O (single-pattern render)
- And there is NO external MIDI clock feeding IT
- When the render finishes and the live driver is back
- Then playback resumes on its own from where it was
- And a whole-song render or a multi-WAV sweep does NOT auto-resume this way

<sub>cite: IT_MUSIC.ASM WAV_LeaveMode latches WAV_DoResumeOnLeave (only when</sub>


## 5. Resume matches the play mode that was active at render enter

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the user was on pattern 022 row 32 in single-pattern play (PlayMode 1)
- When Ctrl-O renders and finishes
- Then playback resumes as pattern 022 from row 32 via Music_PlayPattern
- But if a SONG was playing (PlayMode 2) it resumes the saved order/row via Music_PlayPartSong

<sub>cite: IT_MUSIC.ASM enter snapshots WAV_ResumePlayMode + CurrentPattern +</sub>


## 6. No resume if nothing was playing

`@shipped @build-verified @runtime-untested @hw-untested`


- Given playback was stopped when the render started
- When the render finishes and clocks arrive
- Then nothing auto-starts (resume is armed only if a song was playing)

<sub>cite: WAV_ResumeArmed is only set when PlayMode != 0 at render enter</sub>


## 7. True simultaneous live-audio + render is NOT done

`@known-limit`


- Given IT's single audio engine
- When a render runs
- Then live audio cannot literally continue DURING the render
- And this feature gives "brief freeze + resume after" as the achievable best

<sub>cite: render unloads the live driver (Music_UnloadDriver) -- one active</sub>

