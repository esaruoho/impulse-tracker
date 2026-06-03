# =============================================================================
# WIKI PAGE / REPORT CARD: Sample Amplify keeps the song playing
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
#
# This .feature is the durable understanding-store AND the session command for
# the fork change that makes Sample Amplification (Alt-M) NOT stop pattern
# playback. Each Scenario is a verified claim about behaviour, cited to its
# source proc and the commit that shipped it. Tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (the card is a generative SEED, not a description):
#   - CODESPACE  (the file structure): this .feature + the .session.md sibling,
#                PLUS the innards in "Source files" below -- the one-line swap in
#                I_AmplifySample (Music_Stop -> Music_SilenceSampleVoices) and
#                the Extrn that makes it link.
#   - THINKSPACE (the reasoning / vibe): the .session.md -- WHY silencing only
#                the affected sample's voices is safe while rewriting PCM in
#                place, and why this is the same pattern as the loader fix.
#   - AREASPACE  (the domain boundary): what this OWNS (the amplify-apply
#                playback handling) and what it must NOT touch (the peak scan,
#                the scaling/clip math, other Music_Stop call sites in IT_I).
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_I.asm Error/Warning = None, IT.EXE links
#   @runtime-untested - NOT yet exercised by running IT.EXE: start a song, press
#                       Alt-M on a playing sample, confirm OK amplifies the
#                       sample AND the song keeps playing. Runnable in DOSBox-X.
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/sample-amplify-keeps-playback"):
#   IT_I.ASM  - I_AmplifySample apply path: Music_SilenceSampleVoices swap
#               (~line 4010) + the Extrn Music_SilenceSampleVoices import
#   IT_I.ASM  - I_AmplifySample15 EXIT (~line 4103): reload ONLY this slot via
#               Music_SoundCardLoadSample, NOT Music_SoundCardLoadAllSamples
#   IT_MUSIC.ASM - Music_SilenceSampleVoices (9284): sets [SI]=200h only on
#               slaves whose [SI+36h] == AL (target slot); PushA/PopA preserves AX
#   IT_MUSIC.ASM - Music_SoundCardLoadAllSamples (10458) CALLS Music_Stop +
#               ResetSoundCardMemory (the song-killer); Music_SoundCardLoadSample
#               (10436) reloads one slot and does NEITHER
#   IT_OBJ1.ASM - sample-list keylist: Alt-M (3200h) -> I_AmplifySample (3471)
#
# Commit log (the ingest trail):
#   e5e5c38  Sample Amplify (Alt-M) no longer stops the song (entry: Music_Stop
#            -> Music_SilenceSampleVoices) -- INCOMPLETE: exit still stopped it
#   (this commit) complete the fix: exit reloads ONLY this sample, not all
#
# SESSION (the vibe record -- the conversation that spawned this card):
#   features/sample-amplify-keeps-playback.session.md
#   The card is incomplete without it. The session is the vibe-diff unit:
#   future versions diff the dialogue (requests, refinements, corrections),
#   not just the code and the card.
#
# RESULT (third leg of the triad: .feature spec + .session convo + what shipped):
#   Feature delivery : e5e5c38 direct to esaruoho/main, no PR
#   This card authored: the card+session commit that follows e5e5c38
#   Triad: this .feature  <->  sample-amplify-keeps-playback.session.md  <->  e5e5c38
#
# WATCH: I_AmplifySample Music_SilenceSampleVoices Music_Stop Music_GetSampleLocation Music_SoundCardLoadSample Music_SoundCardLoadAllSamples
#
# Sibling: features/loader-keyjazz-hang.feature (same Music_SilenceSampleVoices
# pattern, applied to the F3 sample loader). "Don't stop the song to touch one
# sample" is the shared principle.
# =============================================================================

