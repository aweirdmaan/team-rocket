# Beads adapter

Team Rocket's core is tool-agnostic. This directory holds the **Beads** ([bd](https://github.com/steveyegge/beads)) reference implementation of the tracker-specific pieces. None of it is loaded automatically — wire in only what you use.

## What's here

| File | What it is | How to wire it |
|------|------------|----------------|
| `story.formula.json` | A `mol-story` formula that scaffolds the story → goal → implementation hierarchy (used conceptually by `/team-rocket:scheme`). | Place where your `bd` formula loader looks (e.g. `.beads/formulas/`), then invoke via your formula tooling. |
| `on_create.sh` | Beads **event** hook: rejects goals/epics without WHY + WHAT. | Register as a Beads `on_create` hook (Beads' own hook system — **not** Claude Code). Make executable: `chmod +x on_create.sh`. |
| `on_close.sh` | Beads **event** hook: requires a close reason; nudges for a session summary. | Register as a Beads `on_close` hook. `chmod +x on_close.sh`. |
| `hooks.json` | **Claude Code** SessionStart / PreCompact hooks that run `bd prime`. | Merge these entries into your project `.claude/settings.json`. The plugin manifest only loads the core, tool-agnostic hooks. |

## Why these aren't in the plugin core

The plugin describes itself as tracker-agnostic, so anything that hard-codes `bd` lives here as an opt-in adapter rather than in the always-loaded core. If you use Jira / Linear / GitHub Issues / a flat file instead, write the equivalent adapter for your tracker and ignore this one. `/team-rocket:blast-off` detects your tracker and tells the lead which adapter (if any) applies.
