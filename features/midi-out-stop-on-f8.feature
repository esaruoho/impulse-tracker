# =============================================================================
# WIKI PAGE / REPORT CARD: Send MIDI Stop (FC) out on F8
# Convention: ../GHERKIN-FEATURE-WIKI-PATTERN.md  ·  skill: report-card
#
# WHAT THIS CARD SPAWNS (the seed):
#   codespace  - Glbl_F8 (IT_G.ASM) gains a single, gated transmit call;
#                Music_SendMIDIStop (IT_MUSIC.ASM) is the lone transmit site;
#                MIDIStopOnF8Enable flag + Glbl_MIDIStopF8_Toggle + the Far
#                query MIDI_F8StopEnabled + setter MIDI_SetF8StopEnable (IT_K.ASM);
#                the Shift-F1 button (IT_OBJ1.ASM); the IT.CFG persistence mirror
#                at PE_ForkExtConfig +3 (IT_PE.ASM) synced in IT_DISK.ASM.
#   thinkspace - midi-out-stop-on-f8.session.md (why the transmit lives in the
#                main-loop Glbl_F8 and NOT the IRQ F8 path; why one transmit
#                site means no feedback loop is structurally possible).
#   areaspace  - OWNS: the OUTBOUND transmission of the single 0FCh transport
#                Stop byte triggered by the F8 keypress, and its Shift-F1 gate.
#                MUST NOT TOUCH: the INBOUND System Real-Time intercept
#                (features/midi-realtime-sync.feature owns FA/FB/FC/F8 IN), the
#                per-channel MIDI note-off / MIDICOMMAND_STOP macro data that
#                Music_Stop already emits, or the IRQ-level F8 stop at
#                IT_K.ASM:755 (left untouched -- no UART busy-wait in the ISR).
#
# Report-card legend (one grade tag per scenario):
#   @shipped         - in origin/main
#   @build-verified  - assembles + links clean (TASM 4.1 / TLINK 3.01); all four
#                      changed modules reported Error/Warning = None, IT.EXE links
#   @runtime-untested- not yet run + watched in IT.EXE / DOSBox-X
#   @hw-untested     - NOT exercised with real MIDI gear; DOSBox-X cannot easily
#                      confirm a 0FCh actually leaving the UART to a slaved device
#
# RESULT (what shipped):
#   delivery     : direct-push to main, no PR
#   feature commits:
#     67cdb60  2026-06-04  Glbl_F8 transmits 0FCh out, gated by Shift-F1 toggle
#     222962f  2026-06-04  persist the toggle across restarts (IT.CFG +3)
#   card-authoring commit: (this commit)
#   files: IT_G.ASM (transmit site), IT_MUSIC.ASM (Music_SendMIDIStop),
#          IT_K.ASM (flag + toggle + query + setter + messages),
#          IT_OBJ1.ASM (button), IT_PE.ASM (PE_ForkExtConfig +3 mirror byte),
#          IT_DISK.ASM (load/save sync in D_InitDisk + D_SaveDirectoryConfiguration)
#
# Source files back-linked to this card (grep "features/midi-out-stop-on-f8"):
#   IT_G.ASM      - Glbl_F8 (the singular transmit site)
#   IT_MUSIC.ASM  - Music_SendMIDIStop (the transmit)
#   IT_K.ASM      - MIDIStopOnF8Enable flag, Glbl_MIDIStopF8_Toggle, gate query,
#                   MIDI_SetF8StopEnable (persistence setter)
#   IT_OBJ1.ASM   - MIDIStopF8ToggleButton on the Shift-F1 MIDI screen
#   IT_PE.ASM     - PE_ForkExtConfig +3 (MIDIStopOnF8PersistOff mirror byte)
#   IT_DISK.ASM   - D_InitDisk load-sync + D_SaveDirectoryConfiguration save-sync
#
# WATCH: Glbl_F8 Music_SendMIDIStop Glbl_MIDIStopF8_Toggle MIDI_F8StopEnabled MIDI_SetF8StopEnable
# =============================================================================

