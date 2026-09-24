# Report Card — Multi-WAV render

> Source: `features/multi-wav.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone bouncing a tune to stems or a mix, I want to render the current pattern per channel, or the whole song as one WAV or as per-channel stems, So that I can take Impulse Tracker output into another DAW — NOTE: this whole feature is shipped but NOT yet runtime-tested (see header).

**Grades:** @build-verified × 4 · @runtime-untested × 4 · @shipped × 4

**Scenarios: 5**


---


## 1. Shift-Alt-M renders the current pattern per non-empty channel

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the pattern editor on a pattern with several non-empty channels
- When the user presses Shift-Alt-M
- Then each non-empty channel is rendered to its own WAV (empty channels skipped)
- And plain Alt-M still does block-mix (3200h), unchanged

<sub>cite: IT_PE.ASM PEFunction_StartMultiWAVKey (8267) -> Music_StartMultiWAV;</sub>


## 2. F10 "WAV" renders the whole song to a single WAV

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a loaded song
- When the user activates the F10 "WAV" button
- Then the entire song is rendered to one WAV in the render folder

<sub>cite: IT_MUSIC.ASM Music_StartFullSongWAV (2621); commit 9fb5ac1</sub>


## 3. F10 "MWAV" renders the whole song as per-channel stems

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a loaded song
- When the user activates the F10 "MWAV" button
- Then the song is rendered once per non-empty/non-muted channel (stems)

<sub>cite: IT_MUSIC.ASM Music_StartFullSongMWAV (2859); commit 9fb5ac1</sub>


## 4. The Shift+Alt keymap path exists (this part IS structural)

`@shipped @build-verified @hw-untested`


- Given IT's keymap could not previously express a Shift+Alt combo for M
- Then K_TranslateCondition11 supplies one, mapping Shift-Alt-M to 3232h

<sub>cite: IT_K.ASM K_TranslateCondition11 (1457) emits 3232h for Shift+Alt-M</sub>


## 5. WHAT WOULD VERIFY THIS CARD (the test that has not been run)

`@runtime-untested`


- Given IT.EXE running in DOSBox-X with a multi-channel tune loaded
- When Shift-Alt-M / F10 WAV / F10 MWAV are each triggered
- Then the expected WAV file(s) appear in the render folder, non-zero, and play
- And only THEN do the scenarios above lose their @runtime-untested tag

