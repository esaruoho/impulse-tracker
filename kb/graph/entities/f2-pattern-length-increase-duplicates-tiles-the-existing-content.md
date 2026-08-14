---
name: F2 pattern-length increase duplicates (tiles) the existing content
slug: f2-pattern-length-increase-duplicates-tiles-the-existing-content
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/dist/f2-resize-tiles-pattern.gherkin.feature.

## Claims
- Scenario (L12): 64 -> 128 duplicates the 64 rows once
- Scenario (L23): 64 -> 192 duplicates the 64 rows twice
- Scenario (L31): Non-multiple lengths get a partial final copy ("until the end")
- Scenario (L39): Shrinking the pattern does not tile
- Scenario (L46): Scope is the F2 config path only
- Scenario (L55): The tiled buffer persists via the working-copy model
- Scenario (L61): 64 -> 128 duplicates the 64 rows once
- Scenario (L72): 64 -> 192 duplicates the 64 rows twice
- Scenario (L80): Non-multiple lengths get a partial final copy ("until the end")
- Scenario (L88): Shrinking the pattern does not tile
- Scenario (L95): Scope is the F2 config path only
- Scenario (L104): The tiled buffer persists via the working-copy model

## Relationships
