# Session — Send MIDI Stop (FC) out on F8

> The spawning conversation for `midi-out-stop-on-f8.feature`. Faithful, not
> flattering: the request, what was verified before any code was written, the
> design choices and why, and the honest grades.

## The request

Esa: *"can F8 be wired, set, in Shift-F1 so that pressing F8 will send a Midi
Stop Clock? And can we make it so that we in Shift-F1 define, that there can be
a singular clause, where ImpulseTracker actually sends a Midi Stop Out on F8.
but nothing else. no midi feedback loop, etc."*

Decoded:
- F8 (the existing Stop key) should ALSO emit an outbound MIDI Stop (0FCh).
- A toggle on the Shift-F1 MIDI screen governs it.
- "Singular clause" + "no feedback loop" = the transmit must happen in exactly
  one place, sourced only by the keypress, so a MIDI-thru loopback can't storm.

## What was checked BEFORE writing any code

Two parallel Explore passes mapped the unknowns rather than guessing:

1. **MIDI-out path.** `MIDISendFilter` (IT_MUSIC.ASM:1111) is the blessed
   sender: tests `DriverFlags` bit 0 (no-ops if the driver has no MIDI out),
   and for a byte >= 0F0h it takes the `JAE` branch that SKIPS the
   running-status store — exactly correct for a System Real-Time byte —
   then calls `DriverMIDIOut`. It reads neither SI nor DI, so it is safe to
   call standalone. Confirmed by reading 1111–1132 directly.

2. **F8 dispatch.** F8 has TWO stop paths: an instant IRQ-level `Music_Stop`
   in the keyboard ISR (IT_K.ASM:755) AND the main-loop `Glbl_F8`
   (IT_G.ASM:637). The scancode is queued at IT_K.ASM:735 *before* the ISR's
   F8 special-case, so on a normal press BOTH fire — the ISR stops instantly,
   then the queued key dispatches `Glbl_F8`. That made the design choice obvious.

## Design decisions (and the rejected alternative)

- **Transmit from `Glbl_F8` (main loop), NOT the IRQ handler at IT_K.ASM:755.**
  `UARTOut` busy-waits on the UART status port; doing that inside the keyboard
  ISR is the wrong place. `Glbl_F8` runs in main-loop context where the UART
  poll is fine, and it fires on every normal F8. The IRQ path was left
  completely untouched.
- **One transmit site = the no-feedback-loop guarantee.** `Music_SendMIDIStop`
  has exactly one caller: `Glbl_F8`. The inbound real-time path
  (`MIDISendRTStop`) only ever calls `Music_Stop`; it never transmits. So
  output is sourced *exclusively* by the physical key. Worst case under a
  loopback: F8 → send 0FCh → received 0FCh → `Music_Stop` (already stopped,
  no-op). A Stop cannot beget a Stop. This is the "singular clause" Esa asked
  for, made structural rather than guarded-by-flag.
- **Send `0FCh` via `MIDISendFilter`, not a raw `DriverMIDIOut`.** Going through
  the filter gets the no-MIDI-driver no-op and the spec-correct running-status
  handling for free.
- **Mirror the existing Shift-F1 toggles.** Flag `MIDIStopOnF8Enable DB 1`
  (default ON), `Glbl_MIDIStopF8_Toggle`, and a button cloned from the
  Multitimbral toggle — same pattern as MIDI Sync / MIDI Transport. A Far
  query `MIDI_F8StopEnabled` bridges the Keyboard-segment flag to the
  Pattern-segment `Glbl_F8` (mirrors the `MIDI_SetLoaderSuppress` Far-helper
  pattern).
- **Not persisted to IT.CFG.** Matches the sibling MIDI toggles
  (`MIDISyncEnable` / `MIDITransportEnable` are runtime-only `DB 1`). Esa did
  not ask for persistence; keeping it runtime-only matched the request's
  "simple" framing. Easy to add to the PE_ForkExtConfig block later if wanted.

## Build + honest grades

Built in DOSBox-X via `buildall.conf`. All four changed modules
(IT_G, IT_K, IT_MUSIC, IT_OBJ1) reported **Error/Warning = None**; IT.EXE
linked (477,392 bytes). → `@build-verified`.

NOT graded verified: the actual 0FCh leaving the UART to slaved gear is
`@hw-untested` (DOSBox-X can't easily confirm outbound MIDI to a device), and
the Shift-F1 button is `@runtime-untested` (not yet run + watched in IT.EXE).
The no-feedback-loop property is provable by reading the call graph (one
caller), but exercising it on a real loopback is still `@hw-untested`.

## Follow-up: "survive restarts" (commit 222962f)

Esa: *"survive restarts"* — persist the toggle to IT.CFG.

The fork already has the `PE_ForkExtConfig` 16-byte block in IT.CFG (read in
`D_InitDisk`, written in `D_SaveDirectoryConfiguration`) with 13 reserved pad
bytes. But the block's fields live in the **Pattern** segment, and our flag
lives in the **Keyboard** segment — so the block can't store it directly.

Decisions:
- **Mirror + sync, not relocate.** Keep `MIDIStopOnF8Enable` where it is (its
  toggle + query already work); add a mirror byte at block **offset +3** and
  sync it ↔ the live flag at load (`D_InitDisk`) and save
  (`D_SaveDirectoryConfiguration`). New Far setter `MIDI_SetF8StopEnable`
  bridges into the Keyboard segment; the existing `MIDI_F8StopEnabled` reads it.
- **FORCE-OFF sense (the backward-compat trap).** Pre-222962f IT.CFGs already
  wrote offset +3 as a reserved **zero**, and files with no block at all keep
  the static default zero. If 0 meant OFF, every existing user would boot to a
  surprise OFF. So the byte stores the *non-default* state: **0 = ON (default),
  nonzero = OFF.** Live `enable = (byte == 0)`, persisted `byte = NOT enable`.
  Every old config and fresh install decodes to ON.
- **Build catch: `[DX+3]` is illegal in 16-bit real mode** — DX is not a valid
  base register (only BX/BP/SI/DI). First build failed with "Illegal indexing
  mode" at both sync sites; routed through BX (load) and SI (save). DX stays
  the DOS buffer pointer for the surrounding Int 21h / D_SaveBlock calls.

Rebuilt: IT_PE / IT_K / IT_DISK all Error/Warning = None, IT.EXE links
(477,470 bytes). Persistence scenarios graded `@build-verified @runtime-untested`
(not yet round-tripped through a real save/quit/relaunch in IT.EXE).

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work-impulse-tracker/adf61574-f4a4-4fbc-b9db-dbcf7476fc40.jsonl
- Session ID: `adf61574-f4a4-4fbc-b9db-dbcf7476fc40`
- Resume: `claude --resume adf61574-f4a4-4fbc-b9db-dbcf7476fc40`
- Date: 2026-06-04 (feature commit `67cdb60`)
