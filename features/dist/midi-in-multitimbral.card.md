# Report Card — Multitimbral MIDI-In

> Source: `features/midi-in-multitimbral.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a musician driving the DOS PC from an external MIDI source, I want incoming notes on MIDI channels 01-16 to each trigger their own Impulse Tracker instrument live, So that Impulse Tracker becomes a 16-part sampler-synth, even while the transport is stopped.

**Grades:** @build-verified × 7 · @shipped × 9 · @stock × 1 · @todo × 1

**Scenarios: 12**


---


## 1. Output MIDI fields are independent of the input field

`@stock @shipped @build-verified @hw-untested`


- Given an instrument header
- Then byte 3Ch "MIDI Channel", 3Dh "MIDI Program" and 3Eh/3Fh "MIDI Bank"
- are OUTPUT only (IT sends note/program/bank out to an external synth)
- And byte 1Fh "MIDI In Channel" is INPUT only (which channel IT listens on)
- And changing one never affects the other

<sub>cite: IT_MUSIC.ASM UpdateMIDI (~line 7960) reads hdr 3Ch/3Dh/3Eh-3Fh · nothing in the output path reads hdr 1Fh</sub>


## 2. Each instrument can claim an incoming MIDI channel

`@shipped @build-verified @hw-untested`


- Given the F4 instrument editor MIDI screen
- Then a "MIDI In Channel" field stores 0..17 at instrument header byte 1Fh
- And 0 means off, 1..16 mean that channel, 17 means All/Omni
- And the value persists inside the 554-byte header (saved in .IT / .ITI)

<sub>cite: IT_OBJ1.ASM InstrumentMIDIInChannel object (F4 MIDI tab, type 14,</sub>


## 3. First Shift-F4 maps current samples to MIDI-In 01-16

`@shipped @build-verified @hw-untested`


- Given the user has samples loaded
- And Instruments mode is Off
- And no multitimbral set exists yet (MIDIMultiBanks = 0)
- When the user presses Shift-F4
- Then the "Map current samples to MIDI-In 01-16?" dialog opens
- When the user confirms
- Then instruments 01-16 are created in slots 1..16 directly
- And instrument N is set to MIDI In Channel N and plays sample N
- And each is named "MIDI In Ch NN"
- And the multitimbral router is enabled

<sub>cite: IT_G.ASM Glbl_Shift_F4 -> Music_CreateMIDIInInstruments (IT_MUSIC) · commit 8c32fd2 ; instrument-mode gate (b5a0c66) removed here</sub>


## 4. Second Shift-F4 replicates 01-16 across six banks (96 instruments)

`@shipped @build-verified @hw-untested`


- Given the user has samples loaded and a single 01-16 set exists (banks = 1)
- When the user presses Shift-F4
- Then instruments 1..96 are created as six copies of the 01-16 map
- And instrument K responds to MIDI In Channel ((K-1) mod 16)+1 and plays
- that same-numbered sample
- And 96 is the largest multiple of 16 under the 99-instrument cap
- And the router still plays the first matching instrument per channel
- (the extra five copies are spare slots, by design)

<sub>cite: IT_G.ASM Glbl_Shift_F4 -> Music_ExpandMIDIInTo96 (IT_MUSIC) · commit 8c32fd2 ; decision: "just create the 96 slots, no router change"</sub>


## 5. Third Shift-F4 resets the six banks back to one 01-16 set

`@shipped @build-verified @hw-untested`


- Given six banks exist (banks = 6, instruments 1..96 populated)
- When the user presses Shift-F4
- Then instruments 17..96 are emptied (each 554-byte header zeroed)
- And the single 01-16 set in slots 1..16 remains
- And the cycle returns to its one-bank state (banks = 1)

<sub>cite: IT_G.ASM Glbl_Shift_F4 -> Music_ResetMIDIInTo16 (IT_MUSIC) · commit 8c32fd2</sub>


## 6. An incoming note on channel N triggers the matching instrument

`@shipped @hw-untested`


- Given the multitimbral router is enabled
- And an instrument has MIDI In Channel set to N (or 17 = All)
- When a MIDI note-on arrives on channel N
- Then that instrument is played live on host channel 48+N, transport-independent
- And the note is NOT recorded into the pattern
- When the matching note-off (or note-on velocity 0) arrives
- Then that channel's voice is cut

<sub>cite: IT_K.ASM MIDISend hook -> IT_I.ASM MIDIMulti_Route + MMR_FindInst · plays via Music_PlayNote on host channel 48+N ; commit 7e3620a</sub>


## 7. Channel 1 note entry is unchanged when the router is off

`@shipped @hw-untested`


- Given the multitimbral router is disabled (MIDIMultiEnable = 0)
- When a MIDI note arrives
- Then behaviour is byte-for-byte the classic note-entry path (the selected
- sample is triggered on the active screen)

<sub>cite: IT_K.ASM MIDISend ; router returns 0 when MIDIMultiEnable=0,</sub>


## 8. The router on/off switch lives on the Shift-F1 MIDI screen

`@shipped @build-verified @hw-untested`


- Given the Shift-F1 MIDI screen
- Then a "Toggle Multitimbral MIDI-In" button sits beside the MIDI Sync
- (F8 Clock) and MIDI Transport (FA/FB/FC) toggles
- When the user activates it
- Then the live router is flipped on or off without destroying any instruments
- And the info line confirms "Multitimbral MIDI-In: ON" / ": OFF"

<sub>cite: IT_OBJ1.ASM MIDIMultiToggleButton (list entry 25, rows 46-48) · IT_K.ASM Glbl_MIDIMulti_Toggle flips MIDIMultiEnable ; commit 8c32fd2</sub>


## 9. Enabling it from Sample mode offers to make the whole move

`@shipped @build-verified @hw-untested`


- Given the song is in Sample mode
- When the user activates the Shift-F1 multitimbral toggle
- Then IT asks whether to map the current samples to MIDI-In 01-16
- And on yes it creates instruments 01-16, switches the song to Instrument mode,
- and turns the router on
- And on no it leaves the router OFF and says it needs Instrument mode

<sub>cite: IT_G.ASM Glbl_MIDIMulti_ToggleGuarded -- the button's handler as of · same O1_ConfirmCreateMIDIIn dialog and Music_CreateMIDIInInstruments</sub>


## 10. Why "ON" in Sample mode was a lie worth removing

`@design-note`


- Given a switch whose effect depends on state the user has not set up
- Then offer to set that state up, and do not claim success without it


## 11. Why the flag is set directly and not through F12

`@design-note`


- Given the mapping has just been built
- Then the mode flag is set directly, so the mapping survives it

<sub>cite: IT_G.ASM -- Or Byte Ptr [DS:2Ch], 4 on the song segment</sub>


## 12. Polyphony per channel

`@todo`


- Given a channel receives overlapping notes
- Then later notes currently cut earlier ones on that channel

