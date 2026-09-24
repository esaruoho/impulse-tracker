# Report Card — Undo steps are named via the UndoBufferTypes table

> Source: `features/undo-messaging.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As a maintainer adding a pattern-editing operation, I want a documented, repeatable way to give my operation a readable undo-list name, So that pressing Ctrl-Backspace shows "what this step was" instead of a blank or garbage label, and the knowledge of how to do it never gets lost.

**Grades:** @build-verified × 4 · @runtime-untested × 1 · @runtime-verified × 4 · @shipped × 1 · @stock × 3

**Scenarios: 6**


---


## 1. Each undo slot stores a TYPE number that indexes a string table

`@howto @stock @build-verified @runtime-verified`


- Given the 10-deep undo buffer
- When a step is recorded
- Then its slot holds a type word, and UndoBufferTypes[type] points at its label

<sub>cite: IT_PE.ASM:375 UndoBuffer = 10 entries x 4 bytes: [seg/handle][type word] · IT_PE.ASM:378 UndoBufferTypes = parallel offset table (one DW per type) · IT_PE.ASM:393-417 UndoBufferType0..24 = the null-terminated label strings</sub>


## 2. Recording an undo step assigns its type

`@howto @stock @build-verified @runtime-verified`


- Given an edit op that mutates pattern data
- When it does `Mov DI, <type>` then `Call PE_AddToUndoBuffer`
- Then the pattern is snapshotted AND the step is tagged with <type>

<sub>cite: IT_PE.ASM:13708 PE_AddToUndoBuffer; :13712 "Parameter: DI = buffer TYPE";</sub>


## 3. The undo list draws each step's name from the table

`@howto @stock @build-verified @runtime-verified`


- Given the user presses Ctrl-Backspace
- When the undo list is drawn
- Then each of the 10 rows shows UndoBufferTypes[its type] as its label

<sub>cite: IT_PE.ASM:13865 PEFunction_DrawUndo; :13887 Mov SI,[UndoBufferTypes+SI]</sub>


## 4. Adding a new named undo step (the four-step recipe)

`@howto`


- Given a new pattern-editing operation that needs an undo step
- When the maintainer wires it up
- Then they (1) add a string `UndoBufferTypeN DB "My Label", 0` after the last one
- And  (2) add a matching `DW Offset UndoBufferTypeN` to the UndoBufferTypes table
- (MANDATORY — see the off-the-end bug below)
- And  (3) make the op call `Mov DI, N` / `Call PE_AddToUndoBuffer` BEFORE it mutates
- And  (4) (optional) format codes in the string: `0FDh,"D"` draws a decimal number
- (e.g. UndoBufferType22 "Pattern <n>"); `0FFh,N` pads/aligns a trailing
- key hint. Plain inline keys like "(Alt-R)" need no codes and are fine.


## 5. A type with no offset-table entry draws garbage (the trap)

`@howto @bug @runtime-verified`


- Given an op passes a type number with no UndoBufferTypes[type] entry
- When the undo list is drawn
- Then PEFunction_DrawUndo reads past the table and draws a garbage/blank label
- And the fix is ALWAYS to add the offset-table DW, not just the string

<sub>cite: commit 3a3b7ff (added UndoBufferType23/24 + their offset-table DWs)</sub>


## 6. Worked example - Alt-R / Shift-Alt-R replicate labels

`@howto @shipped @build-verified @runtime-untested`


- Given Alt-R (type 23) and Shift-Alt-R (type 24) replicate ops
- When the user undoes one via Ctrl-Backspace
- Then it is named "Replicate Track Above (Alt-R)" or "Replicate Pattern Above (Sh-Alt-R)"

<sub>cite: IT_PE.ASM:416 UndoBufferType23 "Replicate Track Above (Alt-R)" · IT_PE.ASM:417 UndoBufferType24 "Replicate Pattern Above (Sh-Alt-R)" · IT_PE.ASM PEFunction_ReplicateAtCursor (DI=23) / ReplicatePatternAtCursor</sub>

