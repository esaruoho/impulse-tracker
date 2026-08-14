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
- Scenario (L58): Output MIDI fields are independent of the input field
- Scenario (L68): Each instrument can claim an incoming MIDI channel
- Scenario (L79): First Shift-F4 maps current samples to MIDI-In 01-16
- Scenario (L94): Second Shift-F4 replicates 01-16 across six banks (96 instruments)
- Scenario (L107): Third Shift-F4 resets the six banks back to one 01-16 set
- Scenario (L119): An incoming note on channel N triggers the matching instrument
- Scenario (L132): Channel 1 note entry is unchanged when the router is off
- Scenario (L143): The router on/off switch lives on the Shift-F1 MIDI screen
- Scenario (L154): Enabling it from Sample mode offers to make the whole move
- Scenario (L167): Why "ON" in Sample mode was a lie worth removing
- Scenario (L182): Why the flag is set directly and not through F12
- Scenario (L193): Polyphony per channel

## Relationships
