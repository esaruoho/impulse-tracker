# Report Card — Shift-Right on the F5 Info Page renders the playing pattern to Quicksave

> Source: `features/f5-info-page-shift-right-quicksave.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone watching playback on the Info Page, I want Shift-Right to write the pattern I can hear out as a WAV, So that capturing a loop is one key from the screen I am already looking at, without going to F11 first.

**Grades:** @build-verified × 4 · @hw-verified × 2 · @shipped × 4 · @todo × 2

**Scenarios: 8**


---


## 1. Shift-Right renders the playing pattern, no sample import

`@shipped @build-verified @hw-verified`


- Given the song is playing and the user is on the F5 Info Page
- When the user holds Shift and presses Right
- Then the pattern currently being played is rendered to the Quicksave folder
- And no sample slot is consumed (WAV_NoImport armed)
- And the channel selection does not move

<sub>cite: IT_DISPL.ASM DisplayListKeys - DB 4 / DW 1CDh -> Display_RenderQuicksave · IT_DISPL.ASM Display_ResolvePattern - Music_GetPlayMode CX=CurrentPattern · IT_MUSIC.ASM Music_ArmRenderNoImport then Music_ToggleWAVRender (AX=pattern)</sub>


## 2. Plain Right still moves the channel selection

`@shipped @build-verified @hw-verified`


- Given the user is on the F5 Info Page
- When the user presses Right without shift
- Then the selected channel moves down, as it always did

<sub>cite: IT_DISPL.ASM DisplayListKeys - DB 0 / DW 1CDh -> DisplayDown, the</sub>


## 3. Stopped, it falls back to the pattern in the editor

`@shipped @build-verified @hw-untested`


- Given playback is stopped and the user is on the F5 Info Page
- When the user holds Shift and presses Right
- Then the pattern currently loaded in the editor is rendered instead

<sub>cite: IT_DISPL.ASM Display_ResolvePattern - PlayMode 0 -> PE_GetCurrentPattern</sub>


## 4. A bogus pattern number is refused rather than rendered

`@shipped @build-verified @hw-untested`


- Given the resolved pattern number is 200 or higher
- When the user holds Shift and presses Right
- Then nothing is rendered and the gesture is a no-op

<sub>cite: IT_DISPL.ASM Display_ResolvePattern - Cmp AX,200 / JAE fail; CF=1</sub>


## 5. It IS a "DB 4" keymap row -- the first attempt got this wrong

`@corrected`


- Given a modified key must be caught by the keymap, not by the handler
- Then the arrow is registered twice, exactly as OrderListKeys does it


## 6. Why the Info Page resolves the pattern differently from F11

`@design-note`


- Given the Info Page has no order cursor to point with
- Then the stopped-case fallback is the editor's pattern, not an order row


## 7. Ctrl-Shift-Right dumps every sample in the song as WAVs

`@todo`


- Given the user is on the F5 Info Page
- When the user holds Ctrl and Shift and presses Right
- Then every loaded sample is written out as its own WAV file


## 8. Enter on the Info Page jumps to the playing pattern at the playing row

`@todo`


- Given the user is on the F5 Info Page with a channel selected
- When the user presses Enter
- Then the pattern editor opens on that pattern, that channel and that row

