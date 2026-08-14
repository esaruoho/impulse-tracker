---
name: Pattern length beyond 200 rows (256 / 512)
slug: pattern-length-beyond-200-rows-256-512
kind: feature
confidence: 0.6
updated: 2026-08-14
---

## Summary
Convey feature: features/pattern-length-beyond-200.feature.

## Claims
- Scenario (L47): The unpacked editor buffer is a single 64,000-byte segment = 200 rows exactly
- Scenario (L58): Row offsets are computed with 16-bit math that wraps past ~64KB
- Scenario (L66): Block and network ops pack the row index into a byte (cap 255)
- Scenario (L74): The on-disk .IT Rows field is a WORD, but the spec defines 32..200
- Scenario (L83): What it would actually take (NOT done — recorded for honesty)

## Relationships
