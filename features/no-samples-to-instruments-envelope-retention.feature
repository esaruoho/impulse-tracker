# =============================================================================
# WIKI PAGE / REPORT CARD: F12 Samples->Instruments is upstream clear+remap
#                          (envelope-retention DELIBERATELY REMOVED)
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/no-samples-to-instruments-envelope-retention.session.md
#
# This card exists to make a REMOVAL durable. The "keep drawn envelopes across
# the Samples->Instruments flip" feature has now been added, reverted (PR #2),
# re-added (PR #3), and reverted AGAIN (this commit). It is the brittlest thing
# in the tree and the EMM386 #12 hard-crash class. Esa's standing instruction:
# F12 "Initialise Instruments? = YES" stays at UPSTREAM behaviour (unconditional
# Music_ClearAllInstruments + clean 0..99 remap). Do NOT re-introduce envelope
# retention without real-hardware EMM386 verification.
#
# WHAT THIS CARD SPAWNS (generative seed)
#   Codespace : F_SetControlInstrument (IT_F.ASM) = upstream clear+remap.
#               Music_InstrumentIsReal (IT_MUSIC.ASM) DELETED (tombstone at 4025).
#   Thinkspace: the .session.md (PR#2/PR#3 history, why removed for good).
#   Areaspace : OWNS the F12 Samples->Instruments conversion policy. MUST NOT
#               re-add per-slot envelope-preserve / IMPI-gated-clear logic, and
#               MUST NOT re-couple instrument init to the loaders.
#
# Report-card legend (tags):
#   @stock            - upstream Impulse Tracker 2.15 behaviour
#   @removed          - a fork feature deliberately taken back OUT
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01)
#   @runtime-untested - not yet exercised against a running IT.EXE
#
# Source files linked back to this card:
#   IT_F.ASM     - F_SetControlInstrument (4831): upstream Music_ClearAllInstruments
#                  (call ~4852) + 0..99 sample-name/120-note-keymap remap. Dialog
#                  focus restored to CX=3 (OK button) per PR #2.
#   IT_MUSIC.ASM - Music_InstrumentIsReal REMOVED; tombstone at 4025. The
#                  InstrumentHeader "IMPI" template magic stays for normal init.
#   IT_I.ASM     - I_MapEnvelope MaxNode<=25 clamp KEPT (defensive insurance,
#                  independent of this feature; do not remove).
#
# Commit log (the ingest trail):
#   d8ec842  (added) F12 Samples->Instruments preserves drawn envelopes
#   b5a0c66  (PR #2, removed) revert envelope preservation -> upstream clear+remap
#   c2094e6 a44a607 9a1142c  (PR #3, re-added) IMPI-gated keep-envelopes policy
#   (this commit) reinstate PR #2's removal as the de-facto behaviour
#
# RESULT (third leg of the triad):
#   Delivery : this commit (direct to esaruoho/main). IT_F.ASM restored to
#              b5a0c66 (git checkout b5a0c66 -- IT_F.ASM; only PR #3 had touched
#              it since); Music_InstrumentIsReal surgically removed from
#              IT_MUSIC.ASM (which had unrelated commits since, so no whole-file
#              revert).
#   Build    : full BUILDALL via dosbox-x -conf buildall.conf 2026-06-03 21:38
#              EEST. IT_F.asm + IT_MUSIC.asm "Error/Warning: None"; tlink 3.01
#              linked (no undefined symbol -> IsReal had no other caller).
#   Triad: this .feature <-> ...session.md <-> commit
#
# WATCH: F_SetControlInstrument Music_InstrumentIsReal Music_ClearAllInstruments
# RESULT-LOG >> (auto-maintained by .githooks/post-merge)
#   2026-06-03  direct-commit  touched: F_SetControlInstrument
#   2026-06-03  direct-commit  touched: F_SetControlInstrument Music_InstrumentIsReal Music_ClearAllInstruments
#
# IT.TXT source of truth: F12 Initialise Instruments is documented stock IT.
# =============================================================================

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
