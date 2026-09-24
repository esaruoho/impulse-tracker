# Report Card — Alt-R replicate at cursor

> Source: `features/alt-r-replicate.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone filling a pattern channel with a repeating figure, I want Alt-R to tile the rows above the cursor down to the end of the channel, So that I can lay down a one- or few-row loop and stamp it across the pattern without copy/paste — while Shift-Alt-R does the same across the WHOLE pattern (all channels).

**Grades:** @build-verified × 7 · @hw-verified × 6 · @runtime-untested × 1 · @runtime-verified × 3 · @shipped × 7

**Scenarios: 8**


---


## 1. Ctrl-Down and Ctrl-Shift-Down do the same thing as Alt-R

`@shipped @build-verified @hw-untested`


- Given the user is in the pattern editor
- When they press Ctrl-Down
- Then the rows above the cursor are replicated down this track
- When they press Ctrl-Shift-Down
- Then they are replicated across the whole pattern

<sub>cite: IT_PE.ASM PEFunctions -- DB 3 / DW 1D0h -> PEFunction_AltR_Dispatch · features/KEYMAPS.generated.md, the PEFunctions table</sub>


## 2. What Ctrl-Down displaced, and why that is free

`@design-note`


- Given next-instrument has three other bindings
- Then handing Ctrl-Down to replicate costs nothing


## 3. Alt-R and Shift-Alt-R are disambiguated by live shift state

`@shipped @build-verified @hw-verified`


- Given the pattern editor with the keyword 1300h bound to the Alt-R dispatcher
- When the user presses Alt-R with no shift held
- Then control goes to PEFunction_ReplicateAtCursor (replicate current TRACK)
- When the user presses Alt-R with either shift held
- Then control goes to PEFunction_ReplicatePatternAtCursor (replicate whole PATTERN)

<sub>cite: IT_PE.ASM PEFunction_AltR_Dispatch — both keys map to 1300h</sub>


## 4. Cursor above row 0 tiles the rows-above-cursor chunk downward

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the cursor is on Row R (R > 0) of the current channel
- Then the source chunk is rows 0..R-1 of that channel (length R)
- And rows R..MaxRow of the SAME channel are filled by repeating that chunk
- And empty events are copied through as-is (mirror semantics, exact tiling)

<sub>cite: IT_PE.ASM PEFunction_ReplicateAtCursor (8308); commit d506486</sub>


## 5. Cursor on row 0 tiles row 0 down the whole channel

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the cursor is on Row 0 of the current channel
- Then the source chunk is row 0 itself (length 1)
- And rows 1..MaxRow are filled with copies of row 0

<sub>cite: IT_PE.ASM PEFunction_ReplicateAtCursor row==0 branch (~8316); aaada5e</sub>


## 6. No-op at the pattern edges

`@shipped @build-verified @hw-verified`


- Given the cursor is past MaxRow, or the destination start is past MaxRow
- (e.g. a 1-row pattern)
- Then Replicate does nothing (clean no-op)

<sub>cite: IT_PE.ASM PEFunction_ReplicateAtCursor guards (8310-8312)</sub>


## 7. Shift-Alt-R replicates the whole PATTERN at cursor

`@shipped @build-verified @runtime-verified @hw-verified`


- Given the cursor is on Row R of the pattern
- When the user presses Shift-Alt-R
- Then Shift+Alt+R reaches the dispatcher (cond-11 keymap entry) and is routed here
- And if R > 0, rows 0..R-1 (ALL channels) tile down to fill rows R..MaxRow
- And if R == 0, row 0 (all channels) tiles down the whole pattern

<sub>cite: IT_PE.ASM PEFunction_ReplicatePatternAtCursor; commit 5fb263b</sub>


## 8. Both replicate ops are undoable and show a correct label in the undo list

`@shipped @build-verified @runtime-untested @hw-verified`


- Given the user has performed an Alt-R or Shift-Alt-R replicate
- When they open the undo list with Ctrl-Backspace
- Then the step is named "Replicate Track Above (Alt-R)" (Alt-R) or
- "Replicate Pattern Above (Sh-Alt-R)" (Shift-Alt-R), not blank/garbage
- And selecting it reverts the pattern to its pre-replicate state

<sub>cite: IT_PE.ASM PEFunction_ReplicateAtCursor (DI=23) + PEFunction_ReplicatePatternAtCursor · IT_PE.ASM PEFunction_DrawUndo (~13845) indexes UndoBufferTypes by tag low byte</sub>

