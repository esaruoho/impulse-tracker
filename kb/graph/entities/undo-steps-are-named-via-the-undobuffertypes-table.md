---
name: Undo steps are named via the UndoBufferTypes table
slug: undo-steps-are-named-via-the-undobuffertypes-table
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/undo-messaging.feature.

## Claims
- Scenario (L64): Each undo slot stores a TYPE number that indexes a string table
- Scenario (L73): Recording an undo step assigns its type
- Scenario (L81): The undo list draws each step's name from the table
- Scenario (L92): Adding a new named undo step (the four-step recipe)
- Scenario (L105): A type with no offset-table entry draws garbage (the trap)
- Scenario (L118): Worked example - Alt-R / Shift-Alt-R replicate labels

## Relationships
