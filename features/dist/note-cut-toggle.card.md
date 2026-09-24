# Report Card — '1' toggles the note cut under the cursor

> Source: `features/note-cut-toggle.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone editing a pattern, I want pressing '1' on a cell that already shows ^^^ to clear it, So that the same key both places and removes a note cut without reaching for '.'.

**Grades:** @build-verified × 3 · @runtime-untested × 2 · @shipped × 2 · @stock × 1

**Scenarios: 3**


---


## 1. First '1' on an empty (or noted) cell stamps a note cut

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the cursor is on a note cell that does NOT already hold a note cut
- When the user presses '1' (or Shift-'1' = '!')
- Then a note cut (^^^, 0FEh) is written into that cell
- And behaviour is identical to stock IT (cursor advances per the cursor step)

<sub>cite: IT_PE.ASM PE_PatternCursorPos0_3 (~5495) '1'/'!' -> NoteCutToggle ; commit 81e4819 · IT_PE.ASM NoteCutToggle (~5600): [ES:DI] != 0FEh -> JNE WipeNote with AL=0FEh</sub>


## 2. Second '1' on a note-cut cell wipes it

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the cursor is on a note cell that already holds a note cut (^^^)
- When the user presses '1' (or '!')
- Then the cell is erased exactly as pressing '.' would (note <- NONOTE, columns
- per the edit mask)
- And no second ^^^ is stamped

<sub>cite: IT_PE.ASM NoteCutToggle (~5600): [ES:DI] == 0FEh -> AL=NONOTE, Jmp WipeNote · IT_PE.ASM WipeNote (~5534): writes AL into the note byte, clears the</sub>


## 3. Note-off and '.' are unchanged

`@stock @build-verified @hw-untested`


- Given the cursor is on any note cell
- When the user presses '`' / '~' (note-off) or '.' (erase)
- Then those keys behave exactly as in stock IT (note-off stamps ===, '.' erases)

<sub>cite: IT_PE.ASM PE_PatternCursorPos0_3: '`'/'~' still -> WipeNote with AL=0FFh,</sub>

