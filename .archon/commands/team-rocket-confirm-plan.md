---
description: Check every open question is answered, then persist the approved plan as grape tasks
argument-hint: beads epic id
---

# Confirm the plan (meowth)

Input: $ARGUMENTS (the beads epic id)

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
bd show <epic-id>
bd comments <epic-id>
```

## 1. Gate

Read the epic's comments: the plan draft, the `OPEN QUESTIONS` batch, and the human's answers. Match every question to an answer.

**If any question has no answer: stop and fail this step**, listing the unanswered questions verbatim. Do not proceed, do not assume. The human answers on the epic and reruns team-rocket-build.

## 2. Finalize

Fold the answers into the HOW. If an answer invalidates part of the draft, rework that part and log the decision (DECISION / REASON / EVIDENCE / REJECTED) as a comment.

## 3. Persist

Create the tasks in beads: `bd create --type=task --parent=<epic>`, real dependency edges, each task carrying its spec, file pointers, verification setup, and gates (see the plan draft). Re-read what you created and diff it against the draft plus answers: no duplicated entities, no ordering that lives only in prose, no hedged pointer where an answer exists.

Write to the new run's artifacts for the downstream nodes:
- `$ARTIFACTS_DIR/story.md` — epic id, external id if any, WHY, WHAT.
- `$ARTIFACTS_DIR/plan.md` — the final task list with ids.
