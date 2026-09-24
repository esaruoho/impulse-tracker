# MIDI Start Appears To Select Sample/Instrument 81

Problem: sending MIDI transport start/clock starts Impulse Tracker playback, but the current sample/instrument jumps to 81.

## Diagnosis

MIDI Start and Timing Clock themselves do not select instrument 81 in the current source.

- MIDI Start is `FA` and Timing Clock is `F8`.
- `MIDISend` handles System Real-Time bytes `F8..FF` before the normal MIDI parser and exits without touching `MIDIStatusByte`, `MIDIDataInput`, or `MIDIDataByte1/2`.
- `FA` Start resets the MIDI clock counter and calls `Music_KBPlaySong`; `F8` Clock only updates clock/tempo handling.

The code path that *does* select a sample/instrument is Program Change:

- `IT_OBJ1.ASM` `ChainMIDICommands` maps status `0C000h` to `MIDI_SetInstrument`.
- `IT_PE.ASM` `MIDI_SetInstrument` stores the Program Change data byte `DL` into `LastInstrument`.
- `LastInstrument` is used as a 1-based UI-facing current sample/instrument value; helper `PE_GetLastInstrument` decrements it for 0-based internal indexing.

So a jump to displayed slot 81 strongly indicates an incoming MIDI Program Change with data byte `80` decimal (`0x50` hex), i.e. General MIDI program number 81 in 1-based naming. Many controllers/DAWs can send a Program Change at transport start, scene launch, clip launch, or track activation. That accompanying `C0 50` (or `Cn 50` on another MIDI channel) is the likely culprit, not the `FA`/`F8` transport bytes.

## Evidence

- `IT_K.ASM:2170-2219`: `F8`/`FA` dispatch happens before normal parser; `FA` calls `Music_KBPlaySong`.
- `IT_K.ASM:2304-2328`: non-real-time channel/status messages update `MIDIStatusByte`, data bytes, and `MIDIDataInput`.
- `IT_K.ASM:1205-1215`: completed MIDI messages are emitted as `CH=status`, `DX=data bytes` into the key/object dispatcher.
- `IT_OBJ1.ASM:3402-3413`: shared MIDI command chain maps `08000h` note-off, `09000h` note-on, and `0C000h` Program Change to `MIDI_SetInstrument`.
- `IT_PE.ASM:14434-14456`: `MIDI_SetInstrument` writes `DL` to `LastInstrument` if `DX <= 99`.
- `IT_PE.ASM:1098-1099`: `LastInstrument` stores the current sample/instrument selector.
- `IT_PE.ASM:12872-12876`: `PE_GetLastInstrument` decrements `LastInstrument` when converting to internal zero-based indexing.

## Practical confirmation

Use the Shift-F1 MIDI monitor or an external MIDI monitor and look for a Program Change around the transport start event:

```text
FA          ; Start
F8 F8 ...   ; Timing Clock
C0 50       ; Program Change 80 decimal, displayed as 81
```

If that `C0 50`/`Cn 50` is present, filter Program Change at the sender or change IT so Program Change no longer updates `LastInstrument` during transport sync.
