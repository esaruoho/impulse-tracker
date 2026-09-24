# Report Card — User Presses F11 (Order List)

> Source: `features/f11-order-list.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone sequencing patterns into a song, I want F11 to open the order list and toggle to channel volume, and the fork power tools to clone / extend / render patterns right from the order list, So that arranging and bouncing patterns happens without leaving this screen.

**Grades:** @build-verified × 9 · @hw-verified × 1 · @shipped × 6 · @stock × 3

**Scenarios: 9**


---


## 1. F11 opens the order list with channel panning

`@stock @build-verified`


- Given the user is on a screen other than the order list
- When the user presses F11
- Then CurrentMode becomes 11 and the order list + channel panning screen opens

<sub>cite: IT_OBJ1.ASM:3194 GlobalKeyList F11 -> Glbl_F11 · IT_G.ASM:633 Glbl_F11_2 CurrentMode=11, returns O1_OrderPanningList · IT.TXT:1221 "2.3  Order List, Channel panning & volume. (F11)"</sub>


## 2. A second F11 toggles to channel volume

`@stock @build-verified`


- Given the user is already on the order list panning screen (CurrentMode = 11)
- When the user presses F11
- Then CurrentMode becomes 21 and the channel volume screen opens

<sub>cite: IT_G.ASM:626 Cmp CurrentMode,11 / JE Glbl_F11_1 (CurrentMode=21, · IT.TXT:1239 "initial channel volumes ... F11 once you are already on</sub>


## 3. Stock order-list editing keys

`@stock @build-verified`


- Given the user is editing the order list
- Then Spacebar mutes a channel (on the panning screen)
- And S sets the initial panning to surround
- And N enters (previous order's pattern + 1)

<sub>cite: IT.TXT:1233-1238 spacebar mute, S surround, N = prev order's pattern+1</sub>


## 4. Alt-D clones the current pattern to the first free slot

`@shipped @build-verified @hw-verified`


- Given the user is on the order list with a pattern selected
- When the user presses Alt-D
- Then the pattern is cloned into the first free slot (0..199) and auto-inserted
- And the order cursor advances
- And if mute-wipe is ON, muted channels are wiped with a note-cut at row 0

<sub>cite: IT_PE.ASM:2827 PE_OrderList_ClonePattern; · commits 1a7aa16, 4eee4f8</sub>


## 5. Alt-E doubles the current pattern's length by tiling

`@shipped @build-verified @hw-untested`


- Given the current pattern has N rows
- When the user presses Alt-E
- Then rows 0..N-1 are tiled into N..2N-1, giving a 2N-row pattern
- And nothing happens if 2*N would exceed 200

<sub>cite: IT_PE.ASM:3204 PE_OrderList_ExtendPattern; bails if 2*N > 200; · commit 1a7aa16</sub>


## 6. M toggles the clone mute-wipe mode

`@shipped @build-verified @hw-untested`


- Given the user is on the order list
- When the user presses M
- Then ClonePatternMuteWipe flips (default ON) and the info line shows the state
- And while ON, Alt-D's clone wipes events on currently-muted channels

<sub>cite: IT_PE.ASM:2433 PE_OrderList_ToggleMuteWipe flips ClonePatternMuteWipe · commit 1a7aa16</sub>


## 7. Ctrl-O renders the active pattern to WAV (Shift-Ctrl-O = no import)

`@shipped @build-verified @hw-untested`


- Given the user is on the order list
- When the user presses Ctrl-O
- Then the active pattern is rendered to WAV and auto-imported as the next sample
- When the user instead presses Shift-Ctrl-O
- Then it renders to the Quicksave folder only, with no sample-slot import

<sub>cite: IT_PE.ASM:2338 PE_OrderList_RenderDispatch checks both Shift keys · commit 1a7aa16</sub>


## 8. Ctrl-G and Shift-G render variants

`@shipped @build-verified @hw-untested`


- Given the user is on the order list
- When the user presses Ctrl-G
- Then the pattern renders to Quicksave with no import
- When the user presses Shift-G
- Then the pattern renders with auto-import (plain G keeps the stock goto behaviour)

<sub>cite: IT_PE.ASM:2374 PE_OrderList_RenderQuicksave (Ctrl-G, no import); · commit 1a7aa16</sub>


## 9. Cursor-key edge gestures clone (left) and render (right)

`@shipped @build-verified @hw-untested`


- Given the order cursor is at the left edge of a 3-digit pattern cell
- When the user presses Left (or Shift-Left)
- Then the pattern is cloned verbatim (or cloned with a mute-wipe note-cut)
- Given the order cursor is at the right edge of the cell
- When the user presses Right (or Shift-Right)
- Then the pattern renders with import (or to Quicksave as LL<HHMMSS>.WAV)

<sub>cite: IT_PE.ASM:2269 PE_OrderList_LeftDispatch (col 0: Left=clone verbatim, · IT_PE.ASM:2321 PE_OrderList_RightDispatch (col 2: Right=render+import, · commits 1a7aa16, 90cfd04, 74c3fe8</sub>

