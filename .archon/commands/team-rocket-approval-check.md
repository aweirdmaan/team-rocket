---
description: Check the epic for human approval of the current task list; never pause
argument-hint: (reads plan from artifacts, approval from beads)
---

# Approval check

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/plan.md
bd comments <epic-id>
```

The human approves plans as comments on the epic. Your job is one comparison:

1. Find the latest `APPROVAL` comment on the epic.
2. Compare what it approves against the current task list in `plan.md`.

**Match** (same tasks, no material change since the approval): your last action is
`printf 'PASS\n' > "$ARTIFACTS_DIR/approve-verdict"`.

**No approval, or the task list changed after it**: post one comment on the epic — the plan
summary (one line per task, in order, plus any decision that changed since the last approval)
ending with: *"To approve, comment: APPROVED — B0–B9 as listed. Then rerun team-rocket-implement."*
Then your last action is `printf 'FAIL\nawaiting human approval on the epic\n' > "$ARTIFACTS_DIR/approve-verdict"`.

Never assume approval. Never pause. A missing verdict file fails closed.
