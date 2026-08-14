---
name: Getting facts back off the DOS PC
slug: getting-facts-back-off-the-dos-pc
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/debug-logging-channels.feature.

## Claims
- Scenario (L37): PATLOG.TXT -- one character per event, for tracing a state machine
- Scenario (L53): A worked example -- the right-shift tap
- Scenario (L64): CTRLOLOG.TXT -- structured named fields, for one-shot operations
- Scenario (L79): Probing the filesystem rather than the code
- Scenario (L91): Gotcha 1 -- the log lands in cwd, so cwd is part of the question
- Scenario (L101): Gotcha 2 -- log transitions, never polls
- Scenario (L110): Gotcha 3 -- main-loop context only, never the ISR
- Scenario (L119): Gotcha 4 -- a clean-looking value can still mean failure
- Scenario (L129): VRAM markers, for when there is no file to read

## Relationships
