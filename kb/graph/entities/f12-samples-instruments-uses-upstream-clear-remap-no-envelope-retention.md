---
name: F12 Samples->Instruments uses upstream clear+remap (no envelope retention)
slug: f12-samples-instruments-uses-upstream-clear-remap-no-envelope-retention
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/no-samples-to-instruments-envelope-retention.feature.

## Claims
- Scenario (L73): Initialise Instruments = YES does the upstream clear + remap
- Scenario (L84): The envelope-retention feature and its IMPI checker are gone
- Scenario (L93): Shift-Enter bulk-load can no longer feed the crash class
- Scenario (L105): The I_MapEnvelope MaxNode<=25 clamp stays as defensive insurance
- Scenario (L113): (guardrail) Do not re-introduce envelope retention without HW verify

## Relationships
