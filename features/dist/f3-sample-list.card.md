# Report Card — User Presses F3 (Sample List)

> Source: `features/f3-sample-list.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone working with raw samples, I want F3 to open the sample list and Ctrl-F3 to reach the disk library, And I want previewing a sample in the loader to NOT kill the playing song, So that sample work never silences the tune I'm building it for.

**Grades:** @build-verified × 6 · @runtime-untested × 1 · @shipped × 4 · @stock × 2

**Scenarios: 6**


---


## 1. F3 opens the sample list

`@stock @build-verified`


- Given the user is on any screen
- When the user presses F3
- Then CurrentMode becomes 3 and the sample list (O1_SampleList) opens
- And if the user was on the instrument list, the cursor maps to the same slot

<sub>cite: IT_OBJ1.ASM:3142 GlobalKeyList F3 (scancode 13Dh) -> Glbl_F3 · IT_G.ASM:303 Glbl_F3 sets CurrentMode=3, returns O1_SampleList · IT_G.ASM:305 Glbl_InstrumentToSample translates an F4-cursor to F3 · IT_I.ASM I_DrawWaveForm + I_DrawSampleList draw the screen</sub>


## 2. Ctrl-F3 opens the disk Sample Library from anywhere

`@stock @build-verified`


- Given the user is on any screen
- When the user presses Ctrl-F3
- Then CurrentMode becomes 13 and the disk-based sample library browser opens

<sub>cite: IT_OBJ1.ASM:3146 GlobalKeyList Ctrl-F3 -> Glbl_Ctrl_F3 · IT_G.ASM:680 Glbl_Ctrl_F3 calls D_InitLoadSamples, CurrentMode=13, · IT.TXT:1815 "The Sample library is accesible from all screens ... Ctrl-F3"</sub>


## 3. Previewing a sample in the loader does not stop the song

`@shipped @build-verified @hw-untested`


- Given a song is playing
- When the user keyjazz-previews a sample in the loader (LoadSample zero-based slot 99)
- Then only the voices reading sample slot 99 are silenced (200h sentinel)
- And the rest of the song keeps playing

<sub>cite: IT_DISK.ASM:6108 D_PreLoadSampleWindow calls MIDI_SetLoaderSuppress · IT_MUSIC.ASM:9230 Music_SilenceSampleVoices stops only slaves whose · commits a44c41b, 64fa1ce</sub>


## 4. Loader keyjazz redraws the selected sample waveform

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the user has pressed Enter from F3 into the loader sample area
- When the user selects a sample and presses a note key
- Then the loader waveform viewer redraws the selected sample's waveform
- And it does not render stale pattern/numeric glyphs in the waveform area

<sub>cite: IT_DISK.ASM LoadSample loads zero-based preview slot 99, then calls</sub>


## 5. MIDI transport bytes can't restart the song mid-load

`@shipped @build-verified @hw-untested`


- Given the loader suppress flag is set (a sample load is in flight)
- When a MIDI Start (FA) or Stop (FC) byte arrives
- Then MIDISend skips the playback restart while slot 99 is mid-write
- And once the load finishes the flag is cleared and sync resumes normally

<sub>cite: IT_K.ASM:114 MIDISyncLoaderSuppress; :1991 FA guard, :2014 FC guard · commit 64fa1ce</sub>


## 6. Shift-Enter bulk sample load is guarded the same way

`@shipped @build-verified @hw-untested`


- Given the user triggers a bulk sample load in the library
- When many slots are written in a loop
- Then MIDI transport is suppressed for the whole loop, not per file
- And the song (if playing) survives the bulk load

<sub>cite: IT_DISK.ASM:7859 LSWindow_ShiftEnter sets suppress at loop start, · commit 64fa1ce</sub>

