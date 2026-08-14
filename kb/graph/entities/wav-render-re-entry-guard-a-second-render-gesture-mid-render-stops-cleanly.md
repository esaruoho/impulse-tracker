---
name: WAV render re-entry guard -- a second render gesture mid-render stops cleanly
slug: wav-render-re-entry-guard-a-second-render-gesture-mid-render-stops-cleanly
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/dist/wav-render-reentry-guard.gherkin.feature.

## Claims
- Scenario (L17): The old behaviour -- a second gesture tore the driver down mid-playback
- Scenario (L33): Right starts the render, Shift-Right during it halts and finalizes
- Scenario (L50): WAV_FinalizeRequest tells the genuine finalize apart from a re-press
- Scenario (L62): The genuine auto-finalize is unchanged -- still leaves + imports
- Scenario (L73): Early-stop reuses the existing safe finalize, not a new teardown
- Scenario (L87): All render entry points share the one central guard
- Scenario (L96): Multi-WAV sweep finalize and chaining are untouched
- Scenario (L82): The old behaviour -- a second gesture tore the driver down mid-playback
- Scenario (L98): Right starts the render, Shift-Right during it halts and finalizes
- Scenario (L115): WAV_FinalizeRequest tells the genuine finalize apart from a re-press
- Scenario (L127): The genuine auto-finalize is unchanged -- still leaves + imports
- Scenario (L138): Early-stop reuses the existing safe finalize, not a new teardown
- Scenario (L152): All render entry points share the one central guard
- Scenario (L161): Multi-WAV sweep finalize and chaining are untouched

## Relationships
