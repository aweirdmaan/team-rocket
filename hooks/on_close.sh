#!/bin/bash
# Beads on_close hook — enforces session summary before closing a task
# Reads event JSON from stdin
#
# Checks that:
# 1. A close reason is provided
# 2. The task has at least one comment (session summary)
#
# Exit 0 = allow close
# Exit 2 = reject close with feedback message

EVENT=$(cat)

# Debug: log what we received so we can diagnose issues
echo "$EVENT" >> /tmp/beads-on-close-debug.log 2>/dev/null

ISSUE_ID=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
REASON=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('reason',''))" 2>/dev/null)

# If we can't parse the event, don't block — let it through
if [ -z "$ISSUE_ID" ]; then
  exit 0
fi

if [ -z "$REASON" ]; then
  echo "REJECTED: Close requires --reason. What was accomplished?" >&2
  exit 2
fi

# Check if task has at least one comment (session log)
COMMENT_COUNT=$(bd comment list "$ISSUE_ID" --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d) if isinstance(d,list) else 0)" 2>/dev/null || echo "0")

if [ "$COMMENT_COUNT" = "0" ]; then
  echo "WARNING: No session comments on $ISSUE_ID. Consider adding a summary before closing." >&2
  # Warning only, don't block
fi

exit 0
