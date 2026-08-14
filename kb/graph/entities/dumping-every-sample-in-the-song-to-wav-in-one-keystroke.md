---
name: Dumping every sample in the song to WAV in one keystroke
slug: dumping-every-sample-in-the-song-to-wav-in-one-keystroke
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/dump-all-samples-wav.feature.

## Claims
- Scenario (L37): Ctrl-Shift-Right, or D, writes every loaded sample
- Scenario (L48): 8-bit samples are converted, not dumped raw
- Scenario (L59): The song's own sample filenames are left alone
- Scenario (L68): A bad Quicksave path aborts before writing anything
- Scenario (L75): Dumping while the song plays does not shriek, and playback comes back
- Scenario (L84): Dumping during playback made the mixer scream
- Scenario (L108): Ctrl-Shift-Right cannot be a keymap row -- it is a live modifier test
- Scenario (L127): Names carry the sample name, not just the slot

## Relationships
