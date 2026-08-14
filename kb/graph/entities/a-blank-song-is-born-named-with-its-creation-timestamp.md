---
name: A blank song is born named with its creation timestamp
slug: a-blank-song-is-born-named-with-its-creation-timestamp
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/song-name-timestamp-default.feature.

## Claims
- Scenario (L64): The boot default song is named with the startup timestamp
- Scenario (L75): The format is fixed-width 16 chars, zero-padded, no seconds
- Scenario (L84): Making a fresh song re-stamps the name with the new time
- Scenario (L92): A name that already has content is never clobbered
- Scenario (L100): The stamped name is an ordinary editable name, not a locked field

## Relationships
