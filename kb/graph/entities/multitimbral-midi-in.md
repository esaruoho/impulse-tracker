---
name: Multitimbral MIDI-In
slug: multitimbral-midi-in
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/midi-in-multitimbral.feature.

## Claims
- Scenario (L55): Output MIDI fields are independent of the input field
- Scenario (L65): Each instrument can claim an incoming MIDI channel
- Scenario (L76): First Shift-F4 maps current samples to MIDI-In 01-16
- Scenario (L91): Second Shift-F4 replicates 01-16 across six banks (96 instruments)
- Scenario (L104): Third Shift-F4 resets the six banks back to one 01-16 set
- Scenario (L116): An incoming note on channel N triggers the matching instrument
- Scenario (L129): Channel 1 note entry is unchanged when the router is off
- Scenario (L140): The router on/off switch lives on the Shift-F1 MIDI screen
- Scenario (L153): Polyphony per channel

## Relationships