Feature: Sample Amplify keeps the song playing
  As a musician tweaking a sample's level while a tune is running,
  I want pressing Alt-M (Amplify / normalize) and confirming it to scale the
  sample WITHOUT stopping playback,
  So that I can hear the change in context and keep my flow, instead of the
  whole song cutting out every time I amplify a sample.

  # --- The user-visible behaviour --------------------------------------------

  @shipped @build-verified @runtime-untested
  Scenario: Amplifying a sample mid-playback does not stop the song
    # cite: IT_I.ASM I_AmplifySample apply path (~3997): Music_Stop replaced by
    #       Music_SilenceSampleVoices (AL = sample slot, 1..99)
    # cite: commit e5e5c38
    Given a song is playing
    And the user is on the Sample List with a sample selected
    When the user presses Alt-M and confirms the amplification dialog
    Then the sample is amplified (scaled in place, clipped)
    And the song keeps playing -- only voices using THIS sample fall silent

  @shipped @build-verified @runtime-untested
  Scenario: Alt-M Maximize/Normalize during playback keeps playing through OK/Process
    # The user-journey form (Esa's wantlist phrasing). "Amplify" IS IT's
    # Maximize/Normalize: the peak-scan pre-fills the no-clip slider value (see
    # the "no-clip (normalize) amplification" scenario below), so the default
    # slider amount maximises without clipping. The whole flow -- slider adjust
    # then Process -- no longer halts transport, for a pattern OR a full song.
    # cite: IT_I.ASM I_AmplifySample10 runs the O1_SampleAmplificationList
    #       dialog; on Process (DX != 0) the apply path silences only this
    #       sample's voices (Music_SilenceSampleVoices) instead of Music_Stop
    # cite: commit e5e5c38
    Given the user is playing a pattern or a song
    When they press Alt-M to Maximize/Normalize a sample
    And they set the slider amount and press OK/Process
    Then the sample is scaled by that amount
    And the playback does not stop

  @bug @fixed-pending-verify
  Scenario: REGRESSION (reported 2026-06-03) - Alt-M still stopped F6 playback
    # Reported by Esa: "playback on (F6), i hit alt-M on a sample, and the
    # playback stopped." The e5e5c38 fix swapped the ENTRY Music_Stop for
    # Music_SilenceSampleVoices, but the apply path's EXIT still called
    # Music_SoundCardLoadAllSamples to re-upload samples -- and THAT proc calls
    # Music_Stop + ResetSoundCardMemory unconditionally, killing the song. So the
    # "keeps playing" claim was never actually delivered; only this commit makes
    # it true.
    # cite: IT_MUSIC.ASM:10463 Music_SoundCardLoadAllSamples -> Call Music_Stop
    # cite: IT_I.ASM:4103 I_AmplifySample15 now reloads ONLY this slot:
    #       PE_GetLastInstrument -> AX=slot+1 -> Music_SoundCardLoadSample
    # cite: IT_MUSIC.ASM:10436 Music_SoundCardLoadSample has no Music_Stop/reset
    Given a song is playing (F6) on the Sample List
    When the user presses Alt-M, sets the amount, and confirms
    Then ONLY this sample is re-uploaded to the sound card (no Music_Stop)
    And the song keeps playing
    # @fixed-pending-verify: build-verified; not yet confirmed on a running IT.EXE

  # --- The trigger -----------------------------------------------------------

  @stock @build-verified
  Scenario: Alt-M on the Sample List is the Amplify gesture
    # cite: IT_OBJ1.ASM:3471 sample-list keylist DW 3200h (Alt-'M', scancode
    #       32h) -> DD I_AmplifySample ; not documented in IT.TXT, code is truth
    Given the Sample List (F3) with a sample selected
    When the user presses Alt-M
    Then I_AmplifySample runs: peak-scan, then the amplification dialog

  @stock @build-verified
  Scenario: The dialog pre-fills the no-clip (normalize) amplification
    # cite: IT_I.ASM I_AmplifySample10: Amplification = (8000h/MaxDev)*100,
    #       clamped to 400% max -- i.e. the largest gain that won't clip = the
    #       "normalize" value the user sees by default
    Given the peak scan found the sample's max deviation from mean
    When the dialog opens
    Then it pre-fills the percentage that scales the peak to full-scale
    And that default is why users call Amplify "Normalize"

  # --- Why it is safe --------------------------------------------------------

  @shipped @build-verified
  Scenario: Only the amplified sample's voices are silenced, not all channels
    # cite: IT_MUSIC.ASM Music_SilenceSampleVoices (9284): walks the slave table,
    #       sets [SI]=200h ONLY where [SI+36h]==AL; every other voice untouched
    Given several channels are sounding different samples
    When the user amplifies one of those samples
    Then the mixer marks only that sample's slave voices voice-off (200h)
    And channels playing other samples are unaffected

  @shipped @build-verified
  Scenario: The mixer never reads the sample while it is being rewritten
    # cite: the silence happens BEFORE the in-place scaling loop; a voice marked
    #       200h is skipped by the mixer (Test [SI],1), so no half-scaled PCM is
    #       read. New hits on the slot after amplify allocate a fresh slave.
    Given the amplify apply loop rewrites the sample's PCM in place
    When the mixer runs during that rewrite
    Then it skips the silenced voices and reads no partially-scaled data

  # --- Boundary --------------------------------------------------------------

  @shipped @build-verified
  Scenario: AX (the sample number) survives the silence call
    # cite: Music_SilenceSampleVoices is wrapped PushA..PopA, so AX is intact for
    #       the Music_GetSampleLocation call immediately after -- the reason this
    #       is a true drop-in for Music_Stop at this site
    Given the apply path needs the sample number after silencing
    When Music_SilenceSampleVoices returns
    Then AX still holds the sample number for Music_GetSampleLocation

  @stock @build-verified
  Scenario: Other Sample-List operations that still stop the song are untouched
    # cite: IT_I.ASM has ~16 other Music_Stop call sites (cut, resize, convert,
    #       etc.); this change touches ONLY the amplify apply path
    Given a destructive op other than Amplify (e.g. cut, resize)
    When the user runs it
    Then its existing stop-the-song behaviour is unchanged by this feature
