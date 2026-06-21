#!/usr/bin/env bash
# Team Rocket — deterministic guardrails (PreToolUse).
#
# Enforces the playbook's "hard rules" mechanically, so they hold regardless of
# what any agent decides to do:
#   - no push to a default branch (main / master / develop / trunk)
#   - no force-push to a default branch
#   - no committing / pushing while checked out on a default branch
#   - no bypassing commit/CI gates (--no-verify)
#   - no edits to build files, CI config, or toolchain pins
#
# Reads the PreToolUse event JSON on stdin.
#   Exit 0 = allow.
#   Exit 2 = block; stderr is fed back to the agent as the reason.
#
# Escape hatch: a human can always run the command directly in the terminal
# (e.g. a `!`-prefixed shell line), which is not a tool call and bypasses this hook.

EVENT=$(cat)

# Pull a (possibly nested, dot-separated) string field out of the event JSON.
field() {
  printf '%s' "$EVENT" | python3 -c '
import sys, json
path = sys.argv[1].split(".")
try:
    cur = json.load(sys.stdin)
except Exception:
    print(""); sys.exit(0)
for k in path:
    cur = cur.get(k, "") if isinstance(cur, dict) else ""
print(cur if isinstance(cur, str) else "")
' "$1" 2>/dev/null
}

block() {
  echo "BLOCKED by team-rocket guardrail: $1" >&2
  echo "This is a hard rule from the playbook. If it is genuinely intended, the lead" >&2
  echo "should run it directly in the terminal (a tool call cannot bypass this hook)." >&2
  exit 2
}

TOOL=$(field tool_name)

# A default-branch token appearing as a path/arg component.
DEFAULT_RE='(^|[/[:space:]])(main|master|develop|trunk)([[:space:]]|:|$)'

case "$TOOL" in
  Bash)
    CMD=$(field tool_input.command)

    if printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+push'; then
      CURRENT=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
      case "$CURRENT" in
        main|master|develop|trunk)
          block "push while checked out on default branch '$CURRENT'. Switch to a feature branch." ;;
      esac
      if printf '%s' "$CMD" | grep -Eq -- '--no-verify'; then
        block "git push with --no-verify (bypasses pre-push gates)."
      fi
      if printf '%s' "$CMD" | grep -Eq -- '(--force|[[:space:]]-f([[:space:]]|$))' \
         && printf '%s' "$CMD" | grep -Eq "$DEFAULT_RE"; then
        block "force-push targeting a default branch."
      fi
      if printf '%s' "$CMD" | grep -Eq "$DEFAULT_RE"; then
        block "push to a default branch (main/master/develop/trunk). Use a feature branch."
      fi
    fi

    if printf '%s' "$CMD" | grep -Eq 'git[[:space:]]+commit' \
       && printf '%s' "$CMD" | grep -Eq -- '--no-verify'; then
      block "git commit with --no-verify (bypasses pre-commit gates)."
    fi
    ;;

  Edit|Write|MultiEdit|NotebookEdit)
    FP=$(field tool_input.file_path)
    BASE=$(basename "$FP" 2>/dev/null || echo "")
    case "$BASE" in
      build.gradle|build.gradle.kts|settings.gradle|settings.gradle.kts|pom.xml|\
      package.json|pnpm-lock.yaml|yarn.lock|package-lock.json|\
      pyproject.toml|poetry.lock|setup.py|setup.cfg|\
      Gemfile|Gemfile.lock|Cargo.toml|Cargo.lock|go.mod|go.sum|\
      .tool-versions|mise.toml|.mise.toml|Dockerfile|.nvmrc|.python-version)
        block "edit to toolchain/build file '$BASE'. A local-env mismatch is your environment's problem, not the project's — surface it to the lead." ;;
    esac
    case "$FP" in
      */.github/workflows/*|*.gitlab-ci.yml|*/Jenkinsfile|*azure-pipelines.yml|*/.circleci/*|*.pre-commit-config.yaml)
        block "edit to CI / pre-commit config '$FP'. CI changes are the lead's call." ;;
    esac
    ;;
esac

exit 0
