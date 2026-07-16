---
description: Record human MR/PR review comments in beads; file proposals for recurring themes
argument-hint: MR/PR URL, optionally the beads story id
---

# Harvest

Input: $ARGUMENTS

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
```

1. Read every human comment on the MR/PR (`glab mr note list` / `gh pr view --comments`, plus inline discussion threads).
2. Find the beads epic (from the input, or the story id in the MR title).
3. Post each comment to the epic as a beads comment: the quoted feedback, the file/line it targets, and what change it asks for.
4. Group the comments. A theme that appears more than once, or that generalises beyond this story, becomes a beads issue proposing a change to `.archon/team-rocket/opinions.md`, `failure-modes.md`, or a command file. Quote the source comments in the proposal.
5. Reply with the count recorded and the proposals filed.

This is how the team learns from its reviewer. Do not summarise away the why; quote it.
