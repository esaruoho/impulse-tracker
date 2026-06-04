# Session — shift-f4-drumkit

> The thinkspace leg of the `shift-f4-drumkit` report-card triad.
> Faithful, not flattering.

## Honest scope note (read first)

Written **alongside the build**, same session as the code.

## The request (verbatim intent)

Esa:

> Feature: User is able to use Shift-F4 to turn a C-0 to B-9 space instrument to
> a complete "drumkit" of each of the samples. ... the first instrument "01"
> becomes a "Multitimbral Drumkit". And the Instrument is configured to respond
> to MIDI Channel 10. And c-0 gets the first sample (01) C#0 becomes the second
> sample.. up until B-9. And each note of the instrument triggers one sample.

I asked how this should coexist with the existing Shift-F4 (which already runs
the multitimbral 3-state cycle) and what pitch each pad should play. Esa rejected
the question and clarified:

> "in the process of shift-f4, we create both the 01-16 instruments, and the 00
> instrument is the drumkit that goes from every sample in the sampleslot system.
> it is automatic. it is not touched by other 3-state Shift-F4."

So: no key conflict. The drumkit is built AUTOMATICALLY in the same Create step as
the 01-16 multitimbral set, it maps every sample slot to a key, and the other two
states of the Shift-F4 cycle (expand-to-96, reset) must not disturb it.

## Why the implementation is what it is

- **Build it in `Music_CreateMIDIInInstruments` (the Create step).** That's the
  one Shift-F4 state that "creates"; expand/reset only re-tile or clear. One
  `Call MCMI_BuildDrumkit` at `MCMI_Done`, after the 1-16 loop. Automatic, no UI.

- **Slot 99, not "00"/"01".** IT instruments are 1-99 (no 0), and 01-16 are the
  multitimbral set. The hard constraint from Esa's "not touched by the cycle":
  expand fills 1-96, reset clears 17-96 -- so the drumkit must live OUTSIDE 1-96.
  Slot 99 is the safe, last slot that both states skip. (Esa's "00" is the
  drumkit's conceptual identity; the real slot is 99 so it survives the cycle.)

- **Reuse the MCMI machinery.** `MCMI_BuildDrumkit` mirrors `MCMI_BuildSlot`:
  `Music_ClearInstrument 99`, header pointer via `[ES:DI+64712]`, MIDI channel at
  `[DI+1Fh]=10`, name at `[DI+20h]`, note table at `[DI+40h]` (entry = note byte
  + sample byte). The only difference is the per-note sample (i+1, not a constant)
  and the fixed note byte.

- **Note i -> sample (i+1); fixed pitch C-5.** Each of the 99 sample slots maps to
  a successive key (C-0=01 .. the 99th). Note-to-play = 60 (C-5) for every entry,
  so a pad plays its sample at base rate -- a real drumkit, not a transposed/
  chromatic kit. (Esa rejected the pitch question; fixed pitch is the standard
  "drumkit" reading. Easy to switch to chromatic -- drop the note-byte write -- if
  he wants pitched pads.) Notes 99..119 -> sample 0 (silent), since only 99 samples.

## What was rejected / not done

- **Drumkit at slot 01.** Would collide with the multitimbral set (01 = MIDI ch 1).
- **A new Shift-F4 state / different key.** Esa was explicit: automatic, in the
  existing Create step, untouched by the cycle. No new gesture.

## Honest grades

- `@build-verified`: DOSBox-X BUILDALL, IT_MUSIC.asm Error/Warning = None, IT.EXE links.
- `@runtime-untested @hw-untested`: not yet run. Watch on test: drumkit appears at
  slot 99 named "MIDI Drumkit"; C-0..key-99 each fire a different sample at base
  pitch; MIDI ch 10 routes to it; expand/reset leave slot 99 intact.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/e86aa106-2936-452b-805c-e3418c03140c.jsonl
- Session ID: `e86aa106-2936-452b-805c-e3418c03140c`
- Resume: `claude --resume e86aa106-2936-452b-805c-e3418c03140c`
- Session timestamp: 2026-06-04 ~09:21 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work/impulse-tracker

## Cross-links

- Spec leg: `features/shift-f4-drumkit.feature`
- Rides with: `features/midi-in-multitimbral.feature`, `features/shift-f4-enters-instrument-mode.feature`
- Feature commit: `f94f63c`

## Relocation: slot 99 -> slot 01 (2026-06-04, Esa hardware feedback)

First cut built the drumkit at slot 99 (chosen so the 1-96 multitimbral cycle
couldn't clobber it). Esa ran Shift-F4 and reported: "it created 01-16
instruments, but no drumkit -- the drumkit is supposed to be the FIRST
instrument." Slot 99 was technically correct but invisible (buried below the
empty 18-98 gap; the user looked at the top of the list and saw no kit).

Fix (commit dee41bd): the drumkit is now instrument **01** (first, immediately
visible), and the 16 multitimbral parts shifted to **02-17** (channel/sample =
slot-1, via `Sub AX,2` in MCMI_BuildSlot). Expand fills 02-97, reset clears
18-97, so slot 01 is never touched by the cycle. Channel-10 note: the drumkit
(01) and the multitimbral ch-10 part (slot 11) both claim ch 10; MMR_FindInst
returns the first match (slot 01 = drumkit), which is GM-correct (ch 10 = drums).
Still `@runtime-untested` -- Esa's next run is the proof.
