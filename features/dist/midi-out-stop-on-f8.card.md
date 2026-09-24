# Report Card — Send MIDI Stop (FC) out on F8

> Source: `features/midi-out-stop-on-f8.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a musician whose DOS PC is the master in a MIDI rig, I want pressing F8 (Stop) to also transmit a single MIDI Stop to slaved gear, So that one keypress halts both Impulse Tracker and everything downstream, with no risk of a transport feedback loop.

**Grades:** @build-verified × 8 · @runtime-untested × 3 · @shipped × 8

**Scenarios: 8**


---


## 1. F8 transmits exactly one MIDI Stop byte out

`@shipped @build-verified @hw-untested`


- Given the "Send MIDI Stop on F8" toggle is ON
- And a MIDI-capable sound driver is loaded
- When the user presses F8 to stop playback
- Then a single 0FCh System Real-Time Stop byte is sent out the MIDI port
- And local playback then stops via Music_Stop exactly as before

<sub>cite: IT_G.ASM Glbl_F8 (~637) -> Music_SendMIDIStop when the gate is ON, · IT_MUSIC.ASM Music_SendMIDIStop -> MIDISendFilter with AL=0FCh</sub>


## 2. The Stop byte does not disturb MIDI running status

`@shipped @build-verified @hw-untested`


- Given running status is active on the MIDI output
- When F8 transmits the 0FCh Stop byte
- Then LastMIDIByte (the running-status cache) is left untouched
- And the next note/CC byte still benefits from running-status compression

<sub>cite: IT_MUSIC.ASM MIDISendFilter (~1111): AL >= 0F0h takes the JAE branch</sub>


## 3. With no MIDI-capable driver the transmit is a clean no-op

`@shipped @build-verified @hw-untested`


- Given the loaded sound driver has no MIDI output (DriverFlags bit 0 clear)
- When the user presses F8 with the toggle ON
- Then Music_SendMIDIStop returns harmlessly and only Music_Stop runs
- And no byte is written to a non-existent UART

<sub>cite: IT_MUSIC.ASM MIDISendFilter tests CS:DriverFlags bit 0 first; if the</sub>


## 4. A MIDI-thru loopback cannot create a transport storm

`@shipped @build-verified @hw-untested`


- Given MIDI OUT is physically or virtually looped back to MIDI IN
- And inbound MIDI Transport response is also enabled
- When the user presses F8 (sending 0FCh out, which arrives back in)
- Then the received 0FCh only calls Music_Stop (already stopped -> no-op)
- And no second 0FCh is ever transmitted (a Stop cannot beget a Stop)

<sub>cite: the ONLY caller of Music_SendMIDIStop is Glbl_F8 (the keypress).</sub>


## 5. The toggle defaults ON and is flipped on the Shift-F1 MIDI screen

`@shipped @build-verified @runtime-untested`


- Given the Shift-F1 MIDI screen is open
- Then a "Toggle Send MIDI Stop (FC) on F8" button sits below the Multitimbral toggle
- And selecting it flips the flag and shows "Send MIDI Stop (FC) on F8: ON/OFF"

<sub>cite: IT_K.ASM MIDIStopOnF8Enable DB 1 (default ON) · IT_OBJ1.ASM MIDIStopF8ToggleButton (index 26 on O1_MIDIScreen, row 49)</sub>


## 6. With the toggle OFF, F8 behaves exactly like stock

`@shipped @build-verified @hw-untested`


- Given the "Send MIDI Stop on F8" toggle is OFF
- When the user presses F8
- Then no MIDI byte is transmitted
- And playback stops via Music_Stop, identical to upstream behaviour

<sub>cite: IT_G.ASM Glbl_F8 calls MIDI_F8StopEnabled; ZF=1 (OFF) jumps past the</sub>


## 7. The toggle survives an Impulse Tracker restart (no separate save step)

`@shipped @build-verified @runtime-untested`


- Given the user turns the toggle OFF on the Shift-F1 screen
- When IT.EXE is quit and relaunched (no explicit "save config" needed)
- Then D_InitDisk reads block +3 and restores the toggle to OFF
- And turning it back ON likewise persists on the next launch

<sub>cite: IT_K.ASM Glbl_MIDIStopF8_Toggle calls D_SaveDirectoryConfiguration · IT_DISK.ASM D_SaveDirectoryConfiguration stamps the live flag into · commit 222962f ; IT_PE.ASM MIDIStopOnF8PersistOff at block offset +3</sub>


## 8. Old IT.CFG files (and fresh installs) default the toggle ON

`@shipped @build-verified @runtime-untested`


- Given an IT.CFG written before this feature (block +3 byte is zero or absent)
- When IT.EXE loads it at boot
- Then the "Send MIDI Stop on F8" toggle comes up ON (no surprise OFF)

<sub>cite: block +3 is FORCE-OFF: 0 -> ON. Pre-222962f IT.CFGs wrote that byte as</sub>

