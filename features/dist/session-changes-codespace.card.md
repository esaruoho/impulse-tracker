# Report Card — A session changes a codespace

> Source: `features/session-changes-codespace.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As the agent+user pair changing this repo through conversation, I want every change to leave behind its own graded, session-backed, two-way record in the same motion as the edit, So that the codespace is always accompanied by a true, compounding, git-rebuildable account of what changed, why, and how verified -- and so the account can re-seed the work instead of merely describing it.

**Grades:** @shipped × 5

**Scenarios: 14**


---


## 1. A session edits the codespace surgically and ships it

`@demonstrated`


- Given a running session (conversation) and a codespace (this git repo)
- When the user states intent and the agent edits the relevant source files
- Then the change is made surgically (smallest diff that satisfies the intent)
- And it is built and verified before claiming done
- And it is committed and pushed to origin/main

<sub>cite: this session's commits be595b2 (.000->.WAV) + 74c3fe8 (LL<HHMMSS>.WAV),</sub>


## 2. Shipping a unit emits its report card in the same motion

`@rule-active @shipped @demonstrated`


- Given a unit of work was built or meaningfully changed
- When it ships
- Then a features/<name>.feature card is emitted (not bolted on afterward)
- And each scenario states a verifiable Given/When/Then claim
- And each claim cites the exact innards (file + proc/line + commit) that satisfy it

<sub>cite: ~/.claude/CLAUDE.md:436 mandates it; report-card SKILL.md is the HOW;</sub>


## 3. Each claim is graded honestly -- the grade is the anti-lying mechanism

`@demonstrated`


- Given a claim whose verification on the real target has NOT happened
- Then it carries @untested / @runtime-untested / @wired-untriggered, never graded up
- And a grade is only raised after the real-target check actually runs

<sub>cite: wav card carries @runtime-untested (built, never run); THIS card grades</sub>


## 4. The innards carry a two-way back-link to the card

`@demonstrated`


- Given the card cites a proc as an innard
- Then that source line carries a greppable FEATURE-CARD >> marker back to the card
- And `grep FEATURE-CARD` reconstitutes the wiki in both directions

<sub>cite: IT_MUSIC.ASM:2826, IT_PE.ASM:2319, WAVDRV.ASM:813 each carry</sub>


## 5. The spawning session is stored beside the card (the vibe diff)

`@rule-active @demonstrated`


- Given a card was emitted
- Then the conversation that drove it is stored as <name>.session.md
- And the session carries a clickable get-back block (transcript + id + resume)
- And future versions can diff the dialogue, not just the code and the card

<sub>cite: features/*.session.md with a "How to get back" block (transcript</sub>


## 6. The card carries RESULT, so the wiki rebuilds straight from git

`@shipped @demonstrated`


- Given the change landed in git
- Then the card header RESULT block lists the feature commit(s), the PR if any
- (or "direct-push, no PR"), and the card-authoring commit(s)
- And loading one card yields spec + rationale + diff without re-reading source

<sub>cite: RESULT blocks in features/f11-order-list.feature + wav card header</sub>


## 7. The card is a seed -- code and domain re-spawn from it

`@shipped @design-untested`


- Given the {card, session} pair for a unit
- Then the card yields the codespace (file structure) + areaspace (boundary)
- And the session yields the thinkspace (the reasoning)
- But re-spawning a working unit from the card alone is not yet demonstrated

<sub>cite: "WHAT THIS CARD SPAWNS" preambles + GHERKIN-FEATURE-WIKI-PATTERN.md</sub>


## 8. A merge auto-appends RESULT-LOG to the cards it touched

`@shipped @demonstrated`


- Given core.hooksPath = .githooks and a card with a watch header + RESULT-LOG marker
- When a later merge or pull changes one of that card's watched source symbols
- Then post-merge appends a dated PR/commit line under the card's marker
- And it touches the working tree only, never commits, never aborts the merge

<sub>cite: .githooks/post-merge -- maps a merge diff's changed lines to each</sub>


## 9. A DIRECT commit auto-stamps the card INTO the same commit

`@shipped @demonstrated`


- Given core.hooksPath = .githooks and a staged diff touching a watched symbol
- When the user makes a plain `git commit` (no merge, no PR)
- Then pre-commit stamps the matching card and stages it into that same commit
- And direct-commit lines carry no self-sha (recoverable via `git blame`)

<sub>cite: .githooks/pre-commit -> report-card-stamp.sh ("--cached", gitadd=1)</sub>


## 10. The stamper is shared and re-entrancy-safe

`@demonstrated`


- Given a commit that changes only features/ or only .githooks/
- Then no stamp is produced (the engine excludes those paths)
- And there is no stamp-loop


## 11. A prose watch line trips the hook (caught + fixed in the same demo)

`@known-limit`


- Given a card whose watch header contains prose, not bare symbols
- When any merge happens
- Then common words match and the card is tagged spuriously
- And the fix is: watch headers carry symbols only (or omit the header)


## 12. Concurrent sessions share one working tree

`@known-limit`


- Given more than one session operates in /Users/esaruoho/work/impulse-tracker
- Then commits from another session can appear mid-turn
- And git operations must be defensive (scoped add, rebase-before-push)


## 13. The meta-card cannot be auto-maintained by the hook

`@known-limit`


- Given a card whose innards are all in hook-excluded paths
- Then post-merge will never append to it
- And it must be updated by hand when the process changes


## 14. No test runner -- claims are verifiable-in-principle

`@known-limit @design-untested`


- Given a domain with no executable test runner
- Then the Given/When/Then claims are checked by hand/LLM, not by a runner
- And grades reflect real-target checks actually performed, nothing more

