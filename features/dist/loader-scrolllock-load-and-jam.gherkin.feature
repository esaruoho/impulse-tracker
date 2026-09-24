# Pure Gherkin test extracted from features/loader-scrolllock-load-and-jam.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/loader-scrolllock-load-and-jam.feature

Feature: Scroll Lock in the loader loads the sample and drops me into the editor
  As someone auditioning samples in the loader, I want one key that loads the
  highlighted sample, makes it an instrument, and puts me in the Pattern Editor,
  So that I can go from "found a sound" to "jamming with it" without a detour.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Scroll Lock loads the sample, makes an instrument, and enters the editor
    # cite: IT_DISK.ASM LSViewWindow_ScrollLock ; commit 8f6a5cd
    Given the Load-Sample view is open with a sample highlighted
    When I press Scroll Lock
    Then the highlighted sample is loaded into the current sample slot
    And Instrument mode is forced on (bit 2 of [songseg:2Ch])
    And an instrument is created for that sample and selected as current
    And the Pattern Editor opens with Follow Mode on, ready to jam

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loader jump keys do not disturb the loader's core tools
    # cite: IT_DISK.ASM LSViewWindowKeys 146h/13Ah entries (added before the 0FFh terminator)
    Given the loader keyjazz, Enter, and cursor keys work as before
    When the Scroll Lock and Caps Lock entries are added to LSViewWindowKeys
    Then keyjazz, Enter (LSViewWindow_Enter) and Up/Down are byte-for-byte unchanged
    And only the jump-to-editor loader shortcuts gain behaviour in this window

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Scroll Lock in the editor toggles Follow
    # cite: IT_PE.ASM PE_ScrollLockDispatch falls through to PE_ScrollLockFollow
    #       when Shift is not held; PE_ScrollLockFollow PE_SLF_InEditor toggles.
    Given I am in the Pattern Editor
    When I press Scroll Lock
    Then Follow Mode toggles exactly as before (no round-trip)
    And Ctrl-F toggles Follow Mode regardless of how I got here

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Shift-Scroll Lock in the editor always reopens Sample Load
    # cite: IT_PE.ASM pattern-editor Scroll Lock rows -> PE_ScrollLockDispatch,
    #       which checks live K_IsKeyDown(2Ah/36h) so Shift-Scroll Lock survives
    #       keyboards/BIOSes that normalize the Scroll Lock key word.
    # cite: IT_PE.ASM PE_ScrollLockLoadSample tail-jumps to Glbl_LoadSample.
    Given I am in the Pattern Editor
    When I press Shift-Scroll Lock
    Then the Sample Load view opens
    And plain Scroll Lock keeps its existing Follow-toggle behavior

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Shift-F3 opens Sample Load directly
    # cite: IT_OBJ1.ASM GlobalKeyList Shift-F3 row -> Glbl_LoadSample.
    Given I am on a screen that chains to GlobalKeyList
    When I press Shift-F3
    Then the Sample Load view opens directly
    And it does not merely stop at the Sample List

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Pattern Editor fallback keys open Sample Load directly
    # cite: IT_PE.ASM pattern-editor keylist Caps Lock / Pause rows
    #       -> PE_ScrollLockLoadSample -> Glbl_LoadSample.
    Given I am in the Pattern Editor
    When I press Caps Lock or Pause/Break
    Then the Sample Load view opens directly

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Caps Lock in Sample Load loads and jams
    # cite: IT_PE.ASM PE_CapsLoadSample sets PE_CapsRoundTrip and latches the
    #       destination slot; IT_DISK.ASM LSViewWindow_CapsLock preserves it and
    #       LSViewWindow_LoadAndReturn consumes it, returning through Glbl_F2
    #       without changing TracePlayback.
    Given I opened Sample Load from the Pattern Editor with Caps Lock
    And a sample is highlighted in Sample Load
    When I press Caps Lock again
    Then the highlighted sample is loaded
    And the instrument binding path runs
    And the Pattern Editor opens without changing Follow Mode

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Caps Lock loading keeps its destination while playback advances
    # cite: IT_PE.ASM PE_CapsLoadSample captures PE_GetLastInstrument before
    #       opening Sample Load; IT_DISK.ASM reuses that slot even if playback
    #       changes LastInstrument while the loader is open.
    Given playback is advancing the song order
    When I use Caps Lock to open Sample Load and Caps Lock to load a sample
    Then the sample is loaded into the destination slot captured on entry
    And its instrument binding uses that same destination slot

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loader instrument creation never falls back to another number
    # cite: IT_MUSIC.ASM Music_AssignSampleToInstrumentExact refuses the
    #       first-free-instrument fallback; IT_DISK.ASM uses it for loader
    #       loads and Samples Mode backfill.
    Given sample N is being loaded
    And instrument N is occupied by a different sample
    When the loader creates the instrument binding
    Then it does not overwrite instrument N
    And it does not bind sample N to an unrelated first-free instrument

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Loader allocates the first unused matching sample/instrument pair
    # cite: IT_MUSIC.ASM Music_FindFreeMatchingSlot scans sample and instrument
    #       occupancy together; IT_DISK.ASM LSViewWindow_LoadAndReturn uses its
    #       zero-based result for LoadSample and exact instrument assignment.
    Given samples and instruments 1 through 15 are already in use as matching pairs
    When I load another sample with Caps Lock or Scroll Lock
    Then it is loaded into sample 16
    And instrument 16 is created and selected
    And instrument 16 triggers sample 16

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Sample Loader Scroll Lock returns with Follow Mode on
    # cite: IT_DISK.ASM LSViewWindow_ScrollLock clears any Caps round-trip
    #       latch before LSViewWindow_LoadAndReturn; that path tail-jumps to
    #       PE_ScrollLockFollow, which forces TracePlayback on.
    Given I am in Sample Load without a Caps Lock round-trip latch
    And a sample is highlighted in Sample Load
    When I press Scroll Lock
    Then the Pattern Editor opens with Follow Mode on

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: If the instrument assign fails, it still drops me in to jam on the sample
    # cite: IT_DISK.ASM LSViewWindow_ScrollLock JC LSVSL_Go on Music_AssignSampleToInstrument ; commit 8f6a5cd
    Given the sample loaded but no instrument slot could be assigned
    When Music_AssignSampleToInstrument returns carry
    Then the macro skips the select step
    And still jumps to the Pattern Editor with Follow Mode on

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Samples Mode songs get instrument backfill before Scroll Lock jams
    # cite: IT_DISK.ASM LSViewWindow_ScrollLock checks Music_GetInstrumentMode
    #       before forcing bit 2 of [songseg:2Ch].
    # cite: IT_DISK.ASM LSVSL_BackfillInstruments scans loaded sample headers
    #       and calls Music_AssignSampleToInstrument for each existing sample
    #       before the newly highlighted sample is assigned.
    Given a song is in Samples Mode
    And sample 1 is already loaded and used by a pattern hihat
    When I press Scroll Lock in the sample loader to load another sample
    Then Instrument mode is enabled
    And the pre-existing loaded samples receive matching instruments
    And the newly loaded sample still receives and selects its own instrument
