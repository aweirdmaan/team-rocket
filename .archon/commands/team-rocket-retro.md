---
description: Judge the plan against the outcome; record what the team learned
argument-hint: (reads story and plan from artifacts)
---

# Retro (meowth)

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/story.md $ARTIFACTS_DIR/plan.md $ARTIFACTS_DIR/findings.md
```

Answer honestly. Your output is worthless unless it is durable: post the retro as a beads comment on the epic (verify the command succeeded), run `bd remember` for cross-cutting insights, and file proposals as beads issues. If `bd` fails, say so loudly in your final message - do not pretend. Cover:

1. Did the plan hold? Was every task actually a grape? Did any task come back blocked because reality disagreed with it? Was the verification setup sufficient, or did jessie have to improvise?
2. What did verification catch that planning should have? Each such finding is a planning lesson; write it down.
3. What is worth keeping? Discoveries, gotchas, decisions future stories on this code need. `bd remember` the cross-cutting ones.
4. If the same failure mode appeared more than once, file a beads issue proposing an addition to `.archon/team-rocket/failure-modes.md` or `opinions.md`.

A wrong prediction is the most useful line in the retro. For a trivial story, "plan held; nothing learned" is complete. Human review comments on the MR arrive later; the team-rocket-harvest workflow handles those.
