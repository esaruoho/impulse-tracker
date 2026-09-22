# Report Card — Scroll Lock in the loader loads the sample and drops me into the editor

> Source: `features/loader-scrolllock-load-and-jam.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone auditioning samples in the loader, I want one key that loads the highlighted sample, makes it an instrument, and puts me in the Pattern Editor, So that I can go from "found a sound" to "jamming with it" without a detour.

**Grades:** @build-verified × 6 · @runtime-untested × 6 · @shipped × 6

**Scenarios: 6**


---


## 1. Scroll Lock loads the sample, makes an instrument, and enters the editor

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the Load-Sample view is open with a sample highlighted
- When I press Scroll Lock
- Then the highlighted sample is loaded into the current sample slot
- And Instrument mode is forced on (bit 2 of [songseg:2Ch])
- And an instrument is created for that sample and selected as current
- And the Pattern Editor opens with Follow Mode on, ready to jam

<sub>cite: IT_DISK.ASM LSViewWindow_ScrollLock ; commit 8f6a5cd</sub>


## 2. It is a new key and does not disturb the loader's core tools

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the loader keyjazz, Enter, and cursor keys work as before
- When the Scroll Lock entry is added to LSViewWindowKeys
- Then keyjazz, Enter (LSViewWindow_Enter) and Up/Down are byte-for-byte unchanged
- And only the previously-unbound Scroll Lock gains behaviour in this window

<sub>cite: IT_DISK.ASM LSViewWindowKeys 146h entry (added before the 0FFh terminator) ; commit 8f6a5cd</sub>


## 3. Scroll Lock in the editor round-trips back to the loader on a free slot

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I entered the Pattern Editor via loader Scroll Lock (round-trip armed)
- And I have jammed some notes
- When I press Scroll Lock again in the editor
- Then the armed flag is consumed
- And the loader destination is advanced to the next free slot (max(samples,instruments)+1)
- And the sample loader reopens, ready to grab the next sound onto a fresh slot

<sub>cite: IT_PE.ASM PE_ScrollLockFollow PE_SLF_InEditor (armed -> Glbl_LoadSample) ; commit 3944a9c · IT_DISK.ASM LSViewWindow_ScrollLock Call PE_ArmScrollLockRoundTrip ; commit 3944a9c</sub>


## 4. Scroll Lock in the editor without the round-trip armed still toggles Follow

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am in the Pattern Editor but did NOT arrive via loader Scroll Lock
- When I press Scroll Lock
- Then Follow Mode toggles exactly as before (no round-trip)
- And Ctrl-F toggles Follow Mode regardless of how I got here

<sub>cite: IT_PE.ASM PE_ScrollLockFollow PE_SLF_InEditor JE PE_SLF_Toggle ; commit 3944a9c</sub>


## 5. Shift-Scroll Lock in the editor always reopens Sample Load

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am in the Pattern Editor
- When I press Shift-Scroll Lock
- Then the Sample Load view opens
- And plain Scroll Lock keeps its existing Follow or round-trip behavior

<sub>cite: IT_PE.ASM pattern-editor keylist DB 4 / DW 146h -> PE_ScrollLockLoadSample · IT_PE.ASM PE_ScrollLockLoadSample tail-jumps to Glbl_LoadSample</sub>


## 6. If the instrument assign fails, it still drops me in to jam on the sample

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the sample loaded but no instrument slot could be assigned
- When Music_AssignSampleToInstrument returns carry
- Then the macro skips the select step
- And still jumps to the Pattern Editor with Follow Mode on

<sub>cite: IT_DISK.ASM LSViewWindow_ScrollLock JC LSVSL_Go on Music_AssignSampleToInstrument ; commit 8f6a5cd</sub>

