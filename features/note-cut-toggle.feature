# =============================================================================
# WIKI PAGE / REPORT CARD: '1' toggles the note cut (^^^) under the cursor
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/note-cut-toggle.session.md
#
# Durable understanding-store for the fork change that makes the note-column '1'
# key a TOGGLE: pressing it stamps a note cut (^^^, 0FEh) as in stock IT, but
# pressing it again on a cell that already holds a note cut wipes the cell (the
# same erase '.' performs). One verifiable claim per Scenario, cited to proc +
# line + commit; tags are the report-card grade.
#
# WHAT THIS CARD SPAWNS (the card is a generative SEED):
#   - CODESPACE  : this .feature + the .session.md sibling, PLUS the innards --
#                  NoteCutToggle in IT_PE.ASM and the two PE_PatternCursorPos0_3
#                  dispatch edits ('1'/'!' -> NoteCutToggle instead of WipeNote).
#   - THINKSPACE : the .session.md -- WHY the check reads [ES:DI] (the cursor's
#                  note byte, the same pointer WipeNote writes), and why routing
#                  the wipe through WipeNote/EditMask matches '.' semantics.
#   - AREASPACE  : OWNS the '1'/'!' note-cut entry on the note column. MUST NOT
#                  change '.' erase, note-off ('`'/'~' -> 0FFh), the keyjazz
#                  preview path, or WipeNote's edit-mask handling.
#
# Report-card legend (tags):
#   @shipped          - in esaruoho/main
#   @build-verified   - assembles + links clean (TASM 4.1 / TLINK 3.01);
#                       IT_PE.asm Error/Warning = None, IT.EXE links (477112 bytes)
#   @runtime-untested - NOT yet exercised on a running IT.EXE
#   @hw-untested      - NOT run on real DOS hardware (DOSBox-X is emulation)
#   @stock            - upstream Impulse Tracker behaviour, not a fork addition
#
# Source files linked back to this card (grep "features/note-cut-toggle"):
#   IT_PE.ASM  PE_PatternCursorPos0_3 (~5495): '1'/'!' -> NoteCutToggle
#   IT_PE.ASM  NoteCutToggle (~5600): Cmp [ES:DI],0FEh -> WipeNote, else AL=NONOTE
#   IT_PE.ASM  WipeNote (~5534): the shared writer (note <- AL, rest per EditMask)
#
# Commit log (the ingest trail):
#   81e4819  '1' on a note cut toggles it off (NoteCutToggle)
#
# RESULT (triad: .feature spec + .session convo + what shipped):
#   Feature delivery : 81e4819 (direct to esaruoho/main, no PR)
#   Build            : dosbox-x -conf buildall.conf 2026-06-04 12:10 EEST;
#                      IT_PE.asm Error/Warning None; tlink 3.01 linked;
#                      IT.EXE 477112 bytes.
#   Triad: this .feature <-> note-cut-toggle.session.md <-> commit 81e4819
#
# WATCH: NoteCutToggle WipeNote PE_PatternCursorPos0
# RESULT-LOG >> (auto-maintained by .githooks/pre-commit / post-merge)
#
# IT.TXT source of truth: IT.TXT:486 -- "Pressing '1' on the note column will
#   enter a notecut command." The second-press wipe is a fork extension.
# =============================================================================

Feature: '1' toggles the note cut under the cursor
  As someone editing a pattern,
  I want pressing '1' on a cell that already shows ^^^ to clear it,
  So that the same key both places and removes a note cut without reaching for '.'.

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: First '1' on an empty (or noted) cell stamps a note cut
    # cite: IT_PE.ASM PE_PatternCursorPos0_3 (~5495) '1'/'!' -> NoteCutToggle ; commit 81e4819
    # cite: IT_PE.ASM NoteCutToggle (~5600): [ES:DI] != 0FEh -> JNE WipeNote with AL=0FEh
    Given the cursor is on a note cell that does NOT already hold a note cut
    When the user presses '1' (or Shift-'1' = '!')
    Then a note cut (^^^, 0FEh) is written into that cell
    And behaviour is identical to stock IT (cursor advances per the cursor step)

  @shipped @build-verified @runtime-untested @hw-untested
  Scenario: Second '1' on a note-cut cell wipes it
    # cite: IT_PE.ASM NoteCutToggle (~5600): [ES:DI] == 0FEh -> AL=NONOTE, Jmp WipeNote
    # cite: IT_PE.ASM WipeNote (~5534): writes AL into the note byte, clears the
    #       rest of the event per EditMask -- the same path '.' takes
    Given the cursor is on a note cell that already holds a note cut (^^^)
    When the user presses '1' (or '!')
    Then the cell is erased exactly as pressing '.' would (note <- NONOTE, columns
         per the edit mask)
    And no second ^^^ is stamped

  @stock @build-verified @hw-untested
  Scenario: Note-off and '.' are unchanged
    # cite: IT_PE.ASM PE_PatternCursorPos0_3: '`'/'~' still -> WipeNote with AL=0FFh,
    #       '.' still -> WipeNote with AL=NONOTE (neither routes through NoteCutToggle)
    Given the cursor is on any note cell
    When the user presses '`' / '~' (note-off) or '.' (erase)
    Then those keys behave exactly as in stock IT (note-off stamps ===, '.' erases)