Feature: Send MIDI Stop (FC) out on F8
  As a musician whose DOS PC is the master in a MIDI rig,
  I want pressing F8 (Stop) to also transmit a single MIDI Stop to slaved gear,
  So that one keypress halts both Impulse Tracker and everything downstream,
  with no risk of a transport feedback loop.

  # --- The transmit: one byte, one site --------------------------------------
  @shipped @build-verified @hw-untested
  Scenario: F8 transmits exactly one MIDI Stop byte out
    # cite: IT_G.ASM Glbl_F8 (~637) -> Music_SendMIDIStop when the gate is ON,
    #       BEFORE the existing Music_Stop ; commit 67cdb60
    # cite: IT_MUSIC.ASM Music_SendMIDIStop -> MIDISendFilter with AL=0FCh
    Given the "Send MIDI Stop on F8" toggle is ON
    And a MIDI-capable sound driver is loaded
    When the user presses F8 to stop playback
    Then a single 0FCh System Real-Time Stop byte is sent out the MIDI port
    And local playback then stops via Music_Stop exactly as before

  @shipped @build-verified @hw-untested
  Scenario: The Stop byte does not disturb MIDI running status
    # cite: IT_MUSIC.ASM MIDISendFilter (~1111): AL >= 0F0h takes the JAE branch
    #       and skips the LastMIDIByte running-status store, per the MIDI spec.
    Given running status is active on the MIDI output
    When F8 transmits the 0FCh Stop byte
    Then LastMIDIByte (the running-status cache) is left untouched
    And the next note/CC byte still benefits from running-status compression

  @shipped @build-verified @hw-untested
  Scenario: With no MIDI-capable driver the transmit is a clean no-op
    # cite: IT_MUSIC.ASM MIDISendFilter tests CS:DriverFlags bit 0 first; if the
    #       driver has no MIDI out it returns without calling DriverMIDIOut.
    Given the loaded sound driver has no MIDI output (DriverFlags bit 0 clear)
    When the user presses F8 with the toggle ON
    Then Music_SendMIDIStop returns harmlessly and only Music_Stop runs
    And no byte is written to a non-existent UART

  # --- The no-feedback-loop invariant (the whole point) ----------------------
  @shipped @build-verified @hw-untested
  Scenario: A MIDI-thru loopback cannot create a transport storm
    # cite: the ONLY caller of Music_SendMIDIStop is Glbl_F8 (the keypress).
    #       The inbound path (IT_K.ASM MIDISendRTStop) only ever calls
    #       Music_Stop -- it NEVER transmits. So output is sourced exclusively
    #       by the physical F8 key, never by a received byte.
    Given MIDI OUT is physically or virtually looped back to MIDI IN
    And inbound MIDI Transport response is also enabled
    When the user presses F8 (sending 0FCh out, which arrives back in)
    Then the received 0FCh only calls Music_Stop (already stopped -> no-op)
    And no second 0FCh is ever transmitted (a Stop cannot beget a Stop)

  # --- The Shift-F1 gate ------------------------------------------------------
  @shipped @build-verified @runtime-untested
  Scenario: The toggle defaults ON and is flipped on the Shift-F1 MIDI screen
    # cite: IT_K.ASM MIDIStopOnF8Enable DB 1 (default ON)
    # cite: IT_OBJ1.ASM MIDIStopF8ToggleButton (index 26 on O1_MIDIScreen, row 49)
    #       -> Glbl_MIDIStopF8_Toggle (IT_K.ASM) which XORs the flag + SetInfoLine
    Given the Shift-F1 MIDI screen is open
    Then a "Toggle Send MIDI Stop (FC) on F8" button sits below the Multitimbral toggle
    And selecting it flips the flag and shows "Send MIDI Stop (FC) on F8: ON/OFF"

  @shipped @build-verified @hw-untested
  Scenario: With the toggle OFF, F8 behaves exactly like stock
    # cite: IT_G.ASM Glbl_F8 calls MIDI_F8StopEnabled; ZF=1 (OFF) jumps past the
    #       transmit straight to Music_Stop.
    Given the "Send MIDI Stop on F8" toggle is OFF
    When the user presses F8
    Then no MIDI byte is transmitted
    And playback stops via Music_Stop, identical to upstream behaviour

  # --- Persistence across restarts (IT.CFG ForkExtConfig +3) ------------------
  @shipped @build-verified @runtime-untested
  Scenario: The toggle survives an Impulse Tracker restart
    # cite: IT_DISK.ASM D_SaveDirectoryConfiguration stamps the live flag into
    #       PE_ForkExtConfig +3 (force-off sense, 0=ON) before D_SaveBlock writes
    #       the 16-byte block; D_InitDisk reads it back and calls MIDI_SetF8StopEnable.
    # cite: commit 222962f ; IT_PE.ASM MIDIStopOnF8PersistOff at block offset +3
    Given the user turns the toggle OFF and IT writes IT.CFG (any config save)
    When IT.EXE is quit and relaunched
    Then D_InitDisk reads block +3 and restores the toggle to OFF
    And turning it back ON and saving restores ON on the next launch

  @shipped @build-verified @runtime-untested
  Scenario: Old IT.CFG files (and fresh installs) default the toggle ON
    # cite: block +3 is FORCE-OFF: 0 -> ON. Pre-222962f IT.CFGs wrote that byte as
    #       a reserved zero; files with no block at all keep the static default 0.
    #       Both decode to ON, matching the in-code default MIDIStopOnF8Enable=1.
    Given an IT.CFG written before this feature (block +3 byte is zero or absent)
    When IT.EXE loads it at boot
    Then the "Send MIDI Stop on F8" toggle comes up ON (no surprise OFF)
