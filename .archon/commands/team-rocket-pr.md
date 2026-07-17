---
description: Push the branch and open the MR/PR with the story and evidence
argument-hint: (reads story from artifacts)
---

# PR

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/story.md
```

1. Push the current branch. Never push to a default branch.
2. Check whether an MR/PR already exists for this branch (`glab mr list --source-branch` / `gh pr list --head`). If yes, update its description and push — do not open a second one. If no, open it: `glab` for GitLab remotes, `gh` for GitHub. Title carries the story id. Body: the WHY, the acceptance criteria and how each is met, and the verification evidence (what was run and observed, from the beads sign-off).
3. Comment the MR/PR URL on the beads epic.
4. If the epic carries an external tracker id, post the URL and status there too, using the access pattern the project documents.
