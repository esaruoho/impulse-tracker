# Pure Gherkin test extracted from features/no-samples-to-instruments-envelope-retention.feature
# (report-card banner stripped; inline # cite: traceability kept)
# Regenerate: python3 features/print-card.py features/no-samples-to-instruments-envelope-retention.feature

Feature: F12 Samples->Instruments uses upstream clear+remap (no envelope retention)
  As someone who needs a NON-CRASHING tracker above all,
  I want F12 "Initialise Instruments? = YES" to do exactly what upstream IT2.15
  does -- clear all instruments and rebuild a clean sample-name + 120-note keymap --
  with NO attempt to preserve drawn envelopes across the flip,
  So that nothing in the load/convert path can ever feed garbage instrument
  slots to the envelope renderer and hard-crash IT (EMM386 #12).

  @stock @build-verified @runtime-untested
  Scenario: Initialise Instruments = YES does the upstream clear + remap
    # cite: IT_F.ASM:4831 F_SetControlInstrument; ~4852 Call Music_ClearAllInstruments
    #       then loop 0..99: if sample exists, copy name (CX=26) + fill 120-note keymap
    # cite: commit b5a0c66 (the behaviour this reinstates)
    Given the user presses F12 and answers YES to "Initialise Instruments?"
    When the conversion runs
    Then all instrument slots are cleared unconditionally
    And every slot with a matching sample gets a clean name + 120-note keymap
    And NO per-slot envelope-preserve / IMPI check runs

  @removed @build-verified
  Scenario: The envelope-retention feature and its IMPI checker are gone
    # cite: IT_MUSIC.ASM:4025 Music_InstrumentIsReal tombstone (proc deleted)
    # cite: IT_F.ASM F_SetControlInstrument no longer references IsReal/ClearInstrument
    Given the source tree after this commit
    When you grep for Music_InstrumentIsReal or a per-slot envelope-preserve loop
    Then the helper proc is absent (only a tombstone remains)
    And F_SetControlInstrument contains no envelope-retention branch

  @removed @build-verified
  Scenario: Shift-Enter bulk-load can no longer feed the crash class
    # The EMM386 #12 crash needed garbage instrument slots (left by Shift-Enter
    # bulk-load and sample-only loads) to survive into the envelope renderer via
    # the keep-envelopes path. With that path gone, F12 always clears first.
    # cite: commit b5a0c66 rationale; IT_DISK.ASM LSWindow_ShiftEnter leaves the
    #       loaders decoupled from instrument init again.
    Given instrument slots hold uninitialised garbage after a Shift-Enter bulk-load
    When the user runs F12 Initialise Instruments = YES
    Then those slots are cleared to a valid template by Music_ClearAllInstruments
    And no non-IMPI garbage can reach I_MapEnvelope through a preserve branch

  @stock @build-verified
  Scenario: The I_MapEnvelope MaxNode<=25 clamp stays as defensive insurance
    # cite: IT_I.ASM I_MapEnvelope clamp (commit ed10913) -- KEPT on purpose,
    #       independent of this feature; bounds the envelope node loop regardless.
    Given any instrument reaches the envelope renderer
    When I_MapEnvelope walks its node list
    Then the node count is clamped to <= 25 so the loop cannot run wild

  @todo
  Scenario: (guardrail) Do not re-introduce envelope retention without HW verify
    # The EMM386 #12 crash CANNOT be reproduced under DOSBox-X. Any future attempt
    # to bring back keep-envelopes MUST be verified on real DOS+EMM386 first:
    # bulk-load a module via Shift-Enter, then F12 YES, confirm no crash.
    Given a future proposal to retain envelopes across the flip
    When it is considered
    Then it stays out unless verified on real EMM386 hardware (Esa's standing rule)
