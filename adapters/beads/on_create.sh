#!/usr/bin/env bash
# Beads adapter — on_create hook. Enforces team-rocket story conventions when a
# Beads issue is created. Wire this into Beads (NOT Claude Code) — see README.md.
# Reads the event JSON from stdin.
#
# Rules:
# - Epics (goals) must have description (WHY) + acceptance (WHAT)
# - Tasks (implementations) should have a design/description (HOW)
#
# Exit 0 = allow create. Exit 2 = reject with feedback.

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
