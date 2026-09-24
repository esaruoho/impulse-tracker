# Report Card — Shift-Enter Load from Sample List

> Source: `features/shift-enter-load-from-sample-list.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a user building a song from an existing module's samples, I want Shift-Enter on a module to pull in all its samples at once, So that I get every sample, named and loop-configured as in the source.

**Grades:** @shipped × 4

**Scenarios: 4**


---


## 1. Shift-Enter on a module loads its samples one per row

`@shipped @code-verified @hw-untested`


- Given the user is in the F3 Sample List
- And they have a module selected
- When they press Shift-Enter on it
- Then the samples of the module are loaded into consecutive sample slots
- And they display one sample per row

<sub>cite: IT_DISK.ASM LSWindow_ShiftEnter (7764-7986), per-sample Call</sub>


## 2. Loaded samples keep their original names and loop modes

`@shipped @code-verified @hw-untested`


- Given the module's samples have names and loop modes
- When Shift-Enter loads them
- Then each loaded sample shows its ORIGINAL module name
- And its loop mode (off / forward / ping-pong / sustain) is preserved

<sub>cite: each sample goes through LoadSample (IT_DISK.ASM:7928), the standard</sub>


## 3. In Instrument mode each sample is also auto-assigned to an instrument

`@shipped @code-verified @hw-untested`


- Given the user is in Instrument mode
- When Shift-Enter bulk-loads a module
- Then each loaded sample is assigned to an instrument
- And the sample headers (names, loop modes) are unaffected by that assignment

<sub>cite: IT_DISK.ASM 7935-7940 -- if LSBulkInstMode != 0, Call</sub>


## 4. Samples->Instruments envelope retention does NOT clash with this

`@shipped @code-verified @hw-untested`


- Given the envelope-retention feature is merged (PR #3)
- When the user bulk-loads a module with Shift-Enter
- Then no sample name is lost and no loop mode is lost
- And the two features touch disjoint data (sample headers vs instrument headers)
- and fire on disjoint triggers (Shift-Enter key vs F12 toggle)

<sub>cite: PR #3 (9493101) changed ONLY IT_F.ASM + IT_MUSIC.ASM, NOT IT_DISK.ASM · F_SetControlInstrument runs on the F12 mode-flip, not on Shift-Enter;</sub>

