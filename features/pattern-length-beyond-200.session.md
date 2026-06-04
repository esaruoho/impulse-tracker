# Session — feasibility: 256/512-row patterns? (2026-06-04)

Vibe-diff record for `pattern-length-beyond-200.feature`. A feasibility/negative
result, faithful (not flattering).

## The question (Esa)

> is 256 row or 512 row pattern possible in this format, please?

Then, reframed as a feature:

> Feature: 512 Row Pattern. Given that the current Pattern Length can be 32 to 200,
> When the User sets 256 Row pattern or 512 row pattern, Then the architecture
> creates such and it works.

## The verdict — NO (for this engine), with one nuance for the file format

The 200-row limit is **architectural, not arbitrary**. Decisive fact, read
firsthand:

    IT_PE.ASM:14687  Segment PatternData PARA Public 'Data'
    IT_PE.ASM:14688          DB 64000 Dup (?)

The pattern editor decodes a pattern into PatternData at **320 bytes/row** (64
channels x 5 bytes). 200 * 320 = **64,000** = the segment size, to the byte. That
is why the limit is 200: it's the most that fits in one 64KB real-mode segment.

- 256 rows = 81,920 bytes  -> over 64KB, impossible in this buffer.
- 512 rows = 163,840 bytes -> 2.5x over.
- 201 rows already = 64,320 bytes (over); ~204 is the true hard ceiling, and 200 is
  the clean round clamp under it.

Three independent confirmations the ceiling is real:
1. The 64,000-byte segment (above).
2. Row offsets use 16-bit math that discards the high word (IT_PE.ASM:8457-8461,
   `Mov AX,320 / Mul DX / ... Mov SI,AX`) — offsets >65,535 wrap and corrupt.
3. Block/network ops pack the row into a byte (NetworkPatternBlock BH=Row,
   CH=Height; IT_PE.ASM:4523, :6456) — caps at 255 regardless of #1.

The nuance: the **on-disk** .IT Rows field is a 16-bit WORD (DecodePattern LodsW
at :9905, EncodePattern StosW at :10074), so the number 256/512 is representable in
a file. But ITTECH.TXT:369 defines the valid range as 32..200, so such a file is
non-conformant and classic IT / Schism won't read it reliably. The FILE isn't the
blocker — the EDITOR's 64KB buffer + 16-bit addressing is.

## What I did NOT do

I did not implement it, and I did not bump the clamp to fake it — that would
silently corrupt patterns past row 204 (completion-framing-is-lying). The honest
answer is "no, not without a major rewrite."

## What it would actually take (if ever pursued)

- Move the unpacked buffer past 64KB: 386 32-bit offset addressing / "unreal mode"
  big segment, OR an EMS-paged multi-segment buffer.
- Convert every PatternData access (dozens of sites) to the new addressing.
- Widen the byte Row/Height fields in NetworkPatternBlock to words.
- Accept that the output is no longer a spec-conformant .IT.
Multi-day rewrite with compatibility breakage, not a clamp change.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/6ddcab86-2462-4295-9717-0b3f0e837425.jsonl
- Session ID: `6ddcab86-2462-4295-9717-0b3f0e837425` (identified by content)
- Resume: `claude --resume 6ddcab86-2462-4295-9717-0b3f0e837425`
- Session timestamp: 2026-06-04 ~12:20 EEST (verified via `date`)
- CWD: /Users/esaruoho/work/impulse-tracker
