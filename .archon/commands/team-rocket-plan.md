---
description: Discover the code, draft the HOW with citations, challenge it, and put one question batch to the human on the beads epic
argument-hint: (reads story from workflow artifacts)
---

# Plan (meowth drafts, jessie challenges)

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/story.md
```

Read first: `.archon/team-rocket/opinions.md`, `.archon/team-rocket/philosophy.md`, `.archon/team-rocket/failure-modes.md`, and the project's own docs (CLAUDE.md, TEAM-ROCKET.md, rules files).

## 1. Discover (meowth)

Given WHY and WHAT, find everything needed to write the HOW. Read the code the story touches, its siblings, its tests. Cite every source. Log every decision as a beads comment on the epic, in this shape:

```
DECISION: <what>
REASON: <why>
EVIDENCE: <file:line, doc, or command output>
REJECTED: <alternatives and why not>
```

Do not guess. A question the repo, the tracker, or the project docs can answer is answered there. Note the repo's no-touch files (toolchain pins, CI config) and the gates that must pass.

## 2. Draft the HOW

Split the work into grapes. A grape is a task one implement iteration finishes: one logical change, 1 to 3 small commits. Each task gets:
- What to do and how, with file pointers. Specific enough that the implementer never has to think about design.
- The behaviours and test cases it must pin (the spec; code and tests implement it).
- The verification setup: env, data, commands that prove it at runtime.
- The gates to run before done.

## 3. Challenge (jessie)

Spawn a fresh-eyes review of the draft with the Agent tool. Her checklist: is each task a grape? Can she name a regression a test would catch per acceptance row? Is the verification setup runnable as written? Any failure mode from the list baked into the design? Any contradiction between acceptance rows? Converge with her before finishing.

## 4. Hand over to the human

Collect what discovery and the challenge could not settle into ONE batch of numbered questions. Each question carries its evidence trail ("checked X and Y; could not determine Z") or arrives as confirm/deny with the evidence.

Then post to the beads epic, as comments (beads is the durable copy; artifacts die with the run):
- the full plan draft,
- the numbered question batch, under the heading `OPEN QUESTIONS`.

Also write both to `$ARTIFACTS_DIR/plan-draft.md`.

**Do not create tasks. Do not assume answers. This workflow ends here.** Finish by stating: the epic id, where the questions are, and that the human should answer them as a comment on the epic and then run `team-rocket-build "<epic-id>"`. Starting that workflow is the approval; nothing is built before it.
