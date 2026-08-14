---
name: User Presses Scroll Lock while in F3 (Sample List) or F4 (Instrument List)
slug: user-presses-scroll-lock-while-in-f3-sample-list-or-f4-instrument-list
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/dist/scrolllock-follow-from-lists.gherkin.feature.

## Claims
- Scenario (L13): Scroll Lock inside the Pattern Editor still just toggles Follow Mode
- Scenario (L22): Scroll Lock in the Sample List opens the Pattern Editor with Follow Mode on
- Scenario (L35): Scroll Lock in the Instrument List does the same
- Scenario (L52): Ctrl-F in the Sample List (F3) or Instrument List (F4)
- Scenario (L61): Ctrl-F INSIDE the Pattern Editor (F2) toggles Follow Mode, not the config dialog
- Scenario (L77): Ctrl-F on the Order List (F11) or Song Variables (F12) enters the editor
- Scenario (L86): Follow Mode is forced ON, never toggled off, from the lists
- Scenario (L97): The handler hands Glbl_F2 the dispatcher's own DS (no segment damage)
- Scenario (L110): (not built) Scroll Lock / Ctrl-F from other screens (Order list F11, Song vars F12)
- Scenario (L106): Scroll Lock inside the Pattern Editor still just toggles Follow Mode
- Scenario (L116): Scroll Lock in the Sample List opens the Pattern Editor with Follow Mode on
- Scenario (L130): Scroll Lock in the Instrument List does the same
- Scenario (L147): Ctrl-F in the Sample List (F3) or Instrument List (F4)
- Scenario (L156): Ctrl-F INSIDE the Pattern Editor (F2) toggles Follow Mode, not the config dialog
- Scenario (L174): Ctrl-F on the Order List (F11) or Song Variables (F12) enters the editor
- Scenario (L183): Follow Mode is forced ON, never toggled off, from the lists
- Scenario (L194): The handler hands Glbl_F2 the dispatcher's own DS (no segment damage)
- Scenario (L207): (not built) Scroll Lock / Ctrl-F from other screens (Order list F11, Song vars F12)

## Relationships
