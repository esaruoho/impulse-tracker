# Report Card — Flipping every channel mute at once

> Source: `features/invert-channel-mutes.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone auditioning the complement of a mix, I want one key to invert all the mutes, So that I can flip between two halves of an arrangement without clicking through channels.

**Grades:** @build-verified × 2 · @shipped × 2 · @todo × 1

**Scenarios: 4**


---


## 1. Ctrl-F9 inverts all 64 channels

`@shipped @build-verified @hw-untested`


- Given some channels are muted and others are not
- When the user presses Ctrl-F9
- Then every channel's mute state is inverted

<sub>cite: IT_MUSIC.ASM Music_InvertChannelMutes -- loops channels 0..63 · IT_OBJ1.ASM GlobalKeyList -- DB 3 / DW 143h, so it works on any screen</sub>


## 2. Pressing it twice returns exactly to the start

`@shipped @build-verified @hw-untested`


- Given any arrangement of mutes
- When the user presses Ctrl-F9 twice
- Then the mute state is exactly what it was


## 3. Why it loops Music_ToggleChannel instead of writing the table

`@design-note`


- Given the mute state is recorded in more than one place
- Then the existing per-channel toggle is reused rather than reimplemented


## 4. A key that does not need the fn row on a laptop

`@todo`


- Given a keyboard without a dedicated function row
- Then a letter-based chord might be preferable

