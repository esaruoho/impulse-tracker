# MIDI-In Multitimbral — what's wired, why it's silent, what to change

Study + plan, 2026-06-03. No code changed. Verified against current `main`
(commits `10c837b`, `7e3620a`, `2dac7d5`, `b5a0c66`).

---

## 1. Output MIDI vs Input MIDI — the two are unrelated

Each instrument's 554-byte header carries **two completely separate** MIDI
feature sets. They do not talk to each other.

### Output side (stock Impulse Tracker, decades old)

| Header byte | Field on screen | What it does |
|---|---|---|
| `0x3C` | **MIDI Channel** | If set (1..16), IT becomes a **MIDI sender**: playing this instrument transmits note-on/off **out** the MPU-401 to an external synth on that channel. 0 = off (instrument plays its own sample internally instead). |
| `0x3D` | **MIDI Program** | Program Change (0..127) sent **out** before the first note, so the external synth selects a patch. -1 = don't send. |
| `0x3E/0x3F` | **MIDI Bank Low/High** | Bank Select CC#0/CC#32 sent **out** before the program change. -1 = don't send. |

Where it lives: `IT_MUSIC.ASM` `UpdateMIDI` (~7923–7980). On note start it
emits, in order: Bank Select → Program Change → Note-On, all via
`MIDITranslate`, all addressed to channel `[SI+3Ch]`. This is **IT-as-MIDI-
master**: it drives outboard gear. It has nothing to do with sound coming
*into* the DOS PC.

### Input side (your fork, byte `0x1F`)

| Header byte | Field on screen | What it does |
|---|---|---|
| `0x1F` | **MIDI In Channel** | Fork addition. 0 = off, 1..16 = listen on that channel, 17 = All/Omni. When an external keyboard sends a note **in** on channel N, the router looks for the instrument whose `0x1F == N+1` and plays it. |

Where it lives: read **only** by `MMR_FindInst` in `IT_I.ASM:8831`. Confirmed:
nothing in the output/playback path ever reads `0x1F`. The two directions are
independent — you can have an instrument that listens on MIDI-in ch 3 *and*
echoes out to MIDI-out ch 10, or either alone, or neither.

**So:** "MIDI Channel" + "MIDI Program" above your new field = IT as a
**sender** (sequencing an outboard synth). "MIDI In Channel" = IT as a
**receiver** (your goal: a live 16-part sampler). Same instrument, opposite
plumbing.

---

## 2. Why no incoming notes trigger anything — ranked theories

The MIDI *parser* clearly works: channel-1 note entry already plays the
selected sample. So bytes arrive and assemble. The failure is downstream of
that, inside the new multitimbral router. In likelihood order:

### Theory A (most likely): the engine is never actually ON for your workflow
- `MIDIMultiEnable` defaults to **0** (`IT_MUSIC.ASM:3987`). Nothing routes
  until it's turned on.
- It is turned on **only** by Shift-F4 → confirm dialog → `Music_CreateMIDIIn
  Instruments` (which flips the flag at the end).
- Commit `b5a0c66` gates Shift-F4 to **Instrument mode only** (`IT_G.ASM:337`,
  `Test Byte Ptr [DS:2Ch], 4`). In **Sample mode**, Shift-F4 does nothing but
  print "Enable Instruments mode first (F12)".
- Your described workflow is **sample-centric** ("whichever sample is
  selected gets triggered" — that's F3/Sample-mode keyjazz). If you're in
  Sample mode when you press Shift-F4, the feature **never enables**. Net:
  total silence, exactly as reported.

### Theory B (also likely, and the same root as your Shift-F4 complaint): the auto-created instruments point at empty sample slots
- `Music_CreateMIDIInInstruments` (`IT_MUSIC.ASM:3997`) fills the first 16
  **empty-name** slots, and for each instrument maps **all 120 notes → the
  sample whose number equals the instrument's own slot** (`4068–4076`,
  keymap sample byte = `BL` = slot index).
- So instrument in slot 7 plays **sample 7**. If sample 7 is empty → silence.
- Unless you happen to have samples loaded in exactly the slots the creator
  chose, most/all of the 16 channels trigger a voice with **no sample data**
  = inaudible. The router *is* firing; there's just nothing to play.

### Theory C (ruled out): "Music_PlayNote doesn't work while stopped"
- Tempting, but **false**. `Music_PlayNote` (`IT_MUSIC.ASM:9245`) is the same
  proc the pattern editor uses for QWERTY keyjazz while transport is stopped,
  on host channels initialized by `Music_Stop`'s clear loop. Host channels
  48..63 are valid and pre-cleared. So the call itself is sound — given a
  real sample behind the instrument, it will play.

