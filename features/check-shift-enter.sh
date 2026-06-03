#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# check-shift-enter.sh — runnable Gherkin checks for
# features/shift-enter-load-from-sample-list.feature
#
# Verifies the @code-verified claims statically from the repo (no emulator):
#   - the bulk loader exists
#   - it routes each sample through LoadSample (the full-header path that
#     carries names + loop flags), and auto-assigns in Instrument mode
#   - the envelope-retention re-merge (PR #3, 9493101) did NOT touch the loader
#     file -- the machine-checkable proof of "no clash"
# @hw-untested scenarios (on-screen names/loop-modes after a real load) are
# SKIPped here -- they need the emulator/hardware via features/RUNNER.md.
#
# Usage:  bash features/check-shift-enter.sh   (exit 0 = pass, 1 = fail)
# Fixed-string greps only (grep -F) — no backtracking risk.
# -----------------------------------------------------------------------------
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
FAIL=0
pass(){ printf '  PASS  %s\n' "$1"; }
fail(){ printf '  FAIL  %s\n' "$1"; FAIL=1; }
skip(){ printf '  SKIP  %s\n' "$1"; }

echo "Scenario: the bulk loader exists and loads one sample per row"
if grep -Fq "Proc            LSWindow_ShiftEnter Far" IT_DISK.ASM; then
  pass "LSWindow_ShiftEnter present in IT_DISK.ASM"
else fail "LSWindow_ShiftEnter not found"; fi

echo "Scenario: names + loop modes preserved (routed through LoadSample)"
# LoadSample reads the full sample header (name 0x14, loop flags 0x12) from the
# module — so names/loops are carried, not stripped.
if awk '/Proc +LSWindow_ShiftEnter Far/{f=1} f&&/Call +LoadSample/{print;exit}' IT_DISK.ASM | grep -Fq "LoadSample"; then
  pass "LSWindow_ShiftEnter calls LoadSample (full-header path)"
else fail "LSWindow_ShiftEnter does not call LoadSample"; fi

echo "Scenario: Instrument mode auto-assigns each sample to an instrument"
if awk '/Proc +LSWindow_ShiftEnter Far/{f=1} f&&/Music_AssignSampleToInstrument/{print;exit}' IT_DISK.ASM | grep -Fq "Music_AssignSampleToInstrument"; then
  pass "LSWindow_ShiftEnter calls Music_AssignSampleToInstrument"
else fail "no Music_AssignSampleToInstrument call in the loader"; fi

echo "Scenario: envelope-retention (PR #3) does NOT touch the loader file"
if git rev-parse -q --verify 9493101 >/dev/null 2>&1; then
  if git diff --name-only 9493101^1 9493101 2>/dev/null | grep -Fxq "IT_DISK.ASM"; then
    fail "PR #3 modified IT_DISK.ASM — possible clash, investigate"
  else
    pass "PR #3 (9493101) did not modify IT_DISK.ASM — no code overlap with the loader"
  fi
else
  skip "PR #3 merge 9493101 not in local history (fetch to check)"
fi

echo "Scenario: on-screen names/loop-modes after a real load"
skip "@hw-untested — needs emulator/hardware (see features/RUNNER.md)"

echo
if [ "$FAIL" -eq 0 ]; then echo "ALL HARD CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit "$FAIL"
