---
description: Address verification findings
argument-hint: (reads findings from artifacts)
---

# Fix (james)

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/findings.md
```

If the file says NONE, reply "nothing to fix" and stop.

Otherwise, for each finding: fix it, or state in a beads comment why it should not be fixed. Same commit rules as implementation (one logical change, story id in the message). Re-run the gates after the last fix. List what you changed per finding.
