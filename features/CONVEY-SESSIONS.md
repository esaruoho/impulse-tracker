# Convey — Sessions Ledger

> Every Claude session that worked on **Convey** registers here, so multiple parallel
> conversations can be **distilled into one situation** (`features/CONVEY-SITUATION.md`).
> This is the "which conversations" index; the situation doc is the merged knowledge.
>
> **Honesty:** a session is fully distilled only if its own dialogue was read. For the
> rest, the contribution is **inferred from git** (commits landed in the shared working
> tree), and full distillation = `claude --resume <id>` then read. The repo itself
> (cards + `STATUS.md` + git log) is the authoritative merged record; sessions are how
> it got there.
>
> Get-back block per session: transcript `file://` + resume command.

| Session  | Span (UTC)                   | Lines | Distilled? | Role |
|----------|------------------------------|------:|:----------:|------|
| 8fdac3f9 | 2026-06-03 06:12 → 06-04 06:44 | 1558 | ✓ full     | **Convey genesis.** WAV LL-render → report card → triad → seed → vibe-diff → self-maintaining hooks → @hw floor → auto-generated STATUS → named "Convey". This ledger + situation. |
| e86aa106 | 2026-06-03 09:23 → 06-04 06:44 | 1770 | ✗ registered | The **parallel builder** in the same working tree. Git-evidenced: F-key cards (f2/f3/f4/f11/f12), midi-realtime-sync card, scrolllock feature (91dfc0b), shift-enter/.MOD fix, multitimbral + play-dots, F6-from-order, sample-amplify, samples→instruments removal, day card, RUNNER. |
| 227bcb50 | 2026-06-03 07:29 → 06-04 04:44 | 1180 | ✗ registered | Convey-related (mentions convey); contributions interleave with the above in git. Resume to distill. |
| 1fa213d0 | 2026-06-03 06:07 → 10:41        |  767 | ✗ registered | **Report-card genesis** (the `originSessionId` in the report-card memory) — where the report-card pattern that became Convey was first established. Pre-dates the "Convey" name. |

## Get-back blocks

### 8fdac3f9 — Convey genesis (this session)
- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894.jsonl
- Resume: `claude --resume 8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894`

### e86aa106 — parallel builder
- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`

### 227bcb50
- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/227bcb50-c2eb-4f4e-8c73-116ad86c5e2f.jsonl
- Resume: `claude --resume 227bcb50-c2eb-4f4e-8c73-116ad86c5e2f`

### 1fa213d0 — report-card genesis
- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/1fa213d0-83aa-4fc1-a8fb-b38dbcdee53d.jsonl
- Resume: `claude --resume 1fa213d0-83aa-4fc1-a8fb-b38dbcdee53d`

## How to distill (the operation)

To fold a new Convey conversation into the single situation:
1. Add a row above (id, span via the transcript timestamps, role) + a get-back block.
2. Resume/read it if its dialogue holds decisions not already in the repo.
3. Update `features/CONVEY-SITUATION.md` with anything that lives in NO card (cross-
   session decisions, open threads) — the per-feature facts already live in their cards
   and in the generated `STATUS.md`, so don't re-type those.
