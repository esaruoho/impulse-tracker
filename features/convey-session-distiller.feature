# =============================================================================
# WIKI PAGE / REPORT CARD: Convey SessionEnd distiller
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/convey-session-distiller.session.md
#
# A Claude Code SessionEnd hook fires `features/convey-distill.py` when a Convey
# conversation in this repo ENDS, and writes a per-session stub at
# features/sessions/<id>.md -- plugging the session in the moment it ends, without
# waiting for a card-commit. It runs SYNCHRONOUSLY and FAST (~0.2s); it does NOT
# regenerate the whole registry at exit (too slow for a teardown-blocking hook) --
# CONVEY-SESSIONS.generated.md refreshes on the next commit instead. HOST TOOLING
# (not a DOS tracker feature) so it is excluded from the STATUS.md hardware matrix.
#
# Report-card legend (tags):
#   @shipped          - in origin/main
#   @code-verified    - verified by reading the code / its structure
#   @runtime-verified - exercised for real (ran the script / observed the effect)
#   @runtime-untested - NOT yet exercised end-to-end
#   @fixed-pending-verify - a real failure was seen + fixed; awaiting a re-run to confirm
#   @known-limit      - a real boundary, stated not hidden
#
# Source files linked back to this card:
#   features/convey-distill.py  - the distiller (stdin SessionEnd JSON -> stub, sync)
#   .claude/settings.json       - project SessionEnd hook -> convey-distill.py (timeout 15)
#   features/sessions/          - per-session stubs + .distill-log + .last-payload.json
#                                 (last two gitignored: proof-of-fire + raw payload)
#   features/gen-sessions.py    - the registry generator (runs on COMMIT, NOT at exit)
#
# RESULT (triad: .feature spec + .session convo + what shipped):
#   Feature delivery : this session (see git log for this file)
#   Triad: this .feature <-> convey-session-distiller.session.md <-> the commit
# =============================================================================

Feature: A Convey conversation self-archives when it ends
  As someone running many parallel Convey conversations,
  I want each one to plug itself into the Convey base the moment it ENDS,
  So the sessions registry and per-session stubs are current without waiting for
  the next card-commit (the lag I hit when asking "how many sessions are linked").

  @shipped @runtime-verified
  Scenario: The distiller turns a SessionEnd payload into a per-session stub (fast)
    # cite: features/convey-distill.py reads {session_id, transcript_path} on stdin
    #       (keys confirmed against the documented Claude Code SessionEnd schema).
    # VERIFIED 2026-06-05: 0.19s synchronous on the LARGEST transcript; on a Convey
    # transcript it wrote features/sessions/<id>.md (span, end-reason, topic, 28
    # cards + 10 tools, resume) + FIRED/DONE lines in .distill-log.
    Given a SessionEnd payload pointing at a Convey-relevant transcript
    When convey-distill.py runs
    Then a per-session stub features/sessions/<id>.md is written (metadata only), in ~0.2s
    And it does NOT regenerate the registry here (that happens on the next commit)

  @shipped @runtime-verified @fixed-pending-verify
  Scenario: The SessionEnd HOOK fires the distiller when a real Convey session ends
    # cite: .claude/settings.json SessionEnd -> python3 $CLAUDE_PROJECT_DIR/features/convey-distill.py
    # FIRED FOR REAL 2026-06-05 (Esa typed `exit`): wiring confirmed -- the hook DID
    # invoke the distiller, but Claude reported "Hook cancelled".
    # ROOT CAUSE (corrected via the Claude Code hook docs -- NOT my first guess):
    #   "Hook cancelled" = the harness KILLED the hook during teardown (e.g. Ctrl+C);
    #   it is NOT a timeout. SessionEnd hooks run SYNCHRONOUSLY and BLOCK teardown,
    #   and DETACHED children are NOT guaranteed to survive (Claude kills the hook's
    #   process group). So my first "fix" (fork+setsid, return instantly) was WRONG --
    #   it would let the child be killed mid-work. REVERTED this commit.
    # FIX: do the work SYNCHRONOUSLY and FAST (~0.2s, one transcript, no registry
    #   regen), so it completes before teardown on a normal `exit`.
    # @fixed-pending-verify until the NEXT real `exit` shows a fresh DONE line in
    #   features/sessions/.distill-log and no "Hook cancelled".
    Given the project SessionEnd hook is approved and active
    When a Convey conversation in this repo ends via a normal `exit`
    Then the distiller runs synchronously, writes the stub, and logs FIRED + DONE
    And no "Hook cancelled" message appears

  @shipped @code-verified
  Scenario: Defensive, metadata-only, never touches git
    # cite: convey-distill.py wraps everything in try/except, always returns 0, and
    # performs file writes only -- no git add/commit (the working tree is shared by
    # parallel sessions; auto-commit would race). No dialogue text is copied (the
    # repo is public; the topic is derived from touched cards, not the user's words).
    Given the distiller runs in a shared working tree on a public repo
    Then it can never disrupt a session ending (exit 0 on any error)
    And it writes only metadata, never git-commits, never copies dialogue

  @known-limit
  Scenario: The stub is metadata, not a full vibe-diff
    # The distiller REGISTERS + summarizes by metadata (@distill-pending). A true
    # vibe-diff (the dialogue distilled into a real <name>.session.md) is still a
    # human/agent act -- a shell hook cannot summarize a conversation. The stub is
    # the seed for that, not the thing itself.
    Given a session stub written by the distiller
    Then it carries @distill-pending; promoting it to a real .session.md is manual

  @known-limit
  Scenario: Machine-local and approval-gated
    # Transcripts live in ~/.claude on this machine; on another clone the distiller
    # finds none and no-ops. The project hook also needs one-time approval per clone.
    Given another clone / machine without the transcripts or hook approval
    Then the distiller is a quiet no-op until set up there

  @known-limit
  Scenario: Claude Code edge cases the distiller cannot fix
    # Per the Claude Code hook docs / known bugs: exiting via Ctrl+C CANCELS the
    # SessionEnd hook (#32712), and /clear does NOT fire SessionEnd at all (#6428).
    # So the distiller reliably runs only on a normal `exit`. And the registry
    # (CONVEY-SESSIONS.generated.md) is deliberately NOT refreshed at exit (that
    # would block teardown) -- it refreshes on the next commit via .githooks/pre-commit.
    Given the user exits via Ctrl+C, or via /clear
    Then the SessionEnd hook is cancelled / does not fire (a Claude Code limitation)
    And the stub is written only on a normal `exit`; the registry updates on commit
