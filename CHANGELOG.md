# Changelog

All notable changes to team-rocket are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow semver.

## [1.1.0]

### Fixed
- **Manifest wiring.** `plugin.json` now declares `hooks` so the hook set actually
  loads, and the invalid `settings.json` manifest key (which never applied) was
  removed. Enabling Agent Teams + permissions is now a documented manual step.
- **Hardcoded install paths.** James / Jessie / Meowth no longer hardcode
  `~/.claude/plugins/team-rocket/...`; they resolve the plugin via
  `$CLAUDE_PLUGIN_ROOT` and fall back to `TEAM-ROCKET.md` absolute paths.
- **Orphaned debug code.** Removed the unconditional `/tmp/beads-on-close-debug.log`
  write from the close hook.
- **Stale README.** "What's Inside" tree now reflects the real file layout.

### Added
- **Deterministic guardrails.** `hooks/guardrails.sh` (a `PreToolUse` hook) blocks
  pushes/force-pushes to default branches, committing/pushing on a default branch,
  `--no-verify`, and edits to build/CI/toolchain files — enforcing the "hard rules"
  mechanically instead of by prose alone.
- **Behaviour-verification loop.** Implementer and reviewer now require running the
  change and observing runtime behaviour, not just green tests.
- **Session-end `Stop` hook** and a generic (tracker-agnostic) `TeammateIdle` reminder.
- **Cost / models / fan-out** guidance in the playbook (concurrency caps, model tiers,
  no nested clusters).
- `LICENSE` (MIT) and this `CHANGELOG`.
- **Self-validation.** `scripts/validate.sh`, `Makefile`, and a CI workflow that lint
  JSON, shellcheck hooks, and sanity-check the manifest.

### Changed
- **Tool-agnostic core + adapters.** Beads-specific pieces (`on_create.sh`,
  `on_close.sh`, `story.formula.json`, `bd prime` session hooks) moved to
  `adapters/beads/` with their own README. The core ships nothing tracker-specific.
- `failure-modes.md` now notes that its examples are Scala-flavoured and how to
  translate the smells to other languages; example domains are neutral/illustrative.

## [1.0.0]
- Initial release: three-agent cluster pattern (James / Jessie / Meowth), the rally /
  scheme / blast-off skills, philosophy + failure-modes + examples, and Beads hooks.
