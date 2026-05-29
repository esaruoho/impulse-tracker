# MIDI-In Multitimbral Synth — implementation map (verified 2026-05-29)

Goal: DOS Impulse Tracker fork becomes a live multitimbral sampler-synth.
Incoming MIDI note-on on channel C plays the instrument(s) whose per-instrument
"MIDI-In channel" == C, live, regardless of active screen, while transport may
be stopped. Plus a Shift-F4 dialog that batch-creates 16 instruments, one per
MIDI-in channel.

## Decisions (locked with Esa, 2026-05-29)
- Codebase: esaruoho/impulse-tracker (DOS, TASM). Single MPU-401 port is fine.
- Routing: per-instrument MIDI-in channel (each instrument claims a channel).
- Storage: instrument-header offset **1Fh** (IT-spec reserved "x" byte; verified
  NO code anywhere reads/writes `[..+1Fh]` for instruments). 0=off, 1..16=channel,
  17=All/Omni. Saved verbatim inside the 554-byte header → persists in .IT/.ITI.
- Behavior: pure live synth; never auto-records into pattern.
- Entry key: **Shift-F4** = key word `5700h` (verified free; Shift-F1/2/3 =
  5400/5500/5600h taken). Global, works from any screen.

## Tooling notes (this environment)
- `.ASM`/`.INC` files are normal **CRLF** (hexdump confirmed `0d 0a`). The Read
  tool works on them directly and shows TRUE line numbers — use it.
- GOTCHA: `tr '\r' '\n' < FILE | sed -n` DOUBLES line numbers (each `\r\n` becomes
  two `\n`). Any line number gathered that way is ~2x the real line. Trust Read.
- Editing: multi-line inserts into CRLF files via the Edit tool need `\r\n` in the
  strings, OR use a python byte-replace that writes `\r\n`. Single-line Edits OK.
- Do NOT send many Bash calls in parallel: if one errors the rest are cancelled,
  and cwd resets between calls. One command at a time.
- Build: `dosbox-x -conf buildall.conf -fastlaunch -exit -nogui -nomenu` (~57s);
  toolchain in `tools-local/` (TASM41 + TLINK301). Output: IT.EXE + *.DRV. Both
  buildall.conf and dosbox-x confirmed present.

## Key locations (Read-tool TRUE line numbers unless noted)
- Instrument header template: `IT_MUSIC.ASM` `InstrumentHeader`, 554 bytes.
  0x3C=MCh(out), 0x3D=MPr, 0x3E/3F=MIDIBnk, 0x40=keyboard table. 0x1F reserved.
- `Music_ClearInstrument` `IT_MUSIC.ASM:3926` (Mov CX,554; Rep Movs from template).
- Instrument MIDI object defs: IT_OBJ1.ASM ~line 616 (re-Read to confirm; this is
  the InstrumentMIDIChannel [DW 14, bound DW 3Ch, min/max 0,17] / Program / Bank
  block + InstrumentMIDIText label). Object IDs 25-28 used; next free ~29 (check
  filter-envelope objects 30/31 under FILTERENVELOPES).
- Global key table: `IT_OBJ1.ASM:3126` `GlobalKeyList DB 0 ; F1`. Add an entry
  `DB 1 / DW 5700h / DD DWord Ptr Glbl_Shift_F4`. Note existing Shift handlers are
  named `Glbl_Shift_F1` / `Glbl_Shift_F6` / `Glbl_Shift_F9` (underscore form) and
  are Extrn'd at IT_OBJ1.ASM:175-177; F-key handlers live in IT_G.ASM.
- F-key handlers: IT_G.ASM `Glbl_F2` (211), `Glbl_F3` (290), `Glbl_F4`/`Glbl_F4_2`
  (308/329), `Glbl_Shift_F1` (444), `Glbl_Shift_F9` (458), `Glbl_Shift_F6` (474).
  Add `Glbl_Shift_F4` here + Global/Extrn decls.
- InstrumentGlobalKeyList = IT_OBJ1.ASM:6524 (instrument-screen key handler).
  Pitch-tab screen list references InstrumentGlobalKeyList at IT_OBJ1.ASM:6315.
- ITI save: IT_D_ITI.INC `D_SaveITInstrument` (writes 554-byte header block from
  DiskBuffer — verbatim copy, so 0x1F persists). Also audit IT_D_IT.INC song-save
  instrument write to confirm verbatim (should be).
- MIDI-in entry: `IT_K.ASM` `MIDISend` (~line 1904 real; global, main-loop context;
  already hosts FA/FB/FC sync + F8 clock). Globals MIDIStatusByte / MIDIDataByte1 /
  MIDIDataByte2 / MIDIDataInput. K_GetKey (~1173) turns a complete msg into CH=
  status, DX=note/vel for the ACTIVE page only; PE keymap DB-6 entries → PE_MIDINote
  / PE_MIDINoteOff (IT_PE.ASM ~13934/14034). The channel low-nibble is currently
  IGNORED.
- Live note play: `Music_PlayNote` `IT_MUSIC.ASM:9144` (AX=host chan, DS:SI=5-byte
  event {note,ins,vol,cmd,cmddat}, DH flags; does its own ClI/StI — safe to call
  from MIDISend main-loop context).
- Channel alloc/track: `MIDI_AllocateChannel` `IT_I.ASM:4824` (AX=base,DL=note,
  DI=max), `MIDI_FindChannel` `IT_I.ASM:4895` via `MIDITable` (note→chan+1).
- Modal confirm dialog pattern: `IT_OBJ1.ASM:3846` `O1_ConfirmClearMessage` +
  OK/Cancel buttons (return 1/0) + `OKCancelList` key handler.

## Build units (do in order, build+verify each)
1. Per-instrument field: add `InstrumentMIDIInChannel` object (type 14, bound
   `DW 1Fh`, min/max 0,17) to the Pitch tab + a text label; wire nav links into the
   existing vertical chain (Bank2 below -> new; new above=Bank2, below=0FFFFh);
   add the object ptr to the Pitch screen object list. Template default 0 at 0x1F
   already. No header size change. BUILD.
2. Shift-F4 batch dialog: `Glbl_Shift_F4` in IT_G.ASM + GlobalKeyList entry
   (DW 5700h). Modal confirm ("Create 16 MIDI-In instruments?"); on OK loop 16
   slots from current instrument: Music_ClearInstrument + set [ins+1Fh]=1..16 +
   name "MIDI In ChNN". Optionally auto-enable the live engine. BUILD.
3. Live engine: in MIDISend, gate on a new MIDIMultiEnable flag. On a complete
   note-on (status 9n, n=channel), scan instruments 1..99 for [ins+1Fh]==n+1 (or
   17=All), play each via Music_PlayNote on an allocated host channel; track per
   (channel,note)->host for note-off. On note-off (8n or 9n vel0) release tracked
   voice(s). When the engine consumes a message, clear MIDIDataInput so K_GetKey
   doesn't ALSO deliver it to the page (prevents double-trigger / pattern record).
   Add a toggle on the Shift-F1 MIDI Monitor (default off; batch-create turns on).
   This is IRQ-adjacent: build, and if it hangs use VRAM debug markers
   (WAV_DebugMark-style) before any speculative fix. BUILD + hardware/DOSBox test.

## Status as of 2026-05-29
Design + verification complete. NO .ASM/.INC files modified yet (source tree clean;
only this handoff .md added). Next: execute build units 1->2->3 with a build after each.
