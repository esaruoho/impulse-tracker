# Report Card — Tapping right shift jumps to the pattern being played

> Source: `features/right-shift-tap.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone jamming with a song running, I want a tap of right shift to drop me into the playing pattern with Follow on, So that "listening" and "editing what I hear" are one key apart, while holding right shift as a modifier keeps working normally.

**Grades:** @build-verified × 3 · @hw-verified × 3 · @shipped × 3 · @todo × 1

**Scenarios: 9**


---


## 1. A tap from any other screen opens the playing pattern with Follow on

`@shipped @build-verified @hw-verified`


- Given the song is playing and the user is on the sample, instrument or info page
- When they tap right shift and release it
- Then the pattern editor opens on the pattern being played
- And Follow Mode is on

<sub>cite: IT_M.ASM M_KeyBoardInput1 -- on a tap, CX=DX=146h and control jumps to · IT_OBJ1.ASM GlobalKeyList - DB 0 / DW 146h -> PE_ScrollLockFollow · IT_PE.ASM PE_ScrollLockFollow - forces TracePlayback=1, lights the</sub>


## 2. A tap inside the pattern editor toggles Follow Mode off

`@shipped @build-verified @hw-verified`


- Given the user is in the pattern editor with Follow Mode on
- When they tap right shift
- Then Follow Mode is switched off and the screen does not change

<sub>cite: IT_PE.ASM PE_ScrollLockFollow - Glbl_GetCurrentMode == 2 -> PE_SLF_Toggle,</sub>


## 3. Holding it as a modifier is not a tap

`@shipped @build-verified @hw-verified`


- Given the user holds right shift and presses another key
- When right shift is released
- Then nothing is dispatched and the other key behaves normally

<sub>cite: IT_K.ASM K_GetKey -- Cmp SI,36h / else Mov [RShiftTapArmed],0, so any</sub>


## 4. The tap must have exactly ONE consumer

`@corrected`


- Given a one-shot poll has two callers
- Then the first caller consumes the event and the second never sees it


## 5. K_GetKey's spin is NOT the idle loop -- that cost a whole round trip

`@corrected`


- Given a loop that waits for a key is not necessarily the loop that idles
- Then the poll belongs where the dispatcher decides it has nothing to do


## 6. "Any other key down?" must come from the key QUEUE, not the key-down map

`@corrected`


- Given a key-down map is only as good as the releases that reached it
- Then the disarm is driven by processed scancodes instead


## 7. The probe shipped, proved the point, and was removed again

`@design-note`


- Given a gesture that silently does nothing has several possible causes
- Then instrument the transitions, then take the instrument back out


## 8. Why Scroll Lock's key word and not a new one

`@design-note`


- Given an existing global key already does exactly this
- Then the new trigger synthesizes that key rather than duplicating its handler


## 9. Left shift is deliberately untouched

`@todo`


- Given the user taps LEFT shift
- Then nothing happens

