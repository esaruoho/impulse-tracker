# Session — sample-amplify-keeps-playback

> The thinkspace leg of the `sample-amplify-keeps-playback` report-card triad.
> Faithful, not flattering. The *how we got here* behind the grades in
> `sample-amplify-keeps-playback.feature`.

## Honest scope note (read first)

Written **alongside the build**, same session as the code — the dialogue below
is the actual spawning conversation, not a reconstruction.

## The request (verbatim intent)

Esa, "Impulse Tracker Feature Wantlist":

> Feature: When user normalizes a sample, pattern playback does not stop.
> Given that the User has a sample
> And they select to Normalize it
> And the playback is happening at the same time
> Then the Sample is Normalized
> And the playback does not stop.

Then, mid-investigation, the correction that unlocked it:

> "its not called Normalize its called Sample Amplification"

## The investigation (and a wrong turn)

First grep was for "normali" — **one** hit in the whole source, and none in
IT.TXT. Momentary conclusion: "IT has no Normalize." That was the wrong frame.
Esa's correction ("Sample Amplification") pointed at `I_AmplifySample`
(IT_I.ASM:3896). Reading it explained the naming: the proc **peak-scans** the
sample for max deviation from the mean, then pre-fills the dialog with
`(8000h/MaxDev)*100` — the largest gain that won't clip. That default IS the
normalize value, which is why a user calls Amplify "Normalize".

The bug was one line. After the dialog is confirmed (`DX != 0`), the apply path
at IT_I.ASM:~3997 did:

```
Call    Music_Stop          ; <-- stops the ENTIRE song
...
; NewSample = OldSample*SampleAmplification/100, clipped   (in-place rewrite)
```

`Music_Stop` was there to stop the mixer reading the PCM while it gets rewritten
in place. Correct intent, blunt instrument: it kills all playback, not just the
voices touching this one sample.

## Why the fix is what it is

- **Swap `Music_Stop` for `Music_SilenceSampleVoices`.** This is the exact
  pattern the F3 loader-keyjazz fix already established (commit `a44c41b`):
  silence ONLY the slave voices whose `[SI+36h]` (1-based sample slot) matches
  the target, by setting `[SI]=200h` — the same voice-off sentinel the mixer
  itself writes at sample-end. Every other channel keeps sounding. The song
  doesn't stop.

- **AL already holds the slot, and AX survives.** At the call site, `Pop AX`
  had just restored the sample number (1..99, AH=0). `Music_SilenceSampleVoices`
  takes the slot in AL, and is wrapped `PushA..PopA`, so AX is intact for the
  `Music_GetSampleLocation` immediately after. That register-preservation is
  what makes it a true drop-in for `Music_Stop` here — no reload, no reshuffle.

- **Safe to rewrite PCM in place after silencing.** A voice marked `200h` is
  skipped by the mixer's `Test [SI],1` gate, so it reads no half-scaled data.
  A new note hitting the slot during the ~ms rewrite would allocate a fresh
  slave reading the in-progress buffer — a negligible, non-crashing artifact,
  the same accepted trade as the loader fix.

- **Added the `Extrn`.** `Music_SilenceSampleVoices` wasn't imported into
  IT_I.ASM; without `Extrn Music_SilenceSampleVoices:Far` the link fails. Added
  next to `Extrn Music_Stop`.

## What was rejected / not done

- **Touching the other ~16 `Music_Stop` sites in IT_I.ASM** (cut, resize,
  convert, …). Out of scope — the wantlist item is specifically Amplify. Those
  keep their stop-the-song behaviour.
- **A global "never stop on sample edit" flag.** Overreach; the surgical
  per-sample silence is the right granularity and already proven.

## Honest grades

- `@build-verified` is real: full DOSBox-X BUILDALL, IT_I.asm Error/Warning =
  None, IT.EXE links (the Extrn resolved).
- `@runtime-untested` is honest: I did **not** run IT.EXE, start a song, press
  Alt-M on a playing sample and confirm both that it amplifies AND that the song
  keeps going. That smoke test is owed. IT.EXE is built and runnable in DOSBox-X.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Session ID: `e86aa106-2936-452b-805c-e3418c03140c`
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`
- Session timestamp: 2026-06-03 ~13:49 EEST (run `date` to confirm)
- CWD for this session: /Users/esaruoho/work/impulse-tracker (repo root)

## Cross-links

- Spec leg: `features/sample-amplify-keeps-playback.feature`
- Sibling (same pattern, loader side): `features/loader-keyjazz-hang.feature`
- Feature commit: `e5e5c38`
