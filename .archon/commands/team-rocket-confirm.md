---
description: Confirm the fixes hold; final verdict before the PR
argument-hint: (reads findings from artifacts)
---

# Confirm (jessie)

```bash
[ -f .archon/team-rocket/beads-dir ] && export BEADS_DIR=$(cat .archon/team-rocket/beads-dir)
cat $ARTIFACTS_DIR/findings.md
```

If findings.md says NONE: re-run the gates once to confirm green, post a sign-off comment on the beads epic, write `PASS` to `$ARTIFACTS_DIR/confirm-verdict`, and stop.

Otherwise: check each finding against the fix commits. Re-run the gates and the verification steps the findings touched. Every finding is either fixed or has a recorded reason it stays. Post the sign-off (or the failure) as a beads comment on the epic.

You cannot fail this node yourself — the `ship-gate` bash node after you reads your verdict. Your LAST action is one of:

```bash
printf 'PASS\n' > "$ARTIFACTS_DIR/confirm-verdict"     # every finding fixed or recorded; gates green
printf 'FAIL\n%s\n' "<what is still broken>" > "$ARTIFACTS_DIR/confirm-verdict"
```

A broken change must not reach the PR; when in doubt, FAIL — a missing file fails closed.
