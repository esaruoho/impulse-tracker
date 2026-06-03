# =============================================================================
# WIKI PAGE / REPORT CARD: What happens when a SESSION changes a CODESPACE
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/session-changes-codespace.session.md (the convo that spawned this)
#
# This is the META card: the unit it describes is the PROCESS itself -- how a
# session (a conversation) changes a codespace (this git repo) and, in the same
# motion, leaves behind the durable, graded, two-way-linked, session-backed,
# git-rebuildable, self-seeding record of that change. It is the report card OF
# the report-card process. The other features/*.feature files are its instances.
#
# WHAT THIS CARD SPAWNS (the card comes first; the rest flows out of it):
#   - CODESPACE  = the file structure of the process: the governing rule, the
#                  skill, the schema, the hook, and the features/ triads it
#                  produces (see "Innards" below). From this you can stand the
#                  whole process up in a fresh repo.
#   - THINKSPACE = the .session sibling -- why the process is shaped this way,
#                  including the breach that added the session leg and the
#                  false-positive that re-grounded a grade.
#   - AREASPACE  = the process OWNS: how a change is recorded. It does NOT own
#                  the change's correctness (that's each unit's own card), and
#                  it must NOT silently grade unverified things up.
#
# Report-card legend (tags) -- process skin:
#   @rule-active        - mandated by an active rule (~/.claude/CLAUDE.md)
#   @shipped            - the machinery is committed to origin/main
#   @demonstrated       - OBSERVED to happen this session, with cited evidence
#   @wired-untriggered  - present + configured but NEVER observed to fire (honest)
#   @design-untested    - designed/claimed but not actually exercised end-to-end
#   @known-limit        - a real boundary carried forward, not hidden
#
# Innards linked back to this card (the process's parts):
#   ~/.claude/CLAUDE.md  - §"BUILDING ANY UNIT EMITS ITS REPORT CARD" (the rule)
#   ~/.claude/skills/report-card/SKILL.md  - the HOW, domain-agnostic
#   GHERKIN-FEATURE-WIKI-PATTERN.md         - the schema (card = command = seed)
#   .githooks/post-merge + .githooks/README.md - the self-maintaining third leg
#   features/*.feature + features/*.session.md - the produced triads (instances)
#
# Commit log (the ingest trail -- this process building itself, 2026-06-03):
#   8ca97e9  first F-key report cards (the pattern applied at scale)
#   009dbab  store spawning session beside the F-key cards + SESSION >> links
#   296f3f9  RESULT block (the third leg) added to each card
#   1f47584  self-maintaining post-merge RESULT-LOG hook
#   24279ca  hook excludes features/ + .githooks/ so a card can't self-tag
#   3d5882a  WAV card + two-way innard back-links
#   47015b7  WAV spawning session stored (the vibe-diff leg)
#   3fd46da  the card declared a generative SEED (codespace/thinkspace/areaspace)
#   1ec3e7d  WAV card brought to full triad (RESULT + WATCH + get-back)
#
# RESULT (third leg: spec + session + what shipped):
#   Process delivery : the commits above, direct to esaruoho/main, no PR
#   This card authored: see RESULT-LOG / git log for this file
#   Triad: this .feature <-> session-changes-codespace.session.md <-> those commits
#
# (Deliberately NO machine WATCH line: this card's innards live in ~/.claude
#   (outside the repo) and in features/ + .githooks/ which post-merge EXCLUDES,
#   so the auto-hook CANNOT maintain this meta-card -- it is HAND-maintained.
#   A prose "watch" line was removed after it tokenized to junk words like "the"
#   and made the hook spuriously self-tag this card -- a bug the live hook demo
#   on 2026-06-03 caught. See the @known-limit scenarios below.)
# =============================================================================

