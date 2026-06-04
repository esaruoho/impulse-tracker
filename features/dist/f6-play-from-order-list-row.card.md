# Report Card — F6 in the Order List plays the song from the selected order row

> Source: `features/f6-play-from-order-list-row.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone arranging a song in the F11 Order List, I want F6 to start playback from the order row I have selected, So that I can audition the song from any point in the arrangement without jumping back to the pattern editor or to order 0.

**Grades:** @build-verified × 4 · @runtime-untested × 1 · @shipped × 3 · @stock × 1

**Scenarios: 4**


---


## 1. F6 on a selected order row starts the song from that order

`@shipped @build-verified @runtime-untested`


- Given the user is in the Order List (F11, CurrentMode==11)
- And the cursor is on order row N
- When the user presses F6
- Then Music_PlaySong starts the song from order N
- And playback continues through the order list from there

<sub>cite: IT_G.ASM Glbl_F6: Cmp CurrentMode,11 / JNE stock; in the order list · IT_MUSIC.ASM Music_PlaySong (9106) AX=Order ; commit 8acb41f</sub>


## 2. F6 outside the Order List keeps its stock "play current pattern"

`@shipped @build-verified`


- Given the user is on any screen other than the Order List
- When the user presses F6
- Then the current pattern is played (stock behaviour), not an order

<sub>cite: the gate is CurrentMode==11 only; the JNE branch is the original</sub>


## 3. F7 already plays "from row" relative to the order list

`@stock @build-verified`


- Given the user is in the Order List with a playback mark or current row
- When the user presses F7
- Then playback starts from that row at the corresponding order (pre-existing)

<sub>cite: IT_PE.ASM PE_F7 (13254): uses PlayMark (or current pattern+Row),</sub>


## 4. Song-from-order, not a single looped pattern (design choice)

`@shipped @build-verified`


- Given F6 is pressed on order row N in the Order List
- When playback starts
- Then it does not loop a single pattern; it plays the arrangement from N onward

