# =============================================================================
# WIKI PAGE / REPORT CARD: Convey Gardener — the DETECTOR pass
# Convention: GHERKIN-FEATURE-WIKI-PATTERN.md
# SESSION >> features/convey-gardener.session.md
#
# Host-side tool (@tool), not a tracker behaviour. Implements the DETECT half of
# Convey Principle 7 (features/CONVEY.md): "Convey is a garden, it prunes." Walks
# the cards + sources and REPORTS malformed branches. It NEVER edits/moves/deletes
# anything — pruning is a separate, deliberate commit-with-a-reason. Detect first,
# prune second (same discipline as VRAM-markers-before-fix).
#
# WHAT THIS CARD SPAWNS:
#   - CODESPACE  : features/gardener.py (+ generated features/GARDENER.md), this card,
#                  the session.
#   - THINKSPACE : the .session.md — the false-positive hardening pass (driver-tree
#                  sources, meta-card Python cites, the *.ASM glob, shared SESSION >>).
#   - AREASPACE  : OWNS detection/reporting of malformed branches. MUST NOT mutate
#                  any card/session/source. Pruning is out of scope by design.
#
# Report-card legend (tags):
#   @tool             - host-side python3 tool, not a DOS tracker feature
#   @shipped          - in esaruoho/main
#   @runtime-verified - run against the live garden; output vetted by hand this session
#
# Source files linked back to this card (grep "features/convey-gardener"):
#   features/gardener.py  - the detector (load_sources, cite_tokens, parse_card, main)
#   features/CONVEY.md    - Principle 7 (the doctrine this enforces)
#
# Commit log:
#   (this session)  build + harden the gardener detector
#
# RESULT (triad):
#   Tool delivery : features/gardener.py, direct to main.
#   Run           : python3 features/gardener.py -> 0 PRUNE / 0 DRIFT / 0 INCOMPLETE
#                   / 15 INFO on 2026-06-04 (garden free of malformed branches).
#   Triad: this .feature <-> convey-gardener.session.md <-> the build commit.
#
# WATCH: gardener
# =============================================================================

Feature: Convey Gardener detector (read-only malformed-branch report)
  As the keeper of the card garden,
  I want a tool that REPORTS malformed branches without touching anything,
  So that pruning stays a deliberate, reasoned act and the situation stays wholesome.

  @tool @shipped @runtime-verified
  Scenario: It reports, it never mutates
    # cite: features/gardener.py main() — only reads; --report writes features/GARDENER.md, edits no card
    Given the cards, sessions, and sources
    When `python3 features/gardener.py` runs
    Then it prints findings grouped PRUNE / DRIFT / INCOMPLETE / INFO
    And it changes no card, session, or source file

  @tool @shipped @runtime-verified
  Scenario: A faithfully-recorded wrong turn is never a finding
    # cite: features/gardener.py — findings are dead cites / orphan sessions / dead
    #       back-links / stale markers / grade anomalies, never .session.md content
    Given a .session.md that honestly records a wrong turn
    Then the gardener does NOT flag it (honest history is healthy, per Principle 7)

  @tool @shipped @runtime-verified
  Scenario: Findings are trustworthy — known false positives are suppressed
    # cite: features/gardener.py — SoundDrivers/Network sources scanned; META cards
    #       skip cite checks; glob tokens like *.ASM rejected; shared SESSION >> honored
    Given driver-tree sources, meta/host cards, and cards sharing one session
    When the detector classifies findings
    Then driver-file cites, Python-symbol cites, and shared-session cards are NOT
         reported as malformed
    And the detector exits non-zero only on PRUNE or DRIFT findings (a hook could gate)
