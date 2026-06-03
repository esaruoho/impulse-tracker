# =============================================================================
# WIKI PAGE / REPORT CARD: User Presses F4 (Instrument List)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/fkey-report-cards.session.md (the vibe diff that spawned this)
#
# Durable understanding-store for "what happens when the user presses F4".
# Plain F4 + Ctrl-F4 + the F4-cycles-tabs behaviour live here. The Shift-F4
# multitimbral batch-create and the live MIDI-In router are a SEPARATE card:
# see features/midi-in-multitimbral.feature. This card only notes where the
# per-instrument MIDI-In field is edited (the Pitch tab) and links across.
#
# Report-card legend (tags):
#   @stock          - upstream Impulse Tracker behaviour
#   @shipped        - fork addition, in origin/main
#   @build-verified - assembles + links clean (TASM 4.1 / TLINK 3.01)
#
# Source files linked back to this card:
#   IT_OBJ1.ASM  - GlobalKeyList F4 (3150) and Ctrl-F4 (3154) dispatch entries
#   IT_G.ASM     - Glbl_F4 / Glbl_F4_2 (384-422), Glbl_Ctrl_F4 (696-708)
#   IT_I.ASM     - I_SelectScreen tab cycle (871-889); InstrumentScreenTable (383)
#   IT_OBJ1.ASM  - O1_InstrumentList{General,Volume,Panning,Pitch};
#                  InstrumentMIDIInChannel field (6531, hdr byte 1Fh)
#
# Commit log (the ingest trail):
#   fb47b32  Import code (upstream base: F4 instrument list + tab cycle)
#   10c837b  per-instrument MIDI-In channel field (hdr 1Fh) on the Pitch tab
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : 10c837b  (direct to esaruoho/main, no PR)
#   This card authored: 8ca97e9 (cards) + 009dbab (session + back-links)
#   Triad: this .feature  <->  fkey-report-cards.session.md  <->  commit 10c837b
#          (live MIDI-In routing: see features/midi-in-multitimbral.feature)
#
# WATCH: Glbl_F4 Glbl_Ctrl_F4 I_SelectScreen InstrumentScreenTable InstrumentMIDIInChannel
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest line appended below)
#
# IT.TXT source of truth: lines 1816-1818 (Ctrl-F4 = Instrument library from anywhere).
# =============================================================================

Feature: User Presses F4 (Instrument List)
  As someone shaping instruments (envelopes, NNA, MIDI),
  I want F4 to open the instrument editor and repeated F4 to cycle its tabs,
  And Ctrl-F4 to reach the disk instrument library,
  So that all four envelope/MIDI tabs of an instrument are reachable from one key.

  @stock @build-verified
  Scenario: F4 opens the instrument editor
    # cite: IT_OBJ1.ASM:3150 GlobalKeyList F4 (scancode 13Eh) -> Glbl_F4
    # cite: IT_G.ASM:384 Glbl_F4 -> Glbl_SampleToInstrument (cursor map),
    #       I_MapEnvelope, CurrentMode=4, Object1 instrument list
    Given the user is on any screen
    When the user presses F4
    Then CurrentMode becomes 4 and the instrument editor opens
    And if the user was on the sample list, the cursor maps to the same slot
    And the tab shown is whichever InstrumentScreen was last active

  @stock @build-verified
  Scenario: Pressing F4 again cycles the instrument tabs
    # cite: IT_I.ASM:871 I_SelectScreen cycles 0..3 then redraws via Glbl_F4_2
    # cite: IT_I.ASM:383 InstrumentScreenTable -> General / Volume / Panning / Pitch
    Given the user is already in the instrument editor
    When the user presses F4
    Then the active tab advances General -> Volume -> Panning -> Pitch -> General
    And the matching O1_InstrumentList<tab> object is drawn

  @stock @build-verified
  Scenario: Ctrl-F4 opens the disk Instrument Library from anywhere
    # cite: IT_OBJ1.ASM:3154 GlobalKeyList Ctrl-F4 -> Glbl_Ctrl_F4
    # cite: IT_G.ASM:696 Glbl_Ctrl_F4 calls D_InitLoadInstruments, CurrentMode=15,
    #       returns O1_ViewInstrumentLibrary
    # cite: IT.TXT:1817 "The Instrument library is accesible on Ctrl-F4"
    Given the user is on any screen
    When the user presses Ctrl-F4
    Then CurrentMode becomes 15 and the disk instrument library browser opens

  @shipped @build-verified
  Scenario: The per-instrument MIDI-In Channel is edited on the Pitch tab
    # cite: IT_OBJ1.ASM:6531 InstrumentMIDIInChannel (type 14, hdr byte 1Fh, 0..17)
    # cite: commit 10c837b
    # NOTE: live routing of those channels is a separate card ->
    #       features/midi-in-multitimbral.feature
    Given the user is on the instrument editor Pitch tab
    Then a "MIDI In Channel" field stores 0..17 at instrument header byte 1Fh
    And 0 = off, 1..16 = that channel, 17 = All/Omni
    And what those values DO live is documented in midi-in-multitimbral.feature
