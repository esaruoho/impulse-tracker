# SESSION / VIBE RECORD: 2-day feature digest (2026-06-03 → 04)

> The conversation that spawned `features/recent-features-2026-06-03_to_04.feature`.
> This digest rolls up two days of fork work into one graded, linked index; the
> per-feature cards hold the real detail and their own sessions.
>
> - Card:    features/recent-features-2026-06-03_to_04.feature
> - Detail:  the per-feature cards it links (scrolllock-follow-from-lists,
>            wav-render-quicksave, wav-render-reentry-guard, multi-wav,
>            shift-enter-*, midi-in-multitimbral, shift-f4-enters-instrument-mode,
>            multitimbral-instrument-play-dots, f2-resize-tiles-pattern,
>            sample-amplify-keeps-playback, no-samples-to-instruments-envelope-retention)
> - Span:    2026-06-03 (the build push) → 2026-06-04 (carding + this digest)
> - Agent:   Claude Code (Opus 4.8, 1M context)

## How to get back (the seed is clickable)

- **Transcript:** file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894.jsonl
- **Session ID:** `8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894`
  (confirmed live by transcript mtime matching wall-clock at capture, ~07:00 EEST 2026-06-04)
- **Resume:** `claude --resume 8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894`
- **Honest caveat:** the two days spanned more than this one transcript (a parallel
  session committed into the same working tree throughout — multitimbral, scrolllock,
  runner, day-card work). This digest reflects origin/main as a whole, not just
  this session's commits.

## The two days in one breath

Started as a tiny ask — rename WAV renders so they drag out (`.000`→`.WAV`→
`LL<HHMMSS>.WAV`) — and snowballed into: the WAV re-entry guard, Multi-WAV carding,
Scroll-Lock-and-Ctrl-F follow-to-editor (which took two flag-byte bugs to get
working at runtime), Shift-Enter bulk-load + a .MOD hang fix, Shift-F4 multitimbral
cycle + instrument-mode entry, F4 play dots, F2 tile-on-resize, Sample-Amplify
keep-playback, and the deliberate REMOVAL of the crash-prone Samples→Instruments
envelope retention. Alongside the features, the whole **report-card system** was
stood up (triads + the self-maintaining pre-commit/post-merge hooks), which is why
several pre-existing features got their first card in this same window.

## The honesty thread (why the grades aren't all green)

- **Ctrl-F F3/F4 is `@runtime-verified`** — Esa pressed it on a live IT.EXE. Getting
  there cost two shipped-but-broken cuts (`DB 0` flag did nothing; per-screen copies
  collapsed to one GlobalKeyList entry). The `@runtime-untested` grade caught both.
- **Multi-WAV is loudly `@runtime-untested`** — its card carries a READ-FIRST banner;
  the render machinery ships but the on-disk result is unconfirmed.
- **Most everything else is `@build-verified @runtime-untested`** — assembles clean,
  not yet key-pressed. The digest says so rather than implying it was checked.
- **One `@removal`** — the envelope-retention feature is gone on purpose; the card is
  an honest tombstone, not a working-feature claim.
