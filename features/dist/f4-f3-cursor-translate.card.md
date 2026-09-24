# Report Card — F4<->F3 carry the cursor selection across the two list screens

> Source: `features/f4-f3-cursor-translate.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone moving between the Instrument List (F4) and Sample List (F3), I want the selection to follow me to the matching slot, So that switching screens lands on the related sample/instrument instead of resetting to wherever the other list's cursor happened to be.

**Grades:** @build-verified × 4 · @runtime-untested × 3 · @shipped × 4

**Scenarios: 4**


---


## 1. F3 from the Instrument List lands on the instrument's note-60 sample

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the user is on the F4 Instrument List with an instrument selected
- When the user presses F3
- Then the Sample List opens with the cursor on the sample that instrument plays at C-5

<sub>cite: IT_G.ASM Glbl_InstrumentToSample -- from LastInstrument, read the sample</sub>


## 2. Note-60-first, then scan all 120 notes for the first non-empty

`@shipped @build-verified @runtime-untested @hw-untested`


- Given an instrument whose note 60 (C-5) maps to no sample
- When F3 translation runs
- Then it scans all 120 notes and lands on the first non-empty sample mapping

<sub>cite: commit 672273b -- if the C-5 entry is empty, scan notes 0..119 for the</sub>


## 3. The reverse maps a sample back to an instrument

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the user is on the F3 Sample List
- When the user crosses to F4
- Then the instrument selection is translated from the current sample

<sub>cite: IT_G.ASM Glbl_SampleToInstrument -- translates the other direction</sub>


## 4. 16-bit safe (no 386-only instruction)

`@shipped @build-verified`


- Given IT_G.ASM is 16-bit real-mode code
- Then the translation uses Xor BH,BH / Mov BL,AL, never the 386-only Movzx

<sub>cite: 672273b replaced Movzx (386-only) with Xor BH,BH / Mov BL,AL -- IT_G.ASM</sub>

