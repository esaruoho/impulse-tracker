# Session — multitimbral-instrument-play-dots

> The thinkspace leg of the `multitimbral-instrument-play-dots` report-card
> triad. Faithful, not flattering. The *how we got here* behind the grades in
> `multitimbral-instrument-play-dots.feature`.

## Honest scope note (read first)

Written **alongside the build**, same session as the code.

## The request (verbatim intent)

Esa, from the feature wantlist:

> "when midi triggers the instrument list entries.. there is no 'dot'
> triggering.. the dot triggers when keyboard is pressed."
>
> Feature: When in Multitimbrality mode, the "play notification dots" display in
> Instrument List F4 / Given that the User has samples / And has turned the
> format Multitimbrality on by pressing shift-f4 / Then when the channels play /
> Then the dots for playback, much like with sample use, are shown.

And the decisive clarification after I asked Instrument vs Sample mode:

> "the instruments mode was not open ... in F3 Sample mode only in Samples mode,
> the multitimbrality works. so it doesn't feel like it triggers in Instrument
> List."

## The investigation (what I ruled out first)

The two play-dot drawers are `I_ShowSamplePlay` (8488) and `I_ShowInstrumentPlay`
(8543), both dispatched from `IT_L.ASM` `UpdatePointers` by screen (AH=3 → sample
list, AH=4 → instrument list). They scan the SAME slave-channel table; they differ
in only two ways:

1. `I_ShowInstrumentPlay` opens with `Music_GetInstrumentMode / JZ end` — a gate
   the sample drawer does not have.
2. Sample dots key on slave `[SI+36h]` (sample slot); instrument dots key on
   `[SI+33h]` (instrument = high byte of the `Nte&Ins` word at `[SI+32h]`).

I first chased the slave fields, suspecting the router left `[SI+33h]` unset. But
`MIDIMulti_Route` plays through `Music_PlayNote` **with** the matched instrument
(`MMR_Inst`, 1..99), and the slave allocator (`AllocateChannel`, ~IT_MUSIC.ASM
1591) copies host `[DI+3..4]` straight into `[SI+32h]` — so `[SI+33h]` *is* the
instrument, identical to the keyboard path. The fields were a red herring.

A wrong turn worth recording: I almost asked the mode question and then accepted a
first answer ("instrument mode will need to be on for multitimbrality") at face
value — which would have sent me digging in the wrong place. Esa corrected it:
instrument mode was actually OFF; multitimbral runs in Sample mode. That correction
is the whole fix.

## Why the fix is what it is

- **The gate, not the fields.** In Sample mode `Music_GetInstrumentMode` returns 0,
  so `I_ShowInstrumentPlay` returns before drawing anything — no dots — while the
  ungated `I_ShowSamplePlay` keeps showing them. Exactly the reported asymmetry.

- **Relax the gate only when the router is on.** New branch: if instrument mode is
  off, consult `Music_GetMIDIMultiEnable`; proceed if set, else keep the original
  bail. So Instrument mode is untouched, normal Sample mode (router off) is
  untouched, and only multitimbral-in-Sample-mode gains the dots. Minimal blast
  radius.

- **No new import, register-safe.** `Music_GetMIDIMultiEnable` is already Extrn'd
  in IT_I.ASM (the router uses it) and clobbers only AL, called at proc entry
  before anything is live.

## What was rejected / not done

- **Removing the gate outright.** Would draw instrument dots in plain Sample mode
  with no router — behaviour change nobody asked for. Scoped to the router flag
  instead.
- **Touching the slave scan or `[SI+33h]`.** The fields were already correct; the
  body needs no change.

## Honest grades

- `@build-verified` is real: DOSBox-X BUILDALL, IT_I.asm Error/Warning = None,
  IT.EXE links.
- `@runtime-untested` is honest: not yet confirmed by running IT.EXE, enabling
  multitimbral in Sample mode, and watching the F4 dots light on the routed
  instrument rows. IT.EXE is relaunched and ready; that check is owed. There is a
  specific thing to watch: confirm the dot lands on the *routed instrument's* row
  and not a sample-number-offset row (Sample-mode instrument≈sample numbering).

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Session ID: `e86aa106-2936-452b-805c-e3418c03140c`
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`
- Session timestamp: 2026-06-03 ~14:30 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work/impulse-tracker (repo root)

## Cross-links

- Spec leg: `features/multitimbral-instrument-play-dots.feature`
- The router: `features/midi-in-multitimbral.feature`
- Feature commit: `478b638`
