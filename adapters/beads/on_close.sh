#!/usr/bin/env bash
# Beads adapter — on_close hook. Enforces a close reason and nudges for a session
# summary before a Beads issue is closed. Wire this into Beads (NOT Claude Code) —
# see README.md. Reads the event JSON from stdin.
#
# Checks:
# 1. A close reason is provided (hard requirement).
# 2. The task has at least one comment / session summary (warning only).
#
# Exit 0 = allow close. Exit 2 = reject close with feedback.

EVENT=$(cat)

ISSUE_ID=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
REASON=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('reason',''))" 2>/dev/null)

# If we can't parse the event, don't block — let it through.
if [ -z "$ISSUE_ID" ]; then
  exit 0
fi

if [ -z "$REASON" ]; then
  echo "REJECTED: Close requires --reason. What was accomplished?" >&2
  exit 2
fi

# Nudge (non-blocking) if there's no session comment on the issue.
COMMENT_COUNT=$(bd comment list "$ISSUE_ID" --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d) if isinstance(d,list) else 0)" 2>/dev/null || echo "0")

if [ "$COMMENT_COUNT" = "0" ]; then
  echo "WARNING: No session comments on $ISSUE_ID. Consider adding a summary before closing." >&2
  # Warning only, don't block.
fi

exit 0
