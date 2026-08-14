---
name: Shift-Right on the F5 Info Page renders the playing pattern to Quicksave
slug: shift-right-on-the-f5-info-page-renders-the-playing-pattern-to-quicksave
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/f5-info-page-shift-right-quicksave.feature.

## Claims
- Scenario (L53): Shift-Right renders the playing pattern, no sample import
- Scenario (L64): Plain Right still moves the channel selection
- Scenario (L72): Stopped, it falls back to the pattern in the editor
- Scenario (L79): A bogus pattern number is refused rather than rendered
- Scenario (L86): It IS a "DB 4" keymap row -- the first attempt got this wrong
- Scenario (L105): Why the Info Page resolves the pattern differently from F11
- Scenario (L118): Ctrl-Shift-Right dumps every sample in the song as WAVs
- Scenario (L128): Enter on the Info Page jumps to the playing pattern at the playing row

## Relationships
