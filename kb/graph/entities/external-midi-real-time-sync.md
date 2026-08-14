---
name: External MIDI Real-Time Sync
slug: external-midi-real-time-sync
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/midi-realtime-sync.feature.

## Claims
- Scenario (L55): Real-Time bytes are dispatched without disturbing running status
- Scenario (L66): 0xFA Start plays the song from the top
- Scenario (L75): 0xFC Stop halts playback
- Scenario (L83): 0xFB Continue currently behaves as Start (known v1 limitation)
- Scenario (L91): 0xFB Continue resumes from the last-known order/row
- Scenario (L100): 0xF8 Clock derives IT tempo from the master at 24 PPQ
- Scenario (L112): MIDI Transport can be switched off, swallowing FA/FB/FC
- Scenario (L121): MIDI Sync (clock) can be switched off independently, ignoring F8
- Scenario (L129): Loader keyjazz suppresses transport re-entry
- Scenario (L138): Sound drivers pass F8-FF through to MIDISend
- Scenario (L150): The MIDI Monitor shows live Real-Time byte counters

## Relationships
