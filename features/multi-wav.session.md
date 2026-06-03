# SESSION / VIBE RECORD: Multi-WAV

> Carded this session while clearing the INDEX's uncarded backlog. The feature
> shipped earlier (commit 9fb5ac1); the conversation here is the carding +
> grading decision, and one explicit instruction shaped it.
>
> - Card:    features/multi-wav.feature
> - Innards: IT_PE.ASM PEFunction_StartMultiWAVKey / PE_ChannelIsEmpty;
>            IT_MUSIC.ASM Music_StartMultiWAV / StartFullSongWAV / StartFullSongMWAV;
>            IT_K.ASM K_TranslateCondition11
> - Commits: 9fb5ac1 (feature) ; card-commit follows in git log
> - Date:    2026-06-03
> - Agent:   Claude Code (Opus 4.8, 1M context)

## How to get back (the seed is clickable)

- **Transcript:** file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894.jsonl
- **Session ID:** `8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894`
- **Resume:** `claude --resume 8fdac3f9-0da3-4d36-a1e1-7e0d3ed99894`
- **Window:** 2026-06-03 (UTC).

## The instruction that shaped the grade

Esa, 2026-06-03: *"multi-wav is not tested so it should say it. gherkin should
state that this one is not tested."*

So the card does not pretend. It carries a `!!! TESTING STATUS — READ FIRST !!!`
banner in the header, every behaviour scenario is `@runtime-untested`, and there
is an explicit final scenario — "WHAT WOULD VERIFY THIS CARD" — naming the exact
DOSBox-X run that would let the grades be raised. The only `@build-verified`
(non-runtime) claim is the structural one: that `K_TranslateCondition11` supplies
the Shift+Alt keymap path, which is a fact about assembly, not about rendered
audio.

## Honest grade

`@shipped @build-verified @runtime-untested`. The render machinery is in main and
assembles; whether the per-channel / whole-song WAVs are actually written
correctly has NOT been observed. Not lying about it is the whole point.
