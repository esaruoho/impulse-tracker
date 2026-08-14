---
name: Alt-R replicate at cursor
slug: alt-r-replicate-at-cursor
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/alt-r-replicate.feature.

## Claims
- Scenario (L53): Alt-R and Shift-Alt-R are disambiguated by live shift state
- Scenario (L65): Cursor above row 0 tiles the rows-above-cursor chunk downward
- Scenario (L74): Cursor on row 0 tiles row 0 down the whole channel
- Scenario (L81): No-op at the pattern edges
- Scenario (L89): Shift-Alt-R replicates the whole PATTERN at cursor
- Scenario (L108): Both replicate ops are undoable and show a correct label in the undo list
- Scenario (L13): Alt-R and Shift-Alt-R are disambiguated by live shift state
- Scenario (L25): Cursor above row 0 tiles the rows-above-cursor chunk downward
- Scenario (L34): Cursor on row 0 tiles row 0 down the whole channel
- Scenario (L41): No-op at the pattern edges
- Scenario (L48): Shift-Alt-R replicates the whole PATTERN at cursor

## Relationships
