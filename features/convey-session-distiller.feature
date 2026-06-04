# =============================================================================
# WIKI PAGE / REPORT CARD: Convey SessionEnd distiller
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/convey-session-distiller.session.md
#
# Closes the "registry trails between commits" gap (the lag Esa hit). A Claude
# Code SessionEnd hook fires `features/convey-distill.py` when a Convey
# conversation in this repo ENDS, and -- without waiting for a card-commit --
# plugs the session in LIVE: regenerates CONVEY-SESSIONS.generated.md and writes
# a per-session stub at features/sessions/<id>.md. This is HOST TOOLING (not a
# DOS tracker feature) so it is excluded from the STATUS.md hardware matrix.
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
#   features/convey-distill.py  - the distiller (stdin SessionEnd JSON -> refresh)
#   .claude/settings.json       - project SessionEnd hook -> convey-distill.py
#   features/gen-sessions.py    - the registry generator it re-runs
#   features/sessions/          - per-session stubs + .distill-log (gitignored)
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
  Scenario: The distiller turns a SessionEnd payload into a registry refresh + stub
    # cite: features/convey-distill.py reads {session_id, transcript_path} on stdin
    # VERIFIED 2026-06-05: piped a synthetic SessionEnd JSON at the script -> it
    # regenerated CONVEY-SESSIONS.generated.md and wrote features/sessions/<id>.md
    # (span, topic-from-touched, 24 cards + 10 tools, resume cmd) + a .distill-log line.
    Given a SessionEnd payload pointing at a Convey-relevant transcript
    When convey-distill.py runs
    Then the sessions registry is regenerated
    And a per-session stub features/sessions/<id>.md is written (metadata only)

  @shipped @runtime-verified @fixed-pending-verify
  Scenario: The SessionEnd HOOK fires the distiller when a real Convey session ends
    # cite: .claude/settings.json SessionEnd -> python3 $CLAUDE_PROJECT_DIR/features/convey-distill.py
    # FIRED FOR REAL 2026-06-05 (Esa typed `exit`): the wiring is confirmed -- the
    # hook DID invoke the distiller. BUT Claude reported "Hook cancelled" because
    # the first version ran ~2.1s synchronously (it scanned every transcript via
    # gen-sessions). An exit hook must return instantly.
    # FIX (this commit): the distiller now reads stdin, then DETACHES (fork +
    # setsid) and the PARENT returns in ~0.05s; the detached child does the
    # stub + registry work in its own session, surviving `exit`. Measured: parent
    # 0.046s; child still wrote the stub. @fixed-pending-verify until the NEXT
    # real `exit` confirms no "Hook cancelled" and the stub/registry update.
    Given the project SessionEnd hook is approved and active
    When a Convey conversation in this repo ends (clear / exit / logout)
    Then the hook returns instantly (detached) and never reports "Hook cancelled"
    And the detached child writes the stub + refreshes the registry afterward

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
