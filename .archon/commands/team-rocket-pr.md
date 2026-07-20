---
description: Push the branch and open the MR/PR with the story and evidence
argument-hint: (reads story from artifacts)
---

# PR

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/story.md
```

Delivery shape (human decision): one stacked MR per grape, plus one epic roll-up MR.

1. Identify each grape's commits on the current branch (commit messages carry the task ids; `bd show` each task for its close evidence). Never push to a default branch.
2. For each grape, in dependency order, create a branch at that grape's last commit: `<story>-b0`, `<story>-b1`, … Push them all.
3. Open the stack (`glab` for GitLab, `gh` for GitHub), reusing any MR that already exists for a branch instead of duplicating:
   - first grape's MR targets the default branch;
   - every later grape's MR targets the previous grape's branch (grape-sized diffs; the host retargets as the stack merges).
   - Each title: story id + grape id. Body: what the grape does, its spec coverage, its verification evidence.
4. Open the epic roll-up MR from the full branch to the default branch. Title: story id + "epic roll-up". Body: the WHY, the acceptance criteria, the verification evidence from the beads sign-off, and an index of the grape MRs in merge order. Note in it that code lands through the stack; the roll-up is the epic-level review view.
5. Comment all MR URLs on the beads epic, stack order stated.
6. If the epic carries an external tracker id, post the roll-up URL and status there, using the access pattern the project documents.
