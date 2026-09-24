# Report Card — A Convey conversation self-archives when it ends

> Source: `features/convey-session-distiller.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As someone running many parallel Convey conversations, I want each one to plug itself into the Convey base the moment it ENDS, So the sessions registry and per-session stubs are current without waiting for the next card-commit (the lag I hit when asking "how many sessions are linked").

**Grades:** @runtime-verified × 2 · @shipped × 3

**Scenarios: 6**


---


## 1. The distiller turns a SessionEnd payload into a per-session stub (fast)

`@shipped @runtime-verified`


- Given a SessionEnd payload pointing at a Convey-relevant transcript
- When convey-distill.py runs
- Then a per-session stub features/sessions/<id>.md is written (metadata only), in ~0.2s
- And it does NOT regenerate the registry here (that happens on the next commit)

<sub>cite: features/convey-distill.py reads {session_id, transcript_path} on stdin</sub>


## 2. The SessionEnd HOOK fires the distiller when a real Convey session ends

`@shipped @runtime-verified`


- Given the project SessionEnd hook is approved and active
- When a Convey conversation in this repo ends via a normal `exit`
- Then the distiller runs synchronously, writes the stub, and logs FIRED + DONE
- And no "Hook cancelled" message appears

<sub>cite: .claude/settings.json SessionEnd -> python3 $CLAUDE_PROJECT_DIR/features/convey-distill.py</sub>


## 3. Defensive, metadata-only, never touches git

`@shipped @code-verified`


- Given the distiller runs in a shared working tree on a public repo
- Then it can never disrupt a session ending (exit 0 on any error)
- And it writes only metadata, never git-commits, never copies dialogue

<sub>cite: convey-distill.py wraps everything in try/except, always returns 0, and</sub>


## 4. The stub is metadata, not a full vibe-diff

`@known-limit`


- Given a session stub written by the distiller
- Then it carries @distill-pending; promoting it to a real .session.md is manual


## 5. Machine-local and approval-gated

`@known-limit`


- Given another clone / machine without the transcripts or hook approval
- Then the distiller is a quiet no-op until set up there


## 6. Claude Code edge cases the distiller cannot fix

`@known-limit`


- Given the user exits via Ctrl+C, or via /clear
- Then the SessionEnd hook is cancelled / does not fire (a Claude Code limitation)
- And the stub is written only on a normal `exit`; the registry updates on commit

