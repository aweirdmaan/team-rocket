---
description: Prove the change survives production, then review the diff
argument-hint: (reads plan from artifacts and beads)
---

# Verify (jessie)

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/story.md $ARTIFACTS_DIR/plan.md
```

Read `.archon/team-rocket/failure-modes.md` and `.archon/team-rocket/opinions.md`. You may write test probes under the project's test roots. You never write production code.

## 1. Prove it works

- Run every gate the tasks list. Zero failures.
- Run the change per each task's verification setup. Record what you observed, not what was expected.
- Attack it: adversarial inputs, failure paths (dependency down, missing data, retry), environment variance if the project is multi-env. Run it twice; leftover-state bugs hide from single runs.
- Regression: run the existing suite in full. Anything that worked before must still work.

## 2. Review the diff

- Every acceptance row maps to a test that pins it plus the runtime evidence above. A row without both is a finding.
- Check the diff against the failure-modes list; name any hit by its entry name.
- Assertions must fail on a plausible regression. Exact values, not "is not null".
- No-touch files (per the plan) untouched. Commit sizes within opinions.md. Blocked tasks in beads are findings. A READY task left open after the implement loop finished is a finding - never rationalize it as scope.

## 3. Report

Write findings to `$ARTIFACTS_DIR/findings.md`, one per line: `file:line | what is wrong | the failure it allows | suggested fix`. Post the same as a beads comment on the epic. If there are no findings, write `NONE` in the file and say so. End with one paragraph: what you ran, what you observed, your verdict.
