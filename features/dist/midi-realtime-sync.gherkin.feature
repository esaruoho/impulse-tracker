# Pure Gherkin test extracted from features/midi-realtime-sync.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/midi-realtime-sync.feature

Feature: External MIDI Real-Time Sync
  As a musician slaving the DOS PC to an external sequencer or drum machine,
  I want MIDI System Real-Time messages to drive Impulse Tracker's transport
  and tempo,
  So that pressing play on the master device starts, stops, and clocks IT in
  time with the rest of the rig.

  # --- The spec-correctness claim that the whole feature rests on ------------
  @shipped @build-verified @hw-untested
  Scenario: Real-Time bytes are dispatched without disturbing running status
    # cite: IT_K.ASM MIDISend (~1947) tests AL >= 0F8h BEFORE the running-status
    #       store; per the MIDI spec, F8h..FFh are transparent to running status.
    # cite: commit ec42bd1
    Given an incoming MIDI byte stream with running status active
    When a System Real-Time byte (0F8h..0FFh) arrives mid-message
    Then it is handled immediately and MIDIStatusByte / MIDIDataInput are left intact
    And only F8h, FAh, FBh, FCh act; F9h, FDh, FEh, FFh are ignored

  # --- Transport: Start / Stop / Continue -------------------------------------
  @shipped @build-verified @hw-untested
  Scenario: 0xFA Start plays the song from the top
    # cite: IT_K.ASM MIDISendRTStart (~1968) -> Music_KBPlaySong (F5 equivalent)
    # cite: commit ec42bd1 ; status: live start unverified on hardware
    Given MIDI Transport is enabled and no loader keyjazz is in flight
    When a 0xFA (MIDI Start) byte arrives
    Then playback begins from order 0 (Music_KBPlaySong, safe to call again)
    And the clock-tracking counter MIDIClockCount is reset to 0

  @shipped @build-verified @hw-untested
  Scenario: 0xFC Stop halts playback
    # cite: IT_K.ASM MIDISendRTStop (~2000) -> Music_Stop
    # cite: commit ec42bd1
    Given MIDI Transport is enabled and no loader keyjazz is in flight
    When a 0xFC (MIDI Stop) byte arrives
    Then Music_Stop is called and playback halts

  @shipped @build-verified @hw-untested
  Scenario: 0xFB Continue currently behaves as Start (known v1 limitation)
    # cite: IT_K.ASM MIDISendRTContinue (~1958) jumps to MIDISendRTStart_Play
    # cite: comment "Continue = Start for v1" ; commit ec42bd1
    Given MIDI Transport is enabled
    When a 0xFB (MIDI Continue) byte arrives
    Then playback restarts from order 0 (NOT resumed from last position)

  @todo
  Scenario: 0xFB Continue resumes from the last-known order/row
    # The proper behaviour: pass last order/row to Music_PlayPartSong instead of
    # restarting. Deferred; IT already has Music_PlayPartSong to build on.
    Given playback was stopped at order N, row R
    When a 0xFB (MIDI Continue) byte arrives
    Then playback should resume from order N, row R

  # --- Clock: external tempo sync at 24 PPQ -----------------------------------
  @shipped @build-verified @hw-untested
  Scenario: 0xF8 Clock derives IT tempo from the master at 24 PPQ
    # cite: IT_K.ASM MIDISendRTClock (~2023): count 24 clocks = 1 quarter note,
    #       measure DOS-tick (Int 1Ah) delta across the beat -> Music_SetTempoFromClocks
    # cite: commits 03b0a6d (feature) + 0a82cb3 (enable flag + sanity)
    Given MIDI Sync (F8 Clock) is enabled
    When 24 consecutive 0xF8 Clock bytes have been received
    Then the DOS-tick delta across that quarter-note is measured
    And a delta of 0 (too fast) or > 2730 ticks (~150s, BPM < 0.4) is rejected
    And otherwise Music_SetTempoFromClocks applies the derived tempo

  # --- The user-visible gates (independent of each other) ---------------------
  @shipped @build-verified @hw-untested
  Scenario: MIDI Transport can be switched off, swallowing FA/FB/FC
    # cite: IT_K.ASM MIDITransportEnable (default 1); gate at ~1988 and ~2011
    # cite: Glbl_MIDITransport_Toggle (~1773); commit 731e168
    Given the user turns MIDI Transport OFF on the Shift-F1 screen
    When 0xFA / 0xFB / 0xFC arrive
    Then the MIDI Monitor counters still tick (the byte was seen)
    But no playback start or stop occurs

  @shipped @build-verified @hw-untested
  Scenario: MIDI Sync (clock) can be switched off independently, ignoring F8
    # cite: IT_K.ASM MIDISyncEnable (default 1); gate at ~2029 ; commit 0a82cb3
    Given the user turns MIDI Sync (F8 Clock) OFF on the Shift-F1 screen
    When 0xF8 Clock bytes arrive
    Then they are counted in the monitor but never alter IT's tempo
    And the Transport gate is unaffected (the two switches are independent)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: MIDI Sync (F8 Clock) OFF persists across restart
    # cite: IT_K.ASM MIDI_SyncEnabled / MIDI_SetSyncEnable; IT_DISK.ASM
    #       D_SaveDirectoryConfiguration +4 write and D_InitDisk +4 restore.
    Given the user turns MIDI Sync (F8 Clock) OFF on the Shift-F1 screen
    When IT exits and starts again
    Then MIDI Sync (F8 Clock) remains OFF
    And the setting is still visible as OFF on the Shift-F1 MIDI screen

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: All Shift-F1 MIDI toggles save immediately
    # cite: IT_K.ASM Glbl_Alt_F12, Glbl_MIDITransport_Toggle,
    #       Glbl_MIDIMulti_Toggle, and Glbl_MIDIStopF8_Toggle call
    #       D_SaveDirectoryConfiguration immediately after changing state;
    #       IT_DISK.ASM persists the four force-off bytes at +3..+6.
    Given the Shift-F1 MIDI screen is open
    When I change any of the four MIDI toggle settings
      Then IT.CFG is updated immediately
      And the changed setting survives exiting and restarting IT

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: MIDI input is re-armed after restarting IT
    # cite: IT.ASM startup calls Music_ResetMIDIInput immediately after
    #       Music_AutoDetectSoundCard; IT_MUSIC.ASM Music_ResetMIDIInput calls
    #       DriverReinitSound and MIDI_ResetInputState; IT_K.ASM clears the
    #       running-status parser and F8 clock state.
    # cite: SoundDrivers/MIDIDRV.ASM ReInitSound resets the MPU UART and
    #       UnInitSound restores interrupts after ResetUART.
    Given IT has been quit and its MIDI-capable sound driver is selected again
    When IT starts and finishes sound-card detection
    Then the driver UART is explicitly reinitialized
    And any partial MIDI message from the prior process is discarded
    And MIDI input is ready for a new Renoise transport or note message

  @shipped @build-verified @hw-untested
  Scenario: Loader keyjazz suppresses transport re-entry
    # cite: IT_K.ASM MIDISyncLoaderSuppress (default 0); gate at ~1991 and ~2014
    # cross-card: features/loader-keyjazz-hang.feature owns the suppress flag
    Given the F3/F4 loader keyjazz path has set MIDISyncLoaderSuppress
    When 0xFA / 0xFC arrive while a sample preview is mid-load
    Then MIDISend does NOT call Music_KBPlaySong / Music_Stop (no re-entry race)

  # --- Driver-level prerequisite (why it works end-to-end) --------------------
  @shipped @build-verified @hw-untested
  Scenario: Sound drivers pass F8-FF through to MIDISend
    # cite: SoundDrivers/*.ASM CheckMIDI: drop only F0h..F7h (System Common/SysEx),
    #       pass F8h..FFh to the ring buffer. Before the fix, CheckMIDI dropped
    #       everything >= F0h at IRQ time, silently eating FA/FB/FC/F8.
    # cite: commit 4ebf849 (14 drivers) + 78fb72d (GUSMIXDR + IWDRV) = 16 total
    Given a sound driver receiving MIDI bytes at IRQ time
    When a System Real-Time byte (F8h..FFh) is read from the UART
    Then it is buffered and drained to MIDISend in the main loop
    And only F0h..F7h are still filtered at the driver

  # --- Observability ----------------------------------------------------------
  @shipped @build-verified @hw-untested
  Scenario: The MIDI Monitor shows live Real-Time byte counters
    # cite: IT_K.ASM K_ShowMIDIInput (~1690) renders MIDIMon_StartCount /
    #       StopCount / ContCount / F8Count + last RT byte + DOS tick
    # cite: commit 95f628a ; lives on the Shift-F1 MIDI screen
    Given the Shift-F1 MIDI screen is open
    Then it shows running counts of FA Start, FC Stop, FB Continue, F8 Clock
    And the last Real-Time byte received and the DOS tick at receipt

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The Shift-F1 toggle buttons show their live ON/OFF state
    # cite: IT_K.ASM K_ShowMIDIInput draws ON/OFF text for MIDISyncEnable,
    #       MIDITransportEnable, Music_GetMIDIMultiEnable, and
    #       MIDIStopOnF8Enable inside the four Shift-F1 toggle buttons.
    Given the Shift-F1 MIDI screen is open
    Then MIDI Sync (F8 Clock) visibly says ON or OFF
    And MIDI Transport (FA/FB/FC) visibly says ON or OFF
    And Toggle Multitimbral MIDI-In visibly says ON or OFF
    And Send MIDI Stop (FC) on F8 visibly says ON or OFF
