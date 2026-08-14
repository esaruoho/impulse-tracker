---
name: A Convey conversation self-archives when it ends
slug: a-convey-conversation-self-archives-when-it-ends
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/convey-session-distiller.feature.

## Claims
- Scenario (L41): The distiller turns a SessionEnd payload into a per-session stub (fast)
- Scenario (L53): The SessionEnd HOOK fires the distiller when a real Convey session ends
- Scenario (L74): Defensive, metadata-only, never touches git
- Scenario (L84): The stub is metadata, not a full vibe-diff
- Scenario (L93): Machine-local and approval-gated
- Scenario (L100): Claude Code edge cases the distiller cannot fix

## Relationships
