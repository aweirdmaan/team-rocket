---
description: Turn a story idea or tracker id into a beads story with WHY and WHAT
argument-hint: story id or story description
---

# Ideate (meowth)

Input: $ARGUMENTS

Beads setup (do this first, every command does):
```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
```

1. If the input is a beads id: read the story (`bd show`). If it already has a clear WHY and WHAT, write them to `$ARTIFACTS_DIR/story.md` and stop here.
2. If the input is an external tracker id (Jira etc.): first search beads for an epic already carrying that id (`bd list --all` / `bd search`) — if one exists, use it, don't mirror twice. Otherwise fetch the story using the access pattern the project documents (CLAUDE.md or TEAM-ROCKET.md) and mirror it: `bd create --type=epic` with the WHY and WHAT. Note the external id in the epic description so `pr` and `retro` can sync back.
3. If the input is a description: write the WHY (one paragraph: why this matters, for whom) and the WHAT (acceptance criteria: testable, binary outcomes). Create the beads epic.
4. Write to `$ARTIFACTS_DIR/story.md`: the beads epic id, the external id if any, WHY, WHAT.

Do not design. HOW belongs to `plan`.
