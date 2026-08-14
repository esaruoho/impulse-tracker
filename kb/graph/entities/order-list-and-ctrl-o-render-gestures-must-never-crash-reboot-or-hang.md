---
name: Order-list and Ctrl-O render gestures must never crash, reboot, or hang
slug: order-list-and-ctrl-o-render-gestures-must-never-crash-reboot-or-hang
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/ctrl-o-empty-orderlist-crash.feature.

## Claims
- Scenario (L87): an out-of-range pattern number resolves to EmptyPattern, never a wild pointer
- Scenario (L96): empty order list, F6 playing, Ctrl-O — no longer reboots
- Scenario (L106): a single-pattern render stops after one pass instead of hanging
- Scenario (L116): the render terminator never leaks into normal playback
- Scenario (L123): all three gestures share the one hardened render path
- Scenario (L132): each render writes a back-and-forth debug line to CTRLOLOG.TXT
- Scenario (L142): the reboot leak SOURCE (Music_PlayPartSong) is documented, not yet hardened

## Relationships