### Smaller real risks worth a marker-pass if A+B are cleared
- Note-off uses a fixed host channel per MIDI channel (`48 + ch`), so fast
  overlapping notes on one channel cut each other — fine for monophonic test,
  but "stuck note" or "only last note sounds" could show here, not "silence".
- Running-status streams (note-ons without repeated status byte): the
  consume/`MIDIDataInput` reset only happens when the router returns 1. Worth
  confirming the next note pair re-assembles when the router returns 0. Not
  the cause of *total* silence, but a tail bug.

**Honest bottom line:** the overwhelmingly probable reason you hear nothing is
**A (never enabled because you're in Sample mode) and/or B (instruments map to
empty samples)** — not a deep bug in the router. The router logic itself reads
correctly.

---

## 3. The Shift-F4 redesign you asked for

### Current behavior (the bug you saw)
Shift-F4 today does exactly one thing: scan slots 1..99, and for the first 16
slots whose **name byte is 0** (`IT_MUSIC.ASM:4026`), fabricate a brand-new
"MIDI In ChNN" instrument mapped to the same-numbered sample. That's why "new
slots get generated in no-name slots" — it's hunting empty slots by design,
and it ignores the instruments/samples you already set up.

### What you want: a choice dialog
Replace the single confirm with a 2-option (or 3-option) dialog:

1. **Map current / existing** — don't fabricate anything. Walk the
   instruments (or samples) you already have content in, and assign MIDI-in
   channels 1..16 to the first 16 that hold real content. This respects your
   existing names and sample mappings → actually makes sound.
2. **Create new in slots** — the present behavior, but it should create
   instruments that point at **loaded** samples, or at minimum tell you which
   sample slots it bound so you can load them.
3. (optional) **Cancel.**

"Map current" is almost certainly the mode you actually want, and it dovetails
with Theory B: it removes the empty-sample problem entirely because it reuses
instruments that already have working sample keymaps.

---

## 4. The bigger strategic fork (worth a decision before more code)

There's a conceptual mismatch driving a lot of this pain:

- The multitimbral router is **instrument-centric** (matches `0x1F`, plays via
  instrument keymap, requires Instrument mode).
- Your mental model and existing working path are **sample-centric** ("the
  selected sample gets triggered").

Two clean ways forward:

- **(I) Stay instrument-based** — keep the router, add the "map current"
  dialog, and either drop the Instrument-mode gate or have Shift-F4
  auto-switch into Instrument mode first. You get full IT instrument features
  (envelopes, NNA, filters) per MIDI channel. More setup per channel.
- **(S) Add a sample-based multitimbral mode** — MIDI channel N triggers
  **sample slot N** (or a small configurable channel→sample map) directly via
  the keyjazz/`Music_PlaySample` path, with **no instruments at all**. Works
  in Sample mode where you already live, sidesteps the empty-instrument
  problem, and matches "whichever sample" thinking. Simplest path to "16
  channels each play a different sample, live."

These aren't exclusive — but picking the primary one decides whether the next
edit is "fix the dialog + gate" (I) or "write a small sample-mode router" (S).

---

## 5. Concrete next steps once you choose

If **(I) instrument-based + map-current dialog**:
1. Turn `O1_ConfirmCreateMIDIIn` into a 3-button list ("Map current" /
   "Create new" / "Cancel").
2. Add `Music_MapCurrentMIDIIn`: walk instruments 1..N, assign `0x1F = 1..16`
   to the first 16 that have a non-default sample keymap; set
   `MIDIMultiEnable=1`; leave names/samples intact.
3. Either remove the Sample-mode gate or auto-enter Instrument mode in
   `Glbl_Shift_F4` before the dialog.

If **(S) sample-based router**:
1. Add a parallel router in `MIDIMulti_Route` (or a sibling) that, when a
   "sample mode" sub-flag is set, maps incoming channel N → sample slot
   (N or a stored map) and triggers via the keyjazz/`Music_PlaySample` path
   on host channel `48+N`.
2. Drop the Instrument-mode requirement for this mode.
3. Shift-F4 dialog: "16 channels → samples 1..16?" with the live toggle.

Either way: build, then test on real hardware / DOSBox-X with an external
clock+keyboard, and if anything hangs, VRAM debug markers before any
speculative IRQ-adjacent fix (per the project's diagnostic discipline).