Feature: A session changes a codespace
  As the agent+user pair changing this repo through conversation,
  I want every change to leave behind its own graded, session-backed, two-way
  record in the same motion as the edit,
  So that the codespace is always accompanied by a true, compounding,
  git-rebuildable account of what changed, why, and how verified -- and so the
  account can re-seed the work instead of merely describing it.

  # --- The change itself -----------------------------------------------------

  @demonstrated
  Scenario: A session edits the codespace surgically and ships it
    # cite: this session's commits be595b2 (.000->.WAV) + 74c3fe8 (LL<HHMMSS>.WAV),
    #       each: read-before-edit, build (DOSBox-X BUILDALL clean), commit, push
    Given a running session (conversation) and a codespace (this git repo)
    When the user states intent and the agent edits the relevant source files
    Then the change is made surgically (smallest diff that satisfies the intent)
    And it is built and verified before claiming done
    And it is committed and pushed to origin/main

  # --- The record born with the change (the four properties) -----------------

  @rule-active @shipped @demonstrated
  Scenario: Shipping a unit emits its report card in the same motion
    # cite: ~/.claude/CLAUDE.md:436 mandates it; report-card SKILL.md is the HOW;
    #       evidence: features/wav-render-quicksave.feature exists for the change above
    Given a unit of work was built or meaningfully changed
    When it ships
    Then a features/<name>.feature card is emitted (not bolted on afterward)
    And each scenario states a verifiable Given/When/Then claim
    And each claim cites the exact innards (file + proc/line + commit) that satisfy it

  @demonstrated
  Scenario: Each claim is graded honestly -- the grade is the anti-lying mechanism
    # cite: wav card carries @runtime-untested (built, never run); THIS card grades
    #       the self-maintaining hook @wired-untriggered after checking real output
    Given a claim whose verification on the real target has NOT happened
    Then it carries @untested / @runtime-untested / @wired-untriggered, never graded up
    And a grade is only raised after the real-target check actually runs

  @demonstrated
  Scenario: The innards carry a two-way back-link to the card
    # cite: IT_MUSIC.ASM:2826, IT_PE.ASM:2319, WAVDRV.ASM:813 each carry
    #       "; FEATURE-CARD >> features/wav-render-quicksave.feature"
    Given the card cites a proc as an innard
    Then that source line carries a greppable FEATURE-CARD >> marker back to the card
    And `grep FEATURE-CARD` reconstitutes the wiki in both directions

  # --- The triad: session + result -------------------------------------------

  @rule-active @demonstrated
  Scenario: The spawning session is stored beside the card (the vibe diff)
    # cite: features/*.session.md with a "How to get back" block (transcript
    #       file://, session id, `claude --resume <id>`); this card's own session too
    Given a card was emitted
    Then the conversation that drove it is stored as <name>.session.md
    And the session carries a clickable get-back block (transcript + id + resume)
    And future versions can diff the dialogue, not just the code and the card
    # honest: the session id can be AMBIGUOUS when several transcripts the same
    # day reference the same text -- say so rather than guess (see @known-limit)

  @shipped @demonstrated
  Scenario: The card carries RESULT, so the wiki rebuilds straight from git
    # cite: RESULT blocks in features/f11-order-list.feature + wav card header
    Given the change landed in git
    Then the card header RESULT block lists the feature commit(s), the PR if any
      (or "direct-push, no PR"), and the card-authoring commit(s)
    And loading one card yields spec + rationale + diff without re-reading source

  # --- The seed -------------------------------------------------------------

  @shipped @design-untested
  Scenario: The card is a seed -- code and domain re-spawn from it
    # cite: "WHAT THIS CARD SPAWNS" preambles + GHERKIN-FEATURE-WIKI-PATTERN.md
    # status: the principle is shipped and the preamble is present; "regenerate the
    #         code from the card alone" has NOT been exercised, so it stays untested
    Given the {card, session} pair for a unit
    Then the card yields the codespace (file structure) + areaspace (boundary)
    And the session yields the thinkspace (the reasoning)
    But re-spawning a working unit from the card alone is not yet demonstrated

  # --- Staying current by itself (the honest one) ----------------------------

  @shipped @demonstrated
  Scenario: A merge auto-appends RESULT-LOG to the cards it touched
    # cite: .githooks/post-merge -- maps a merge diff's changed lines to each
    #       card's watch-header symbols, appends a dated line under the
    #       RESULT-LOG marker, working tree only, by symbol not filename,
    #       excluding features/ + .githooks/
    # DEMONSTRATED 2026-06-03: a --no-ff merge (6de8cd0) that touched
    #       WAV_Store2Dec made the hook append exactly
    #       "  2026-06-03  direct-merge  merge 6de8cd0  touched: WAV_Store2Dec"
    #       to wav-render-quicksave.feature. Live stdout:
    #       "[post-merge] report-card: logged 6de8cd0 -> wav-render-quicksave.feature"
    Given core.hooksPath = .githooks and a card with a watch header + RESULT-LOG marker
    When a later merge or pull changes one of that card's watched source symbols
    Then post-merge appends a dated PR/commit line under the card's marker
    And it touches the working tree only, never commits, never aborts the merge

  @shipped @demonstrated
  Scenario: A DIRECT commit auto-stamps the card INTO the same commit
    # The gap (post-merge only fires on merges; this fork ships direct-to-main,
    # so it almost never fired) is closed by .githooks/pre-commit: it matches the
    # STAGED diff and `git add`s the stamped card so the line rides into the same
    # commit -- no second commit, ships + pushes with the code.
    # cite: .githooks/pre-commit -> report-card-stamp.sh ("--cached", gitadd=1)
    # DEMONSTRATED 2026-06-03 (isolated worktree): a direct commit touching
    #       Music_ToggleWAVRender produced commit a9e6d98 with TWO files --
    #       the source + wav-render-quicksave.feature -- carrying the line
    #       "  2026-06-03  direct-commit  touched: Music_ToggleWAVRender".
    #       Stdout: "[report-card] RESULT-LOG updated and staged into this commit."
    Given core.hooksPath = .githooks and a staged diff touching a watched symbol
    When the user makes a plain `git commit` (no merge, no PR)
    Then pre-commit stamps the matching card and stages it into that same commit
    And direct-commit lines carry no self-sha (recoverable via `git blame`)

  @demonstrated
  Scenario: The stamper is shared and re-entrancy-safe
    # Both hooks call .githooks/report-card-stamp.sh (one matching engine). It
    # excludes features/ + .githooks/, so a card-only or hook-only commit does
    # NOT stamp -- DEMONSTRATED: a card-only edit committed as 1 file, no loop.
    Given a commit that changes only features/ or only .githooks/
    Then no stamp is produced (the engine excludes those paths)
    And there is no stamp-loop

  @known-limit
  Scenario: A prose watch line trips the hook (caught + fixed in the same demo)
    # The hook tokenizes everything after "# WATCH:" and matches each token as a
    # substring of the diff. A card that wrote PROSE there tokenized to words like
    # "the", which matched the demo diff and spuriously self-tagged the meta-card
    # ("touched: -- the"). Fix: a watch header must be ONLY symbol tokens, or be
    # absent. This meta-card now has none.
    Given a card whose watch header contains prose, not bare symbols
    When any merge happens
    Then common words match and the card is tagged spuriously
    And the fix is: watch headers carry symbols only (or omit the header)

  # --- Known limits carried forward ------------------------------------------

  @known-limit
  Scenario: Concurrent sessions share one working tree
    # Observed THIS turn: a parallel session committed 73c3c2a into this same
    # checkout mid-conversation. Two agents editing one working tree => races on
    # git stash/rebase/push and on the same files. Mitigation used: add only my
    # own new files, pull --rebase before push, never `git clean`.
    Given more than one session operates in /Users/esaruoho/work/impulse-tracker
    Then commits from another session can appear mid-turn
    And git operations must be defensive (scoped add, rebase-before-push)

  @known-limit
  Scenario: The meta-card cannot be auto-maintained by the hook
    # The hook excludes features/ and .githooks/, and this card's innards live
    # there (and in ~/.claude, outside the repo). So the third leg is HAND-kept
    # for this one card. Stated, not hidden.
    Given a card whose innards are all in hook-excluded paths
    Then post-merge will never append to it
    And it must be updated by hand when the process changes

  @known-limit @design-untested
  Scenario: No test runner -- claims are verifiable-in-principle
    # 16-bit TASM has no Cucumber harness; cards are disciplined human/LLM
    # checklists + session commands. The wiki value holds regardless; the
    # automation glue is the part still unwritten.
    Given a domain with no executable test runner
    Then the Given/When/Then claims are checked by hand/LLM, not by a runner
    And grades reflect real-target checks actually performed, nothing more
