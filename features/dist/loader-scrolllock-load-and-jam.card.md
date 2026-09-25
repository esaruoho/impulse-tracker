# Report Card — Scroll Lock in the loader loads the sample and drops me into the editor

> Source: `features/loader-scrolllock-load-and-jam.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone auditioning samples in the loader, I want one key that loads the highlighted sample, makes it an instrument, and puts me in the Pattern Editor, So that I can go from "found a sound" to "jamming with it" without a detour.

**Grades:** @build-verified × 14 · @runtime-untested × 14 · @shipped × 14

**Scenarios: 14**


---


## 1. Scroll Lock loads the sample, makes an instrument, and enters the editor

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the Load-Sample view is open with a sample highlighted
- When I press Scroll Lock
- Then the highlighted sample is loaded into the current sample slot
- And Instrument mode is forced on (bit 2 of [songseg:2Ch])
- And an instrument is created for that sample and selected as current
- And the Pattern Editor opens with Follow Mode on, ready to jam

<sub>cite: IT_DISK.ASM LSViewWindow_ScrollLock ; commit 8f6a5cd</sub>


## 2. Loader jump keys do not disturb the loader's core tools

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the loader keyjazz, Enter, and cursor keys work as before
- When the Scroll Lock and Caps Lock entries are added to LSViewWindowKeys
- Then keyjazz, Enter (LSViewWindow_Enter) and Up/Down are byte-for-byte unchanged
- And only the jump-to-editor loader shortcuts gain behaviour in this window

<sub>cite: IT_DISK.ASM LSViewWindowKeys 146h/13Ah entries (added before the 0FFh terminator)</sub>


## 3. Scroll Lock in the editor toggles Follow

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am in the Pattern Editor
- When I press Scroll Lock
- Then Follow Mode toggles exactly as before (no round-trip)
- And Ctrl-F toggles Follow Mode regardless of how I got here

<sub>cite: IT_PE.ASM PE_ScrollLockDispatch falls through to PE_ScrollLockFollow</sub>


## 4. Shift-Scroll Lock in the editor always reopens Sample Load

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am in the Pattern Editor
- When I press Shift-Scroll Lock
- Then the Sample Load view opens
- And plain Scroll Lock keeps its existing Follow-toggle behavior

<sub>cite: IT_PE.ASM pattern-editor Scroll Lock rows -> PE_ScrollLockDispatch, · IT_PE.ASM PE_ScrollLockLoadSample tail-jumps to Glbl_LoadSample.</sub>


## 5. Shift-F3 opens Sample Load directly

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am on a screen that chains to GlobalKeyList
- When I press Shift-F3
- Then the Sample Load view opens directly
- And it does not merely stop at the Sample List

<sub>cite: IT_OBJ1.ASM GlobalKeyList Shift-F3 row -> Glbl_LoadSample.</sub>


## 6. Pattern Editor fallback keys open Sample Load directly

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am in the Pattern Editor
- When I press Caps Lock or Pause/Break
- Then the Sample Load view opens directly

<sub>cite: IT_PE.ASM pattern-editor keylist Caps Lock row -> PE_CapsLoadSample</sub>


## 7. Caps Lock from any global screen opens Sample Load directly

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am on F3, F4, F11, F12, Load Song, or another screen that chains to GlobalKeyList
- When I press Caps Lock
- Then the Sample Load view opens directly
- And the Caps round-trip latch is armed so the loader Caps key returns to the editor

<sub>cite: IT_OBJ1.ASM GlobalKeyList Caps Lock row (13Ah) -> PE_CapsLoadSample. · IT_PE.ASM PE_CapsLoadSample captures PE_GetLastInstrument, arms the</sub>


## 8. Caps Lock in Sample Load loads and returns

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I opened Sample Load with Caps Lock
- And a sample is highlighted in Sample Load
- When I press Caps Lock again
- Then the highlighted sample is loaded
- And the instrument binding path runs
- And the Pattern Editor opens without changing Follow Mode

<sub>cite: IT_PE.ASM PE_CapsLoadSample sets PE_CapsRoundTrip and latches the</sub>


## 9. Caps Lock loading keeps its destination while playback advances

`@shipped @build-verified @runtime-untested @hw-untested`


- Given playback is advancing the song order
- When I use Caps Lock to open Sample Load and Caps Lock to load a sample
- Then the sample is loaded into the destination slot captured on entry
- And its instrument binding uses that same destination slot

<sub>cite: IT_PE.ASM PE_CapsLoadSample captures PE_GetLastInstrument before</sub>


## 10. Loader instrument creation never falls back to another number

`@shipped @build-verified @runtime-untested @hw-untested`


- Given sample N is being loaded
- And instrument N is occupied by a different sample
- When the loader creates the instrument binding
- Then it does not overwrite instrument N
- And it does not bind sample N to an unrelated first-free instrument

<sub>cite: IT_MUSIC.ASM Music_AssignSampleToInstrumentExact refuses the</sub>


## 11. Loader allocates the first unused matching sample/instrument pair

`@shipped @build-verified @runtime-untested @hw-untested`


- Given samples and instruments 1 through 15 are already in use as matching pairs
- When I load another sample with Caps Lock or Scroll Lock
- Then it is loaded into sample 16
- And instrument 16 is created and selected
- And instrument 16 triggers sample 16

<sub>cite: IT_MUSIC.ASM Music_FindFreeMatchingSlot scans sample and instrument</sub>


## 12. Sample Loader Scroll Lock returns with Follow Mode on

`@shipped @build-verified @runtime-untested @hw-untested`


- Given I am in Sample Load without a Caps Lock round-trip latch
- And a sample is highlighted in Sample Load
- When I press Scroll Lock
- Then the Pattern Editor opens with Follow Mode on

<sub>cite: IT_DISK.ASM LSViewWindow_ScrollLock clears any Caps round-trip</sub>


## 13. If the instrument assign fails, it still drops me in to jam on the sample

`@shipped @build-verified @runtime-untested @hw-untested`


- Given the sample loaded but no instrument slot could be assigned
- When Music_AssignSampleToInstrument returns carry
- Then the macro skips the select step
- And still jumps to the Pattern Editor with Follow Mode on

<sub>cite: IT_DISK.ASM LSViewWindow_ScrollLock JC LSVSL_Go on Music_AssignSampleToInstrument ; commit 8f6a5cd</sub>


## 14. Samples Mode songs get instrument backfill before Scroll Lock jams

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a song is in Samples Mode
- And sample 1 is already loaded and used by a pattern hihat
- When I press Scroll Lock in the sample loader to load another sample
- Then Instrument mode is enabled
- And the pre-existing loaded samples receive matching instruments
- And the newly loaded sample still receives and selects its own instrument

<sub>cite: IT_DISK.ASM LSViewWindow_ScrollLock checks Music_GetInstrumentMode · IT_DISK.ASM LSVSL_BackfillInstruments scans loaded sample headers</sub>

