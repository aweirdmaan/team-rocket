#!/bin/bash
# Beads on_create hook — enforces team rocket conventions on issue creation
# Reads event JSON from stdin
#
# Rules:
# - Epics (goals) must have description + acceptance
# - Tasks (implementations) should have design field
#
# Exit 0 = allow create
# Exit 2 = reject with feedback

EVENT=$(cat)

TYPE=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('issue_type',''))" 2>/dev/null)
DESC=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('description',''))" 2>/dev/null)
ACCEPT=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('acceptance_criteria',''))" 2>/dev/null)
DESIGN=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('design',''))" 2>/dev/null)

if [ "$TYPE" = "epic" ]; then
  if [ -z "$DESC" ]; then
    echo "REJECTED: Epic (goal) requires --description (WHY does this matter?)" >&2
    exit 2
  fi
  if [ -z "$ACCEPT" ]; then
    echo "REJECTED: Epic (goal) requires --acceptance (WHAT outcome do we want?)" >&2
    exit 2
  fi
fi

if [ "$TYPE" = "task" ] && [ -z "$DESIGN" ] && [ -z "$DESC" ]; then
  echo "WARNING: Task should have --description or --design (HOW will this be done?)" >&2
  # Warning only — some tasks are straightforward
fi

exit 0
