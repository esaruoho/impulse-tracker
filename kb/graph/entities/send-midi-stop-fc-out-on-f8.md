---
name: Send MIDI Stop (FC) out on F8
slug: send-midi-stop-fc-out-on-f8
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/midi-out-stop-on-f8.feature.

## Claims
- Scenario (L63): F8 transmits exactly one MIDI Stop byte out
- Scenario (L74): The Stop byte does not disturb MIDI running status
- Scenario (L83): With no MIDI-capable driver the transmit is a clean no-op
- Scenario (L93): A MIDI-thru loopback cannot create a transport storm
- Scenario (L106): The toggle defaults ON and is flipped on the Shift-F1 MIDI screen
- Scenario (L115): With the toggle OFF, F8 behaves exactly like stock
- Scenario (L125): The toggle survives an Impulse Tracker restart (no separate save step)
- Scenario (L139): Old IT.CFG files (and fresh installs) default the toggle ON

## Relationships
