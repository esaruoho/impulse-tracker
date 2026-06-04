# Report Card — Order List F6 loops the selected order's pattern; F7 plays from it at the cursor row

> Source: `features/f6-play-from-order-list-row.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone arranging a song in the F11 Order List, I want F6 to loop the pattern at the order row I selected, and F7 to start playback from that order at the row my edit cursor is on, So that I can audition any order's pattern in place, and resume the song from any order at the exact row I was working on.

**Grades:** @build-verified × 5 · @runtime-untested × 2 · @shipped × 4 · @stock × 1

**Scenarios: 5**


---


## 1. F6 loops the pattern at the selected order row

`@shipped @build-verified @runtime-untested`


- Given the user is in the Order List (F11, CurrentMode==11)
- And the cursor is on order row N, whose pattern is P
- When the user presses F6
- Then pattern P plays, LOOPING (not advancing through the order list)
- And the row count comes from P's own header, so it loops correctly

<sub>cite: IT_G.ASM Glbl_F6: Cmp CurrentMode,11 -> Call PE_OrderListLoopPattern · IT_PE.ASM PE_OrderListLoopPattern: Order -> pattern via SongSeg:100h+Order; · commit 5b37353</sub>


## 2. F6 outside the Order List keeps its stock "play current pattern"

`@shipped @build-verified`


- Given the user is on any screen other than the Order List
- When the user presses F6
- Then the editor's current pattern is played (stock behaviour)

<sub>cite: the CurrentMode==11 gate; the JNE branch is the original</sub>


## 3. A skip/end marker order slot is a no-op

`@shipped @build-verified`


- Given the selected order row holds a "++" (254) or end (255) marker
- When the user presses F6
- Then nothing plays (there is no pattern at that slot)

<sub>cite: PE_OrderListLoopPattern: Cmp AL,254 / JAE done (0FEh ++ / 0FFh end)</sub>


## 4. F7 plays from the SELECTED order at the current edit row

`@shipped @build-verified @runtime-untested`


- Given the edit cursor is on row R (e.g. 048, set in some pattern)
- And the user is in the Order List with the cursor on order row N
- When the user presses F7
- Then Music_PlayPartSong starts playback at order N, row R

<sub>cite: IT_PE.ASM PE_F7: Cmp CurrentMode,11 -> Music_PlayPartSong(Order, Row) · commit 5b37353</sub>


## 5. F7 outside the Order List keeps its stock from-mark behaviour

`@stock @build-verified`


- Given the user is on the Pattern Editor (not the Order List)
- When the user presses F7
- Then playback starts from the playback mark (or current pattern+row), as before

<sub>cite: PE_F7_Stock branch = the original PlayMark / current-pattern+row logic</sub>

