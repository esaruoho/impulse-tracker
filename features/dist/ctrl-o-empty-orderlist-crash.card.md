# Report Card — Order-list and Ctrl-O render gestures must never crash, reboot, or hang

> Source: `features/ctrl-o-empty-orderlist-crash.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As an Impulse Tracker user rendering a pattern to WAV, I want every render gesture to be safe regardless of order-list state, So that Ctrl-O, right-arrow, and Shift-right can't reboot DOS or wedge the program.

**Grades:** @build-verified × 6 · @runtime-untested × 6 · @shipped × 6

**Scenarios: 7**


---


## 1. an out-of-range pattern number resolves to EmptyPattern, never a wild pointer

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the playback engine asks for a pattern numbered 200 or higher
- When Music_GetPattern is called with that number
- Then it returns the safe EmptyPattern instead of indexing past the 200-entry table
- And no LodsW dereferences a segment read from out-of-bounds garbage

<sub>cite: IT_MUSIC.ASM Music_GetPattern (~3504) — Cmp AX,200 / JAE Music_GetPattern_Empty</sub>


## 2. empty order list, F6 playing, Ctrl-O — no longer reboots

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the order list has zero pattern entries (OrderList[0] = 0FFh end marker)
- And a song is playing because the user pressed F6
- When the user presses Ctrl-O to render the pattern to WAV
- Then the resume sets CurrentPattern to 255 but the next Music_GetPattern returns EmptyPattern
- And Impulse Tracker keeps running instead of triple-faulting and rebooting DOS

<sub>cite: trigger Music_PlayPartSong (~9402) sets CurrentPattern=0FFh; the</sub>


## 3. a single-pattern render stops after one pass instead of hanging

`@shipped @build-verified @runtime-untested @hw-untested`


- Given one pattern (000) in the order list and the cursor on the order list
- When the user presses right-arrow at the edge (promotes to a render)
- Then the pattern renders exactly one pass, PlayMode hits 0, the sync loop exits
- And IT finalizes the WAV instead of spinning the 100000-iteration cap (the hang)

<sub>cite: IT_MUSIC.ASM Music_ToggleWAVRender — StopEndOfPlaySection=1 before the</sub>


## 4. the render terminator never leaks into normal playback

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a single-pattern render has finished and cleaned up
- When the user afterwards presses F5 or F6 to play normally
- Then playback loops as before (StopEndOfPlaySection is back to 0)

<sub>cite: IT_MUSIC.ASM WAV_LeavePostImport clears StopEndOfPlaySection to 0; commit 4041e66</sub>


## 5. all three gestures share the one hardened render path

`@shipped @build-verified @runtime-untested @hw-untested`


- Given Ctrl-O (auto-import), right-arrow (auto-import), and Shift-right (Quicksave-only)
- When any of them triggers a single-pattern render
- Then all flow through Music_ToggleWAVRender with the bound guard and the terminator
- And none can reboot or hang on an empty or one-pattern order list

<sub>cite: IT_PE.ASM PE_OrderList_RightDispatch -> RenderDispatch (shift = Quicksave-only),</sub>


## 6. each render writes a back-and-forth debug line to CTRLOLOG.TXT

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a render gesture runs with the Quicksave folder set to E:\ITNU2026
- When the render enters and (for a single pattern) finishes its sync loop
- Then CTRLOLOG.TXT gains an "E pat=.. o0=.. se=.." inputs line and an "X .. it=.." outcome line
- And the operator on the Mac reads it at /Volumes/netdrive/ITNU2026/CTRLOLOG.TXT
- And it=0000 on the X line flags a render that hit the cap (hung); o0=00FF flags an empty order list

<sub>cite: IT_MUSIC.ASM WAV_LogState — 'E' line after START (inputs), 'X' line at</sub>


## 7. the reboot leak SOURCE (Music_PlayPartSong) is documented, not yet hardened

`@known-limit`


- Given Music_PlayPartSong is a public proc used by resume and other callers
- When it starts at an order whose byte is a 0FEh/0FFh marker
- Then it still stores that marker as CurrentPattern (semantically wrong)
- But the Music_GetPattern sink guard prevents the catastrophic out-of-bounds dereference

<sub>cite: IT_MUSIC.ASM Music_PlayPartSong (~9402) still stores OrderList[order] with no marker check</sub>

