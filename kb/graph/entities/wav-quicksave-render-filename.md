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
- Scenario (L85): Shift-Right at the order-list right edge renders to Quicksave only
- Scenario (L97): Plain Right at the same edge renders AND auto-imports
- Scenario (L108): A single-pattern Quicksave render is named by wall-clock time
- Scenario (L120): The prefix is a static "LL" (Lackluster), not derived from the song
- Scenario (L131): The extension is a real .WAV, not the 3-digit pattern number
- Scenario (L142): The auto-import opens the exact file WAVDRV wrote
- Scenario (L156): Multi-WAV, full-song, and user-named renders keep <PFX><NNNN>
- Scenario (L168): The render plays the pattern's actual number of rows
- Scenario (L178): BX was never set, so renders intermittently wrote NO FILE AT ALL
- Scenario (L206): Two renders in the same second overwrite

## Relationships
