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
- Scenario (L78): an out-of-range pattern number resolves to EmptyPattern, never a wild pointer
- Scenario (L87): empty order list, F6 playing, Ctrl-O — no longer reboots
- Scenario (L97): a single-pattern render stops after one pass instead of hanging
- Scenario (L107): the render terminator never leaks into normal playback
- Scenario (L114): all three gestures share the one hardened render path
- Scenario (L123): each render writes a back-and-forth debug line to CTRLOLOG.TXT
- Scenario (L133): the reboot leak SOURCE (Music_PlayPartSong) is documented, not yet hardened

## Relationships
