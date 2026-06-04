# Session — undo-messaging

> Thinkspace leg of the `undo-messaging` teaching card. How the undo-naming
> mechanism was traced, why it's worth a reference card, and the wording rename.

## The request (verbatim)

Esa, 2026-06-05:

> "roll this as a gherkin. this ought to be properly done so that we can have a
> impulsetracker skill and knowledge and remainder and teaching of how to create
> UndoBufferTypes so they are there."

So: turn the just-learned undo-naming mechanism into durable, teachable knowledge
(a @howto card), not just a one-off label fix.

## How it was traced (the prior turn)

Esa reported the Alt-R / Shift-Alt-R undo step was "unnamed". Static trace:
1. Both replicate procs DID set the tag (`Mov DI, 23` / `Mov DI, 24`) and call
   `PE_AddToUndoBuffer` — same convention as working ops (Alt-S DI=12, Alt-Delete
   DI=20). So the tag was being passed.
2. `PE_AddToUndoBuffer` stores the tag at `[entry+2]` (line 13794) for ALL callers
   equally — so the type WAS stored.
3. `PEFunction_DrawUndo` (13865) looks the type up in `UndoBufferTypes` (13887).
4. Root cause: in the build Esa tested (460a6e1), the offset table only had entries
   0..22, but the replicate ops passed 23 -> DrawUndo indexed PAST the table end ->
   garbage. Fixed later (3a3b7ff) by adding the 23/24 strings + offset DWs — which
   landed AFTER 460a6e1, so his build still showed it unnamed.
5. Esa then wanted action-named wording -> renamed to "Replicate Track Above
   (Alt-R)" / "Replicate Pattern Above (Sh-Alt-R)" (d938ff4).

## Why a reference card (not just a behaviour card)

The naming mechanism is GENERIC: every future pattern-mutating fork op needs to
follow the same four-step contract (string + offset-table DW + DI=type + optional
format codes) or its undo step will be blank/garbage. That's reusable doctrine, so
it gets a @howto card the impulse-tracker skill can teach from — the off-the-end
trap in particular is the kind of thing that silently recurs.

## Decisions

- Plain inline-key label style ("(Alt-R)") chosen over the `0FFh,N` right-aligned
  form to avoid alignment guesswork; `S_DrawString`'s 0FFh semantics weren't pinned
  down and the pre-existing Type24 already used the plain inline style successfully.
- Card tagged @howto (mechanism + recipe). The mechanism scenarios are
  @runtime-verified (stock undo naming demonstrably works for every stock op); the
  specific renamed replicate labels are @runtime-untested pending Esa's live look.

## Honest grade

Docs-only card; the innards it documents are real and shipped. The renamed labels
are build-verified and relaunched in DOSBox-X (pid 70487) for Esa to eyeball; not
yet confirmed, so that one scenario stays @runtime-untested.

## How to get back

- Transcript: file:///Users/esaruoho/.claude/projects/-Users-esaruoho-work/442513b6-4d90-4fef-959c-1ac9d79e8ec0.jsonl
- Session ID: `442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Resume: `claude --resume 442513b6-4d90-4fef-959c-1ac9d79e8ec0`
- Session timestamp: 2026-06-05 ~00:40 EEST (run `date` to confirm)
- CWD: /Users/esaruoho/work (repo at /Users/esaruoho/work/impulse-tracker)
