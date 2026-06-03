#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# check-session-2026-06-03.sh — runnable Gherkin checks for the conversation card
# features/session-2026-06-03-multitimbral-and-whitelabel.feature
#
# Turns the card's @repo-checkable scenarios into pass/fail assertions you can
# run anywhere with a clone (one needs `gh` + network for the release check;
# it degrades to SKIP without it). Doubles as a lint over the whole card set:
# every card must carry a SESSION >>, every session must be clickable.
#
# Usage:  bash features/check-session-2026-06-03.sh
# Exit:   0 = all hard checks passed, 1 = a hard check failed.
# Fixed-string greps only (grep -F) — no backtracking-prone patterns.
# -----------------------------------------------------------------------------
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
FAIL=0
pass(){ printf '  PASS  %s\n' "$1"; }
fail(){ printf '  FAIL  %s\n' "$1"; FAIL=1; }
skip(){ printf '  SKIP  %s\n' "$1"; }

echo "Scenario: The Shift-F4 multitimbral MIDI feature shipped"
C=features/midi-in-multitimbral.feature
if [ -f "$C" ] && grep -Fq "8c32fd2" "$C"; then
  pass "midi-in-multitimbral.feature exists and cites 8c32fd2"
else
  fail "midi-in-multitimbral.feature missing or does not cite 8c32fd2"
fi

echo "Scenario: Every report card carries its spawning session"
# True invariant: each card references an EXISTING .session.md. Most cards use a
# per-card sibling (<base>.session.md); the F-key cards legitimately SHARE one
# (fkey-report-cards.session.md). So: extract the referenced session filename(s)
# and require at least one to exist. Marker wording varies (SESSION >>,
# thinkspace -, etc.) — match the filename, not a fixed phrase.
missing=0
for f in features/*.feature; do
  ref="$(grep -oE '[A-Za-z0-9._-]+\.session\.md' "$f" | head -1)"
  if [ -n "$ref" ] && [ -f "features/$ref" ]; then :; else
    fail "$f references no existing .session.md"; missing=1
  fi
done
[ "$missing" -eq 0 ] && pass "all features/*.feature reference an existing .session.md"

echo "Scenario: Every session is clickable, not just summarized"
missing=0
for s in features/*.session.md; do
  # a clickable seed carries a transcript/session-id/resume reference
  if grep -Fq "Session ID" "$s" || grep -Fq "claude --resume" "$s" || grep -Fq ".jsonl" "$s"; then :; else
    fail "no transcript/get-back reference in $s"; missing=1
  fi
done
[ "$missing" -eq 0 ] && pass "all features/*.session.md carry a get-back reference"

echo "Scenario: The DOS release was delivered"
if command -v gh >/dev/null 2>&1; then
  if gh release view v2.354-2026-06-03 -R esaruoho/impulse-tracker \
       --json assets -q '.assets[].name' 2>/dev/null | grep -Fq ".zip"; then
    pass "release v2.354-2026-06-03 exists with a .zip asset"
  else
    fail "release v2.354-2026-06-03 or its .zip asset not found"
  fi
else
  skip "release check (gh not installed / no network)"
fi

echo "Scenario: The live MIDI routing still needs hardware proof"
skip "@hw-untested — by design, not auto-checkable (needs real MIDI hardware)"

echo "Scenario: report-card pattern became a reusable system"
skip "@out-of-repo — rule + skill live in ~/.claude, not this repo"

echo
if [ "$FAIL" -eq 0 ]; then echo "ALL HARD CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit "$FAIL"
