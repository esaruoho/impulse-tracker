# =============================================================================
# WIKI PAGE / REPORT CARD: Scroll Lock in the sample loader = load + make
#                          instrument + jump to the Pattern Editor to jam
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# In the Load-Sample view, pressing Scroll Lock on the highlighted sample does
# the whole "audition it for real" chain in one key: load the sample into the
# song, force Instrument mode, create + select an instrument for it, then open
# the Pattern Editor with Follow Mode on so you can start jamming immediately.
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE: this .feature + .session.md, the LSViewWindow_ScrollLock proc,
#                the 146h entry in LSViewWindowKeys, and the two new Extrns
#                (PE_ScrollLockFollow, PE_SetLastInstrument) in IT_DISK.ASM.
#   - THINKSPACE: the .session.md -- why it's a NEW key (contained risk, keyjazz
#                untouched) composed only from proven blocks (LSWindow_EnterSample
#                load path, the WAV-import assign+select block, PE_ScrollLockFollow).
#   - AREASPACE: OWNS the Scroll-Lock gesture in the sample-view window; must NOT
#                touch keyjazz, Enter, or the cursor keys.
#
# Report-card legend (tags): @stock @shipped @build-verified @runtime-verified
#                            @runtime-untested @hw-untested @todo
# Source files linked back to this card (grep "features/loader-scrolllock-load-and-jam"):
#   IT_DISK.ASM - LSViewWindow_ScrollLock (the handler)
#   IT_DISK.ASM - LSViewWindowKeys (146h entry)
# Commit log:   <stamped by hook>
# SESSION:      features/loader-scrolllock-load-and-jam.session.md
# RESULT:       <stamped by hook>
# WATCH: LSViewWindow_ScrollLock
# =============================================================================

Feature: Scroll Lock in the loader loads the sample and drops me into the editor
  As someone auditioning samples in the loader, I want one key that loads the
  highlighted sample, makes it an instrument, and puts me in the Pattern Editor,
  So that I can go from "found a sound" to "jamming with it" without a detour.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Scroll Lock loads the sample, makes an instrument, and enters the editor
    # cite: IT_DISK.ASM LSViewWindow_ScrollLock ; commit <hash>
    Given the Load-Sample view is open with a sample highlighted
    When I press Scroll Lock
    Then the highlighted sample is loaded into the current sample slot
    And Instrument mode is forced on (bit 2 of [songseg:2Ch])
    And an instrument is created for that sample and selected as current
    And the Pattern Editor opens with Follow Mode on, ready to jam

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: It is a new key and does not disturb the loader's core tools
    # cite: IT_DISK.ASM LSViewWindowKeys 146h entry (added before the 0FFh terminator) ; commit <hash>
    Given the loader keyjazz, Enter, and cursor keys work as before
    When the Scroll Lock entry is added to LSViewWindowKeys
    Then keyjazz, Enter (LSViewWindow_Enter) and Up/Down are byte-for-byte unchanged
    And only the previously-unbound Scroll Lock gains behaviour in this window

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: If the instrument assign fails, it still drops me in to jam on the sample
    # cite: IT_DISK.ASM LSViewWindow_ScrollLock JC LSVSL_Go on Music_AssignSampleToInstrument ; commit <hash>
    Given the sample loaded but no instrument slot could be assigned
    When Music_AssignSampleToInstrument returns carry
    Then the macro skips the select step
    And still jumps to the Pattern Editor with Follow Mode on
