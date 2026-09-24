# Report Card — User Presses F4 (Instrument List)

> Source: `features/f4-instrument-list.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone shaping instruments (envelopes, NNA, MIDI), I want F4 to open the instrument editor and repeated F4 to cycle its tabs, And Ctrl-F4 to reach the disk instrument library, So that all four envelope/MIDI tabs of an instrument are reachable from one key.

**Grades:** @build-verified × 4 · @shipped × 1 · @stock × 3

**Scenarios: 4**


---


## 1. F4 opens the instrument editor

`@stock @build-verified`


- Given the user is on any screen
- When the user presses F4
- Then CurrentMode becomes 4 and the instrument editor opens
- And if the user was on the sample list, the cursor maps to the same slot
- And the tab shown is whichever InstrumentScreen was last active

<sub>cite: IT_OBJ1.ASM:3150 GlobalKeyList F4 (scancode 13Eh) -> Glbl_F4 · IT_G.ASM:384 Glbl_F4 -> Glbl_SampleToInstrument (cursor map),</sub>


## 2. Pressing F4 again cycles the instrument tabs

`@stock @build-verified`


- Given the user is already in the instrument editor
- When the user presses F4
- Then the active tab advances General -> Volume -> Panning -> Pitch -> General
- And the matching O1_InstrumentList<tab> object is drawn

<sub>cite: IT_I.ASM:871 I_SelectScreen cycles 0..3 then redraws via Glbl_F4_2 · IT_I.ASM:383 InstrumentScreenTable -> General / Volume / Panning / Pitch</sub>


## 3. Ctrl-F4 opens the disk Instrument Library from anywhere

`@stock @build-verified`


- Given the user is on any screen
- When the user presses Ctrl-F4
- Then CurrentMode becomes 15 and the disk instrument library browser opens

<sub>cite: IT_OBJ1.ASM:3154 GlobalKeyList Ctrl-F4 -> Glbl_Ctrl_F4 · IT_G.ASM:696 Glbl_Ctrl_F4 calls D_InitLoadInstruments, CurrentMode=15, · IT.TXT:1817 "The Instrument library is accesible on Ctrl-F4"</sub>


## 4. The per-instrument MIDI-In Channel is edited on the Pitch tab

`@shipped @build-verified @hw-untested`


- Given the user is on the instrument editor Pitch tab
- Then a "MIDI In Channel" field stores 0..17 at instrument header byte 1Fh
- And 0 = off, 1..16 = that channel, 17 = All/Omni
- And what those values DO live is documented in midi-in-multitimbral.feature

<sub>cite: IT_OBJ1.ASM:6531 InstrumentMIDIInChannel (type 14, hdr byte 1Fh, 0..17) · commit 10c837b</sub>

