#!/usr/bin/env bash
# team-rocket self-validation. Run before committing.
#   - every workflow YAML parses
#   - every command referenced by a workflow exists in .archon/commands/
#   - the artifacts the commands point at exist
#   - every *.sh is shellcheck-clean (if shellcheck is installed) and executable
#   - archon's own validators pass (if archon is installed)
# Exit 0 = all checks pass. Exit 1 = at least one failure.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
fail=0
note() { printf '  %s\n' "$1"; }
ok()   { printf 'PASS  %s\n' "$1"; }
bad()  { printf 'FAIL  %s\n' "$1"; fail=1; }

echo "== workflow YAML parses =="
if python3 -c "import yaml" 2>/dev/null; then
  while IFS= read -r y; do
    if python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$y" 2>/dev/null; then
      ok "$y"
    else
      bad "$y (invalid YAML)"
    fi
  done < <(find .archon/workflows \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | sort)
else
  note "(PyYAML not installed — skipped YAML parse check; install via 'pip install pyyaml')"
fi

echo "== workflow commands exist =="
while IFS= read -r cmd; do
  if [ -f ".archon/commands/$cmd.md" ]; then
    ok "$cmd"
  else
    bad "$cmd (referenced by a workflow, missing from .archon/commands/)"
  fi
done < <(grep -h '^\s*command:' .archon/workflows/*.yaml | sed 's/.*command:[[:space:]]*//' | sort -u)

echo "== artifacts exist =="
for f in .archon/team-rocket/opinions.md .archon/team-rocket/philosophy.md \
         .archon/team-rocket/failure-modes.md .archon/team-rocket/beads-dir.example; do
  if [ -f "$f" ]; then ok "$f"; else bad "$f (missing)"; fi
done

echo "== shell scripts =="
HAVE_SHELLCHECK=0; command -v shellcheck >/dev/null 2>&1 && HAVE_SHELLCHECK=1
while IFS= read -r s; do
  [ -x "$s" ] && ok "executable: $s" || bad "not executable: $s (chmod +x)"
  if [ "$HAVE_SHELLCHECK" = 1 ]; then
    if shellcheck -S warning "$s" >/dev/null 2>&1; then ok "shellcheck: $s"; else bad "shellcheck: $s"; fi
  fi
done < <(find . -name '*.sh' -not -path './.git/*' | sort)
[ "$HAVE_SHELLCHECK" = 0 ] && note "(shellcheck not installed — skipped lint; install via 'brew install shellcheck')"

echo "== archon validators =="
if command -v archon >/dev/null 2>&1; then
  while IFS= read -r wf; do
    name=$(basename "$wf" .yaml)
    if archon validate workflows "$name" 2>/dev/null | grep -qE "^\s+$name\s+ok"; then
      ok "archon validate: $name"
    else
      bad "archon validate: $name"
    fi
  done < <(find .archon/workflows -name '*.yaml' | sort)
  if archon validate commands >/dev/null 2>&1; then ok "archon validate commands"; else bad "archon validate commands"; fi
else
  note "(archon not installed — skipped its validators)"
fi

echo
if [ "$fail" = 0 ]; then echo "ALL CHECKS PASSED"; else echo "VALIDATION FAILED"; fi
exit "$fail"
