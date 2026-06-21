#!/usr/bin/env bash
# Team Rocket — self-validation. Run before committing plugin changes.
#   - every *.json parses
#   - plugin.json has the required keys and points at files that exist
#   - plugin.json does NOT carry the invalid "settings.json" manifest key
#   - every *.sh is shellcheck-clean (if shellcheck is installed) and executable
#   - hooks.json references guardrails.sh
#
# Exit 0 = all checks pass. Exit 1 = at least one failure.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
fail=0
note() { printf '  %s\n' "$1"; }
ok()   { printf 'PASS  %s\n' "$1"; }
bad()  { printf 'FAIL  %s\n' "$1"; fail=1; }

echo "== JSON parses =="
while IFS= read -r f; do
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    ok "$f"
  else
    bad "$f (invalid JSON)"
  fi
done < <(find . -name '*.json' -not -path './.git/*' | sort)

echo "== plugin.json manifest =="
MAN=".claude-plugin/plugin.json"
for key in name version description agents hooks skills; do
  if python3 -c "import json,sys; d=json.load(open('$MAN')); sys.exit(0 if '$key' in d else 1)"; then
    ok "has key: $key"
  else
    bad "missing key: $key"
  fi
done
if python3 -c "import json,sys; d=json.load(open('$MAN')); sys.exit(1 if 'settings.json' in d else 0)"; then
  ok "no invalid 'settings.json' manifest key"
else
  bad "'settings.json' is not a valid manifest key — remove it"
fi
# Referenced files exist.
HOOKS_REF=$(python3 -c "import json; print(json.load(open('$MAN')).get('hooks',''))")
if [ -n "$HOOKS_REF" ] && [ -f "$HOOKS_REF" ]; then ok "hooks file exists: $HOOKS_REF"; else bad "hooks file missing: $HOOKS_REF"; fi
while IFS= read -r a; do
  if [ -f "$a" ]; then ok "agent exists: $a"; else bad "agent missing: $a"; fi
done < <(python3 -c "import json; [print(x) for x in json.load(open('$MAN')).get('agents',[])]")

echo "== hooks wiring =="
if grep -q 'guardrails.sh' hooks/hooks.json; then ok "hooks.json references guardrails.sh"; else bad "hooks.json does not reference guardrails.sh"; fi

echo "== shell scripts =="
HAVE_SHELLCHECK=0; command -v shellcheck >/dev/null 2>&1 && HAVE_SHELLCHECK=1
while IFS= read -r s; do
  [ -x "$s" ] && ok "executable: $s" || bad "not executable: $s (chmod +x)"
  if [ "$HAVE_SHELLCHECK" = 1 ]; then
    if shellcheck -S warning "$s" >/dev/null 2>&1; then ok "shellcheck: $s"; else bad "shellcheck: $s"; fi
  fi
done < <(find . -name '*.sh' -not -path './.git/*' | sort)
[ "$HAVE_SHELLCHECK" = 0 ] && note "(shellcheck not installed — skipped lint; install via 'brew install shellcheck')"

echo
if [ "$fail" = 0 ]; then echo "ALL CHECKS PASSED"; else echo "VALIDATION FAILED"; fi
exit "$fail"
