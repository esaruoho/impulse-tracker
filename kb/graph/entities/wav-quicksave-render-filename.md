---
name: WAV Quicksave render filename
slug: wav-quicksave-render-filename
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/wav-render-quicksave.feature.

## Claims
- Scenario (L83): Shift-Right at the order-list right edge renders to Quicksave only
- Scenario (L95): Plain Right at the same edge renders AND auto-imports
- Scenario (L106): A single-pattern Quicksave render is named by wall-clock time
- Scenario (L118): The prefix is a static "LL" (Lackluster), not derived from the song
- Scenario (L129): The extension is a real .WAV, not the 3-digit pattern number
- Scenario (L140): The auto-import opens the exact file WAVDRV wrote
- Scenario (L154): Multi-WAV, full-song, and user-named renders keep <PFX><NNNN>
- Scenario (L166): Two renders in the same second overwrite

## Relationships
