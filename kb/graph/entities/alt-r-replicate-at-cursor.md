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
- Scenario (L55): Ctrl-Down and Ctrl-Shift-Down do the same thing as Alt-R
- Scenario (L77): What Ctrl-Down displaced, and why that is free
- Scenario (L87): Alt-R and Shift-Alt-R are disambiguated by live shift state
- Scenario (L99): Cursor above row 0 tiles the rows-above-cursor chunk downward
- Scenario (L108): Cursor on row 0 tiles row 0 down the whole channel
- Scenario (L115): No-op at the pattern edges
- Scenario (L123): Shift-Alt-R replicates the whole PATTERN at cursor
- Scenario (L142): Both replicate ops are undoable and show a correct label in the undo list
- Scenario (L13): Alt-R and Shift-Alt-R are disambiguated by live shift state
- Scenario (L25): Cursor above row 0 tiles the rows-above-cursor chunk downward
- Scenario (L34): Cursor on row 0 tiles row 0 down the whole channel
- Scenario (L41): No-op at the pattern edges
- Scenario (L48): Shift-Alt-R replicates the whole PATTERN at cursor

## Relationships
