# SESSION / VIBE RECORD: Alt-R = Replicate at Cursor

> The card was authored in this session while working down the INDEX's uncarded
> backlog. The feature itself shipped earlier (commits d506486, aaada5e); this
> session turned it into a triad card, so the "spawning conversation" here is the
> carding decision, not the original feature build.
>
> - Card:    features/alt-r-replicate.feature
> - Innards: IT_PE.ASM PEFunction_AltR_Dispatch / ReplicateAtCursor / ClearViews
> - Commits: d506486, aaada5e (feature) ; card-commit follows in git log
> - Date:    2026-06-03
> - Agent:   Claude Code (Opus 4.8, 1M context)

## How to get back (the seed is clickable)

- **Transcript:** file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894.jsonl
- **Session ID:** `8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894`
- **Resume:** `claude --resume 8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894`
- **Window:** 2026-06-03 (UTC). A parallel session was carding other features in
  the same working tree; this card was created without touching its files.

## Why carded now

Esa asked to work down the uncarded list: "the alt-r-replicate can be done." The
feature was already shipped and is read straight from the source (Paketti port,
mirrors ztrackerprime `CUI_Patterneditor.cpp:2581`), so the card cites the actual
dispatcher + replicate procs rather than re-deriving behaviour.

## Honest grade

Dispatcher + edge-guard scenarios are `@build-verified` (the code is in main and
main assembles). The actual tiling result (rows-above-cursor stamped downward) is
`@runtime-untested` — not yet confirmed by running IT.EXE in DOSBox-X and pressing
Alt-R on a real pattern. The grade says so rather than implying it was checked.

---

# Session — undo labels for Alt-R / Shift-Alt-R (2026-06-04)

## The question (Esa)

> one really important thing about shift-alt-R is that it should create an undo
> step so [I] can undo it with alt-Z, right?

## What I found (premise corrected on two counts)

1. **It already creates an undo step.** PEFunction_ReplicatePatternAtCursor (Shift-Alt-R)
   calls PE_AddToUndoBuffer at IT_PE.ASM:8503; PEFunction_ReplicateAtCursor (Alt-R) at
   :8405. The pattern data was always recoverable.
2. **The undo key is Ctrl-Backspace, not Alt-Z.** IT.TXT:1054 = 10-stage listed Undo.
   IT.TXT:1152 = Alt-Z is "Cut current block". Pressing Alt-Z after a replicate would
   cut a block, not undo.
3. **Real defect: garbage undo-list label.** Both ops used undo tag 23, but the
   UndoBufferTypes offset table only had entries 0..22 (IT_PE.ASM:371-383).
   PEFunction_DrawUndo (~13845) reads the tag's low byte and indexes that table, so
   tag 23 read past the end -> S_DrawString followed a bogus pointer and drew junk for
   the replicate step in the Ctrl-Backspace list. Undo still functioned; only the label
   was wrong.

## The fix (3a3b7ff)

- UndoBufferType23 = "Undo replicate track (Alt-R)", UndoBufferType24 = "Undo replicate
  pattern (Sh-Alt-R)".
- Extend UndoBufferTypes with both offsets.
- Move Shift-Alt-R from tag 23 to tag 24 so the two ops show distinct, correct labels.
- Alt-R keeps tag 23. No change to undo behaviour itself.
- Verified: tag 24 != 22, so the PE_AddToUndoBuffer "don't-mark-modified" special-case
  (Cmp AL,22) is unaffected; replicate still marks the pattern modified.

## Honest grade

`@build-verified` + `@runtime-untested`. dosbox-x build 2026-06-04 11:51 EEST,
IT_PE.asm Error/Warning None, IT.EXE 477096 bytes. NOT yet run live -- needs a
DOSBox-X test: replicate, Ctrl-Backspace, confirm the label reads "Undo replicate
track/pattern" and the revert restores the pre-replicate data.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/6ddcab86-2462-4295-9717-0b3f0e837425.jsonl
- Session ID: `6ddcab86-2462-4295-9717-0b3f0e837425`
  (same session as the Shift-Enter exit-to-directory fix; identified by content)
- Resume: `claude --resume 6ddcab86-2462-4295-9717-0b3f0e837425`
- Session timestamp: 2026-06-04 ~11:51 EEST (verified via `date`)
- CWD: /Users/esaruoho/work/impulse-tracker
