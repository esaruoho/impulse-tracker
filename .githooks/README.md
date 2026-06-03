# `.githooks/` — version-controlled git hooks

These hooks are committed to the repo so they travel with it. Git does **not**
run hooks from a tracked directory automatically (a clone enabling arbitrary
committed scripts would be a security hole), so each clone must opt in once:

```bash
git config core.hooksPath .githooks
```

Run that from the repo root after cloning. Verify with `git config core.hooksPath`
(should print `.githooks`). To disable: `git config --unset core.hooksPath`.

## `post-merge` — self-maintaining report-card RESULT-LOG

Closes the report-card triad: **`.feature` (spec) + `.session` (conversation) +
RESULT (commits / PR / files-changed)**. After every merge or `git pull`, it
appends a dated one-line entry to each `features/*.feature` card whose WATCHed
symbols were actually changed by the merge.

A card opts in with two header lines:

```
# WATCH: Glbl_F11 PE_OrderList_ClonePattern Music_FindFreePattern ...
# RESULT-LOG >> (auto-maintained by .githooks/post-merge — newest below)
```

- **Mapping is by symbol, not filename.** A card is logged only when one of its
  WATCHed procs/symbols appears on a changed (`+`/`-`) line of the merge diff —
  so touching an unrelated part of a shared file (e.g. `IT_G.ASM`) does not tag
  every card.
- **It only edits the working tree; it never commits.** Review the appended
  lines and commit them. (Auto-commit was deliberately left out to avoid
  surprise commits on every `git pull`.)
- **It can't break a merge.** `post-merge` runs after the merge already
  succeeded; the script is defensive and exits 0 on any trouble.
- **Safe to re-run.** Each `(card, merge-sha)` pair is logged at most once.

An appended line looks like:

```
#   2026-06-03  PR #3  merge 9493101  touched: F_SetControlInstrument Music_InstrumentIsReal
```

### Want it to auto-commit?

Possible (append `git add features/*.feature && git commit -m "..."` to the
hook), but off by default. Ask before turning it on — it would create a commit
on every pull that changes a watched symbol.
