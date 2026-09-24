# Report Card — Shift-F4 to enable Multitimbral mode also switches Samples -> Instruments

> Source: `features/shift-f4-enters-instrument-mode.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone enabling live multitimbral MIDI-in, I want confirming "Yes, enter Multitimbral Mode" to ALSO move me from Sample mode into Instrument mode (since the 16 things created are instruments), So that the instruments I just made are immediately the active, playable mode.

**Grades:** @build-verified × 3 · @hw-verified × 1 · @runtime-untested × 1 · @runtime-verified × 1 · @shipped × 3

**Scenarios: 4**


---


## 1. From Sample mode, Shift-F4 + confirm enters Instrument mode with 16 instruments

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the user is in Sample mode
- When they press Shift-F4 and choose "Yes, enter Multitimbral Mode"
- Then the song switches from Sample mode to Instrument mode (flag bit 2 set)
- And 16 instruments are created, instrument N mapped to sample N (01-16)
- And the Instrument List is shown so the mode change is visible

<sub>cite: IT_G.ASM:389 Glbl_Shift_F4_Create opens O1_ConfirmCreateMIDIIn; YES (DX!=0) · IT_G.ASM:396 Call Music_CreateMIDIInInstruments · IT_MUSIC.ASM:4075 builds instruments 1..16, each MIDI-in channel N · IT_G.ASM:415 Or Byte Ptr [DS:2Ch],4 sets the Instrument-mode flag · IT_G.ASM:429 Jmp Glbl_F4 shows the Instrument List (CurrentMode=4)</sub>


## 2. The mode switch is a direct flag set, NOT the F12 clear/remap path

`@shipped @build-verified @hw-untested`


- Given confirming "Yes" on the Shift-F4 prompt
- When the Instrument-mode flag is set
- Then F_SetControlInstrument is NOT invoked
- And no instrument-clearing / envelope-preserve logic runs

<sub>cite: IT_G.ASM:415 sets the flag directly after Music_GetSongSegment, exactly</sub>


## 3. Declining the prompt changes nothing

`@shipped @build-verified @hw-untested`


- Given the user presses Shift-F4 and chooses "No"
- When the prompt is dismissed
- Then no instruments are created, the mode is unchanged, and the screen stays

<sub>cite: IT_G.ASM Glbl_Shift_F4_Create: Test DX / JZ Glbl_Shift_F4_Done</sub>


## 4. (verify live) cursor + playback survive the mode switch

`@runtime-untested`


- Given a song may be playing when Shift-F4 + YES is pressed in Sample mode
- When the Instrument List opens
- Then it behaves like a normal F4 entry (cursor mapped, playback undisturbed)

