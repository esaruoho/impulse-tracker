# Report Card — Convey test-runner conveys the test situation to a User and routes the verdict back

> Source: `features/convey-test-runner.feature` · printable rendering · regenerate with `python3 features/print-card.py`

**Intent:** As the human who flashes a build to real DOS hardware, I want a runner that shows me each unverified behaviour, takes my works/failed call (with a note when it fails), and folds that straight back into the cards, So that confirming what works costs no chat tokens and the generated status matrices advance themselves — the human run becomes Convey truth.

**Grades:** @build-verified × 6 · @runtime-verified × 5 · @shipped × 6

**Scenarios: 6**


---


## 1. It displays each unverified fork scenario's Given/When/Then to the tester

`@shipped @build-verified @runtime-verified @tool`


- Given fork scenarios that are not yet @hw-verified
- When the runner is launched
- Then it shows them one at a time -- card, scenario, the steps to perform, and
- whether DOSBox already confirmed it -- so the User knows exactly what to test

<sub>cite: features/hwtest.py load_items (fork + not @hw-verified, DOSBox-first)</sub>


## 2. It captures the User's verdict: works / failed (+ how) / skip / back / quit

`@shipped @build-verified @runtime-verified @tool`


- Given an item is displayed
- When the User presses w / f / s / b / q
- Then works/skip are recorded, failed also captures a free-text note, and the
- verdict is saved after EVERY answer (resumable -- quit and rerun continues)

<sub>cite: features/hwtest.py verdict loop; 'f' prompts "how did it fail?"</sub>


## 3. A "works" verdict flips that scenario to @hw-verified in its card

`@shipped @build-verified @runtime-verified @tool`


- Given the User marked a scenario "works"
- When the runner exits
- Then the scenario's @hw-untested becomes @hw-verified in its own card
- And STATUS.md / HARDWARE-TEST.md regenerate from the cards (never hand-typed)

<sub>cite: features/hwtest.py flip_tag_to_hw_verified -- edits the scenario's tag</sub>


## 4. Failures are conveyed out as the single focused worklist

`@shipped @build-verified @runtime-verified @tool`


- Given the User marked some scenarios "failed" with notes
- When the runner exits
- Then features/HW-FAILURES.md holds exactly those, with the notes -- the only
- thing the User sends back; passes need no words

<sub>cite: features/hwtest.py write_features -> features/HW-FAILURES.md</sub>


## 5. The launcher runs from any directory

`@shipped @build-verified @runtime-verified @tool`


- Given the user is in any directory
- When they run ~/work/impulse-tracker/test-impulse-tracker
- Then the runner starts against this repo's cards regardless of cwd

<sub>cite: test-impulse-tracker resolves the repo from its own path (symlink-safe)</sub>


## 6. The runner is excluded from the hardware test matrix

`@shipped @build-verified @tool`


- Given the generated STATUS.md and HARDWARE-TEST.md
- When they are regenerated from the cards
- Then this runner card is not listed as a fork behaviour to verify on metal

<sub>cite: features/gen-status.py + gen-hwtest.py + hwtest.py EXCLUDE sets list</sub>

