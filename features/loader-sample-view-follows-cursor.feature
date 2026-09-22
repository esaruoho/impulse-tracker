# =============================================================================
# WIKI PAGE / REPORT CARD: The loader's waveform view follows the cursor
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# The Load-Sample-from-module/library window draws a waveform of the highlighted
# sample. Upstream only refreshed it when you PREVIEWED (pressed a note key), so
# arrowing sample-to-sample left the old waveform on screen. This card makes the
# waveform repaint the instant the selection changes.
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE: this .feature + .session.md, PLUS LSWindow_PreviewCurrent and the
#                six cursor-move handlers that call it (Up/Down/PgUp/PgDn/Home/End).
#   - THINKSPACE: the .session.md -- why we reuse the keyjazz preview path
#                (slot 99 load -> D_DrawWaveForm off slot 100), the SampleInMemory
#                guard that makes it a no-op when nothing changed, and the MIDI
#                loader-suppress bracket carried over from the keyjazz-hang fix.
#   - AREASPACE: OWNS the loader selection->waveform refresh; must NOT touch the
#                keyjazz note-play path, the actual sample load-into-song (Enter),
#                or song playback.
#
# Report-card legend (tags): @stock @shipped @build-verified @runtime-verified
#                            @runtime-untested @hw-untested @todo
# Source files linked back to this card (grep "features/loader-sample-view-follows-cursor"):
#   IT_DISK.ASM - LSWindow_PreviewCurrent (helper: load slot 99, draw waveform)
#   IT_DISK.ASM - LSWindow_Up/Down/PgUp/PgDn/Home/End (call the helper on move)
# Commit log:   <stamped by hook>
# SESSION:      features/loader-sample-view-follows-cursor.session.md
# RESULT:       <stamped by hook>
# WATCH: LSWindow_PreviewCurrent LSWindow_Up LSWindow_Down LSWindow_PgUp LSWindow_PgDn LSWindow_Home LSWindow_End
# =============================================================================

Feature: The load-sample waveform view follows the highlighted sample
  As someone browsing samples in the loader, I want the waveform to update as I
  move the cursor, So that I can see each sample without having to play a note.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Moving to another sample repaints the waveform
    # cite: IT_DISK.ASM LSWindow_Down (~line 8400) Call LSWindow_PreviewCurrent ; commit 614f689
    Given the Load-Sample-from-library window is open on a module with several samples
    When I press Down (or Up/PgUp/PgDn/Home/End) to change the highlighted sample
    Then that sample is loaded into the preview slot (99)
    And D_DrawWaveForm repaints the waveform of the newly selected sample
    And no note has to be played first

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: A cursor key that does not change the selection costs nothing
    # cite: IT_DISK.ASM LSWindow_PreviewCurrent (helper) CurrentSample vs SampleInMemory ; commit 614f689
    Given the cursor is already on the first sample
    When I press Up (a no-op at the top of the list)
    Then LSWindow_PreviewCurrent sees CurrentSample == SampleInMemory
    And it returns without reloading or repainting

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: The auto-preview keeps the keyjazz-hang protection
    # cite: IT_DISK.ASM LSWindow_PreviewCurrent (helper) MIDI loader-suppress bracket ; commit 614f689
    Given a song is playing while I browse samples in the loader
    When the waveform auto-loads on a cursor move
    Then the load runs inside MIDI_SetLoaderSuppress / MIDI_ClearLoaderSuppress
    And an FA/FC arriving mid-load cannot restart playback into the half-written slot
    And only the preview voice is affected, the song keeps playing
