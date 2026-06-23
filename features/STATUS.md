# Feature Test Status — GENERATED, DO NOT EDIT BY HAND

> Computed by `features/gen-status.py` from the `@grade` tags in
> `features/*.feature`. The cards are the source of truth; this table is
> derived. The pre-commit hook regenerates it whenever a card changes, so
> nobody hand-types "runtime-verified" into an index again. Hand edits here
> will be overwritten -- change the card's tags instead.
>
> Runtime = exercised in DOSBox-X (emulation). Hardware = real DOS metal.
> `~ partial` = some scenarios verified, some still untested.

| Card | Scn | Build | Runtime (DOSBox) | Hardware | Grades present |
|------|----:|:-----:|:----------------:|:--------:|----------------|
| alt-r-replicate | 6 | ✓ | ~ partial | ✓ | @build-verified @hw-verified @runtime-untested @runtime-verified @shipped |
| ctrl-o-empty-orderlist-crash | 6 | ✓ | ✗ | ✗ | @build-verified @hw-untested @known-limit @runtime-untested @shipped |
| f11-order-list | 9 | ✓ | — | ✓ | @build-verified @hw-untested @hw-verified @shipped @stock |
| f12-song-variables | 4 | ✓ | — | ✗ | @build-verified @hw-untested @shipped @stock |
| f2-pattern-editor | 4 | ✓ | — | ✗ | @build-verified @hw-untested @shipped @stock |
| f2-resize-tiles-pattern | 6 | ✓ | ✓ | ✓ | @build-verified @hw-untested @hw-verified @runtime-verified @shipped |
| f3-sample-list | 5 | ✓ | — | ✗ | @build-verified @hw-untested @shipped @stock |
| f4-f3-cursor-translate | 4 | ✓ | ✗ | ✗ | @build-verified @hw-untested @runtime-untested @shipped |
| f4-instrument-list | 4 | ✓ | — | ✗ | @build-verified @hw-untested @shipped @stock |
| f6-play-from-order-list-row | 5 | ✓ | ✗ | ✗ | @build-verified @hw-untested @runtime-untested @shipped @stock |
| loader-keyjazz-hang | 4 | ✓ | ✗ | ✗ | @build-verified @hw-untested @runtime-untested @shipped @stock |
| midi-in-multitimbral | 9 | ✓ | — | ✗ | @build-verified @hw-untested @shipped @stock @todo |
| midi-out-stop-on-f8 | 8 | ✓ | ✗ | ✗ | @build-verified @hw-untested @runtime-untested @shipped |
| midi-realtime-sync | 11 | ✓ | — | ✗ | @build-verified @hw-untested @shipped @todo |
| multi-wav | 5 | ✓ | ✗ | ✗ | @build-verified @hw-untested @runtime-untested @shipped |
| multitimbral-instrument-play-dots | 5 | ✓ | ✗ | ✗ | @build-verified @hw-untested @runtime-untested @shipped @stock |
| no-samples-to-instruments-envelope-retention | 5 | ✓ | ✗ | — | @build-verified @removed @runtime-untested @stock @todo |
| note-cut-toggle | 3 | ✓ | ✗ | ✗ | @build-verified @hw-untested @runtime-untested @shipped @stock |
| pattern-length-beyond-200 | 5 | ✗ | — | — | @analysis-verified @blocked-by-architecture @stock |
| sample-amplify-keeps-playback | 9 | ✓ | ✓ | ✓ | @bug @build-verified @hw-untested @hw-verified @runtime-verified @shipped @stock |
| scrolllock-follow-from-lists | 9 | ✓ | ~ partial | ✓ | @bug @build-verified @hw-untested @hw-verified @runtime-untested @runtime-verified @shipped @stock @todo |
| shift-enter-bulk-load-from-module | 4 | ✓ | ✗ | ✗ | @bug @build-verified @fixed-pending-verify @hw-untested @runtime-untested @shipped |
| shift-enter-load-from-sample-list | 4 | ✓ | — | ✗ | @code-verified @hw-untested @shipped |
| shift-f4-drumkit | 5 | ✓ | ~ partial | ✓ | @build-verified @hw-untested @hw-verified @runtime-untested @runtime-verified @shipped |
| shift-f4-enters-instrument-mode | 4 | ✓ | ~ partial | ✓ | @build-verified @hw-untested @hw-verified @runtime-untested @runtime-verified @shipped |
| song-name-timestamp-default | 5 | ✓ | ~ partial | ✓ | @build-verified @hw-untested @hw-verified @runtime-untested @runtime-verified @shipped |
| undo-messaging | 6 | ✓ | ~ partial | — | @bug @build-verified @howto @runtime-untested @runtime-verified @shipped @stock |
| wav-render-keep-playback | 7 | ✓ | ~ partial | ✓ | @build-verified @hw-untested @hw-verified @known-limit @runtime-untested @runtime-verified @shipped |
| wav-render-quicksave | 8 | ✓ | ~ partial | ✓ | @build-verified @hw-untested @hw-verified @known-limit @runtime-untested @runtime-verified @shipped |
| wav-render-reentry-guard | 7 | ✓ | ✓ | ✗ | @build-verified @hw-untested @runtime-verified @shipped |

## Tally (computed)
- Cards: 30
- Build-verified: 29
- Runtime-verified in DOSBox-X: 3 full + 8 partial
- **Hardware-verified: 10**  ·  hardware-untested: 17

