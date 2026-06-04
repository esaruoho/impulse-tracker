#!/usr/bin/env bash
# Regenerate every Convey derived view from its source.
#   STATUS.md                    <- gen-status.py   (from card @grade tags)
#   CONVEY-SESSIONS.generated.md <- gen-sessions.py (from this machine's transcripts)
# The pre-commit hook runs these automatically when a card is staged; this is the
# manual / CI entry point. Never hand-edit the generated files.
set -e
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || dirname "$(dirname "$0")")"
python3 "$ROOT/features/gen-status.py"
python3 "$ROOT/features/gen-sessions.py"
