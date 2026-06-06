# SESSION — f4-f3-cursor-translate card

> Carded 2026-06-06, last of the 3 ⬜ uncarded features. Feature shipped earlier
> (9d626b0/672273b); innards confirmed from the commit diffs (IT_G.ASM
> Glbl_InstrumentToSample / Glbl_SampleToInstrument, the note-60 offset + scan-all
> fallback, the 16-bit Movzx replacement).

- Card:    features/f4-f3-cursor-translate.feature
- Innards: IT_G.ASM Glbl_InstrumentToSample, Glbl_SampleToInstrument
- Live session id: auto-registered in features/CONVEY-SESSIONS.generated.md (Convey lineage)

## Honest grade
`@build-verified` (in main; cards are docs). Behaviour `@runtime-untested @hw-untested`
— the translation result isn't pressed-and-watched by me.
