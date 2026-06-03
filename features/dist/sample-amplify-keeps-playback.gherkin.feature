# Pure Gherkin test extracted from features/sample-amplify-keeps-playback.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/sample-amplify-keeps-playback.feature

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
