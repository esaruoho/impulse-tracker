# Report Card — Impulse Tracker fork — what got baked in 2026-06-03 → 04

> Source: `features/recent-features-2026-06-03_to_04.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As the musician driving this fork, I want one page that lists every behaviour added/changed in the last two days, each graded honestly and linked to its own detailed card, So that I can see at a glance what is live, what is only build-verified, and what still needs a runtime check.

**Grades:** @build-verified × 11 · @runtime-untested × 4 · @runtime-verified × 5 · @shipped × 11

**Scenarios: 11**


---


## 1. Ctrl-F (and Scroll Lock) jump to the Pattern Editor with Follow ON

`@shipped @build-verified @runtime-verified @hw-untested`


- Given the user is on F3/F4 (verified) or F2/F11/F12 (same binding)
- When the user presses Ctrl-F (or Scroll Lock on F3/F4)
- Then Follow Mode is forced ON and the Pattern Editor opens


## 2. Single-pattern Quicksave renders are LL<HHMMSS>.WAV

`@shipped @build-verified @runtime-verified @hw-untested`


- Given a single-pattern Quicksave render (F11 Shift-Right, Ctrl-O, etc.)
- Then the file is a real .WAV named by wall-clock time, e.g. LL163422.WAV


## 3. A second render gesture mid-render no longer wedges IT

`@shipped @build-verified @runtime-verified @hw-untested`


- Given a render is in progress
- When a second render gesture arrives
- Then it early-stops like Esc and finalizes to Quicksave instead of re-entering teardown


## 4. Multi-WAV per-channel + whole-song WAV/MWAV  (NOT runtime-tested)

`@shipped @build-verified @runtime-untested @hw-untested`


- Given Shift-Alt-M, or the F10 WAV / MWAV buttons
- Then per-channel / whole-song WAVs are rendered -- machinery shipped, NOT yet run


## 5. Shift-Enter on a module row bulk-loads all its samples (.MOD hang fixed)

`@shipped @build-verified @runtime-untested @hw-untested`


- Given a module row in the Sample List loader browser
- When the user presses Shift-Enter
- Then all its samples load into consecutive slots (names + loop modes preserved)


## 6. Shift-F4 cycles multitimbral build + enters Instrument mode

`@shipped @build-verified @runtime-untested @hw-untested`


- Given samples loaded
- When the user presses Shift-F4 and confirms
- Then 01-16 instruments are built, the router is enabled, and Instrument mode shows


## 7. F4 instrument list shows live play dots in multitimbral Sample mode

`@shipped @build-verified @runtime-untested @hw-untested`


- Given multitimbral MIDI-in playing while in Sample mode
- Then F4 mirrors F3 and shows live play dots


## 8. F2 pattern-length increase tiles the existing rows

`@shipped @build-verified @runtime-verified @hw-untested`


- Given an F2 Pattern-Edit-Config row-count increase (e.g. 64 -> 128)
- Then the existing rows are duplicated to fill, not padded with blanks


## 9. Sample Amplify (Alt-M) no longer stops the song

`@shipped @build-verified @runtime-verified @hw-untested`


- Given a song is playing
- When the user amplifies/normalizes a sample with Alt-M
- Then only that sample's voices are silenced; every other channel keeps playing


## 10. F12 Samples->Instruments envelope retention was removed (back to upstream)

`@shipped @build-verified @removal @hw-untested`


- Given F12 Samples->Instruments
- Then it behaves as upstream (clear + remap), the retention path is gone


## 11. Pre-existing features that received their triad card in this window

`@shipped @build-verified @hw-untested`


- Given the report-card system was stood up this window
- Then these existing behaviours each gained a graded, source-linked card

