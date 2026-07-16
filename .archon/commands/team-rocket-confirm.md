---
description: Confirm the fixes hold; final verdict before the PR
argument-hint: (reads findings from artifacts)
---

# Confirm (jessie)

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/findings.md
```

If findings.md says NONE: re-run the gates once to confirm green, post a sign-off comment on the beads epic, and stop.

Otherwise: check each finding against the fix commits. Re-run the gates and the verification steps the findings touched. Every finding is either fixed or has a recorded reason it stays. If something is still broken, say exactly what and fail this step; the workflow must not reach the PR with a broken change. Post the sign-off (or the failure) as a beads comment on the epic.
