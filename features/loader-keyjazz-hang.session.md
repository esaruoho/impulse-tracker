# SESSION — loader-keyjazz-hang card

> Carded 2026-06-06 while clearing the last ⬜ uncarded backlog (Esa: "card the 3
> uncarded features"). The feature shipped earlier (a44c41b/ec91331/64fa1ce); this
> turns it into a triad card, read straight from the source.

- Card:    features/loader-keyjazz-hang.feature
- Innards: IT_MUSIC.ASM Music_SilenceSampleVoices; IT_K.ASM MIDISyncLoaderSuppress
           + MIDI_Set/ClearLoaderSuppress
- Live session id: auto-registered in features/CONVEY-SESSIONS.generated.md (Convey lineage)

## Honest grade
`@build-verified` (code is in main; the cards are docs, no rebuild). Behaviour
`@runtime-untested @hw-untested` — not pressed in DOSBox / on metal by me. The
pre-fork "Music_Stop kills the song" path is the `@stock` bug it fixed.
