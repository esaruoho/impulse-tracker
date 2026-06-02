# Feature: Retain drawn envelopes when converting Samples → Instruments

**Status: IMPROVED, STILL DO NOT MERGE WITHOUT REAL-HARDWARE VERIFICATION.**
This PR re-introduces a feature that was scalpel-removed from `main` because it
crashed, then **rebuilds it on the correct signal** (see "BREAKTHROUGH" below).
`main` stays the stable IT2.15-equivalent (always clear+re-init); this branch is
the fixed feature, parked until verified on a real DOS PC (the original crash is
EMM386-#12 / real-hardware-specific and can't be reproduced under DOSBox-X).

## BREAKTHROUGH: the right signal is the `IMPI` magic, not template-diff

The bug was using the *wrong question*. The old code asked "do this instrument's
envelope bytes differ from the default template?" — which uninitialised
**garbage** passes trivially, so garbage got "preserved" and fed to
`I_MapEnvelope` → crash.

The right question is "**is this even a real instrument?**" — and IT already
answers it: every initialised instrument header starts with the 4-byte magic
**`"IMPI"`** at offset 0 (`InstrumentHeader` template, `IT_MUSIC.ASM:371`;
`Music_ClearInstrument` copies it; disk loads write it). Garbage slots
(sample-only loads, `Shift-Enter` bulk-load — neither touches the instrument
region) practically never spell `IMPI` (four exact bytes, ~1 in 4e9).

### Final policy: "always remap, keep envelopes" (chosen by the maintainer)

A new helper `Music_InstrumentIsReal` (AX = instrument#) returns ZF=1 iff the
header starts with `IMPI`. `F_SetControlInstrument`'s Initialise=YES loop now:

```
for each slot 0..98:
    if NOT IsReal(slot):            ; no IMPI -> garbage
        Music_ClearInstrument(slot) ; -> valid blank template (IMPI, 0-node env)
    ; slot is now guaranteed valid (IMPI + valid envelope section)
    if matching sample exists:
        copy sample name -> instrument name (offset 20h)
        fill 120-note keymap        (offset 41h) -> all notes play this sample
    ; the envelope section (130h+) is NEVER written here
```

Consequences:
- **Garbage can never reach the envelope renderer** — non-IMPI slots are cleared
  to a valid template before anything else. **Crash class eliminated at the signal.**
- **Drawn envelopes always survive** — the loop never touches bytes 130h+, on any
  slot, real or just-cleared.
- **Every instrument ends up mapped & playable** — name + keymap are (re)written
  for every slot with a matching sample, including ones that have a drawn
  envelope. (The earlier "skip slots that have envelopes" design left such a slot
  *silent* because its default keymap points every note at sample 0 — that bug is
  gone.)

Trade-off the maintainer accepted: a hand-crafted real instrument's custom name
and multi-sample keymap get overwritten with the simple auto-mapping. That is the
intent of "Initialise = YES"; a user who wants zero changes answers **No** (which,
on stable `main`, already flips to Instrument mode and keeps everything).

The `I_MapEnvelope` `MaxNode<=25` clamp on `main` remains as an independent
renderer-side backstop for any malformed-but-IMPI instrument loaded from disk.

### Why this is strictly safe
The renderer never sees a non-IMPI header, and the envelope section of any slot
is never mutated by this path. There is no longer a "drew on a magic-less slot"
failure mode to worry about (we don't gate on envelopes at all anymore) — the
only thing `IMPI` decides is whether to clear garbage first. **It never crashes.**

### What the verifier should still confirm on real hardware
The original crash is EMM386-#12 / real-hardware-specific (DOSBox-X can't
reproduce it). Confirm on a DOS PC: (1) the old repro (Shift-Enter bulk-load →
F12 Samples→Instruments → Initialise=YES) no longer crashes; (2) a genuinely
drawn envelope survives the flip AND the instrument is now mapped/playable; (3)
a normal song still converts as expected.

---

(Original diagnosis below, retained for context.)

## What the feature is supposed to do

In Impulse Tracker you can be in **Sample mode** or **Instrument mode** (F12 song
flag, bit 2 of `[SongData:2Ch]`). A user can open an instrument's envelope editor
(F4) and draw Volume / Pan / Pitch / Filter envelopes *while still in Sample
mode*. Those envelopes don't sound in Sample mode, but the data is written into
the instrument header. People pre-draw envelopes this way, then flip
Samples → Instruments to start using them.

When you flip to Instrument mode via F12, IT asks **"Initialise Instruments?"**.
Answering **YES** runs `F_SetControlInstrument` (`IT_F.ASM`), whose **upstream
IT2.15 behaviour** is: `Music_ClearAllInstruments` (wipe every instrument header
to the default template), then walk slots 0..99 copying the matching sample's
name and filling the 120-note keymap.

**The desired feature:** make "Initialise Instruments = YES" set up the
sample→instrument mappings on *blank* instruments **without wiping envelopes the
user already drew**.

## Why it was removed (the crash, in detail)

The attempt (`d8ec842`, then patched by `4e4eb9a` / `ed10913` / `3d2412b`)
replaced the unconditional clear with a **per-slot test**,
`Music_InstrumentHasEnvelopes` (`IT_MUSIC.ASM`): for each slot it compared the
live instrument's envelope bytes (`130h..554`, the Vol/Pan/Pitch envelope structs
+ padding) against the default `InstrumentHeader` template. If they differed, the
slot was assumed to hold user-drawn data and was **preserved** (skip clear, skip
re-init). If they matched, the slot was cleared + re-init'd as before.

The fatal flaw: **a slot whose envelope differs from the template is not
necessarily user-drawn — it is very often uninitialised garbage.** Instrument
slots are full of leftover bytes after:
- loading a song in Sample mode (instruments never touched),
- `Shift-Enter` bulk-load of a module's samples (touches samples, not instruments).

The test saw garbage ≠ template, called it "user data", and **preserved the
garbage instead of clearing it**. The instrument-mode renderer `I_MapEnvelope`
(`IT_I.ASM`) then read a **garbage envelope node count** and ran an unbounded
node-draw loop → wild write → **EMM386 exception #12 / hard crash** on real
hardware.

A *second*, independent crash came from the dialog: a focus-index value of `6`
(then `4`) into `O1_InitialiseInstrumentList` pointed past the list terminator
into adjacent bytes → garbage object pointer → wild `Call` the instant the prompt
opened. (See `3d2412b`.)

### Partial mitigations that were tried (still insufficient)

- `ed10913`: clamp `I_MapEnvelope` `MaxNode ≤ 25` and have
  `Music_InstrumentHasEnvelopes` reject slots whose node count at
  `+131h/+183h/+1D5h` exceeds 25 (treat as "default" → clear). **This clamp is
  good and was KEPT on `main`** — it is pure defensive insurance for the renderer
  regardless of this feature. But it does not solve the core ambiguity: a garbage
  header with node counts that *happen* to be ≤ 25 still gets "preserved".
- `4e4eb9a` / `3d2412b`: dialog focus-index fixes. Fixing symptoms, not cause.

## The real problem to solve

**There is no reliable way, from the header bytes alone, to distinguish
"user deliberately drew an envelope on this slot" from "this slot is
uninitialised garbage that happens not to match the template".** Template-diff is
the wrong signal. A correct implementation needs a *positive, trustworthy* signal
that a slot holds intentional instrument data.

### Suggested directions for a correct fix (for the better agent)

1. **Explicit "instrument touched" flag.** Track, per instrument slot, whether the
   user has actually initialised/edited it (e.g. set a bit when the envelope
   editor writes to that slot, or when the instrument is loaded from disk as an
   instrument). Only preserve slots with that bit set. Garbage slots never set it.
2. **Full structural validation before preserve.** Don't just check node count ≤
   25 on three offsets — validate the *entire* envelope struct (node count,
   per-node tick ordering monotonic, loop/sustain points in range, flags sane). A
   slot that fails any check is garbage → clear it. Only a fully-valid envelope is
   preserved. This is more defensive than (1) but still heuristic.
3. **Scope the feature narrowly.** Only preserve envelopes on slots whose matching
   *sample* exists AND whose instrument header is otherwise default except the
   envelope section — i.e. the exact "I drew an envelope on an otherwise-blank
   instrument in Sample mode" case the feature targets. Anything else → clear.
4. **Make it opt-in / undoable.** Consider a third dialog choice ("Initialise but
   keep envelopes") so the destructive default stays the safe, well-understood
   IT2.15 path and envelope-preservation is an explicit, separate action.

Whatever the approach: **the envelope renderer (`I_MapEnvelope`) must never be
handed an unvalidated node count.** The `MaxNode ≤ 25` clamp on `main` is a
backstop, not a license to feed it garbage.

## What this branch contains

Re-applied on top of stable `main`:
- `IT_F.ASM` `F_SetControlInstrument`: the per-slot
  `Music_InstrumentHasEnvelopes` / `Music_ClearInstrument` preservation loop
  (dialog focus index `4` = "No"), plus the `Extrn`s.
- `IT_MUSIC.ASM`: the `Music_InstrumentHasEnvelopes` helper (with the
  garbage-rejection guard) + its `Global` decl.

Deliberately **NOT** reverted (kept from stable `main`):
- `IT_G.ASM` `Glbl_Shift_F4` Instrument-mode gate — unrelated good stability fix.
- `IT_I.ASM` `I_MapEnvelope` `MaxNode ≤ 25` clamp — keep as backstop.

## Reference commits

| Commit | Role |
|--------|------|
| `d8ec842` | introduced per-slot envelope preservation (the feature) |
| `4e4eb9a` | dialog default-focus "No" (symptom patch) |
| `ed10913` | `MaxNode ≤ 25` clamp + garbage-reject (mitigation, partly kept) |
| `3d2412b` | dialog focus-index `6→4` wild-call fix (symptom patch) |
| `b5a0c66` | **the scalpel** — removed the feature from `main` (this branch reverts the IT_F/IT_MUSIC parts of it) |

## How to verify a future fix

Repro the crash first (to confirm you can see it): build, then in DOSBox-X / on a
DOS PC, `Shift-Enter` bulk-load a module's samples (so instrument slots hold
garbage), then F12 → Samples→Instruments → Initialise = YES. The pre-fix feature
crashes (EMM386 #12). A correct fix must: (a) not crash on garbage slots, (b)
actually preserve a genuinely user-drawn envelope across the flip, (c) still clear
truly-blank instruments. All three, verified on real hardware (the crash is
environment-sensitive — see CLAUDE.md on DOSBox-X vs real-hardware repro).
