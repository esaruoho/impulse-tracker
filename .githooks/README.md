# `.githooks/` — version-controlled git hooks

These hooks are committed to the repo so they travel with it. Git does **not**
run hooks from a tracked directory automatically (a clone enabling arbitrary
committed scripts would be a security hole), so each clone must opt in once:

```bash
git config core.hooksPath .githooks
```

Run that from the repo root after cloning. Verify with `git config core.hooksPath`
(should print `.githooks`). To disable: `git config --unset core.hooksPath`.

## Self-maintaining report-card RESULT-LOG (two triggers, one engine)

Closes the report-card triad: **`.feature` (spec) + `.session` (conversation) +
RESULT (commits / PR / files-changed)**. The matching + appending logic lives
once in **`report-card-stamp.sh`**; two hooks feed it the two ways this repo
gains history:

- **`pre-commit`** — the everyday **direct-to-main** path. Stamps each card whose
  WATCHed symbols are in the *staged* diff and `git add`s the card so the stamp
  rides **into the same commit** (no second commit; ships + pushes with the
  code). Direct-commit lines carry no self-sha — the commit doesn't exist yet —
  but `git blame`/`git log -L` on the line recovers it exactly.
- **`post-merge`** — the **merge / PR / non-ff-pull** path. Records the merge sha.

Either way it appends a dated one-line entry to each `features/*.feature` card
whose WATCHed symbols were actually changed.

A card opts in with two header lines:

```
# WATCH: Glbl_F11 PE_OrderList_ClonePattern Music_FindFreePattern ...
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest below)
```

- **Mapping is by symbol, not filename.** A card is logged only when one of its
  WATCHed procs/symbols appears on a changed (`+`/`-`) line of the diff — so
  touching an unrelated part of a shared file (e.g. `IT_G.ASM`) does not tag
  every card.
- **A WATCH line must be bare symbols, not prose.** Tokens are matched as
  substrings; prose like `the` matches almost any diff and self-tags the card.
  A card with no machine-watchable innards should carry NO `# WATCH:` line.
- **`features/` and `.githooks/` are excluded** from the scanned diff, so a card
  edit or a hook edit can't self-tag.
- **It can't break a commit or a merge.** Both hooks are defensive and exit 0 on
  any trouble; `post-merge` runs after the merge already succeeded, and
  `pre-commit` never aborts.
- **post-merge is safe to re-run** — each `(card, merge-sha)` pair logs at most
  once. **pre-commit** logs once per commit by construction.

Appended lines look like:

```
#   2026-06-03  PR #3  merge 9493101  touched: F_SetControlInstrument   <- merge path
#   2026-06-03  direct-commit  touched: WAV_Store2Dec                    <- direct path
```
