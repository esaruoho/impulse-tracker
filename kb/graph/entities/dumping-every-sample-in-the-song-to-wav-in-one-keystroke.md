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
- Scenario (L37): Ctrl-Shift-Right writes every loaded sample
- Scenario (L46): 8-bit samples are converted, not dumped raw
- Scenario (L57): The song's own sample filenames are left alone
- Scenario (L66): A bad Quicksave path aborts before writing anything
- Scenario (L73): Why the Ctrl row sits before the Shift row in the keymap
- Scenario (L84): Names carry the sample name, not just the slot

## Relationships
