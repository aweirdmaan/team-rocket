# Changelog

All notable changes to team-rocket are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow semver.

## [1.5.0]

### Added
- **Archon adapter (`adapters/archon/`).** Wires [Archon](https://github.com/coleam00/Archon)
  as a backend for team-rocket's tracker and persistent-memory abstractions over MCP —
  Archon projects/tasks as the tracker, its knowledge base + RAG as Meowth's memory and
  as grounding for the discovery step and the plan huddle's Phase 1. The RAG/knowledge
  role is the highest-value part (it's where team-rocket is thinnest by default).
- The adapter is explicit that there are **two Archons**: the current `main` is a
  TypeScript workflow engine that *overlaps* team-rocket's orchestration (an alternative
  process owner, not a backend), while the **`archive/v1-task-management-rag`** branch is
  the MCP task-management + RAG server this adapter targets. Includes setup, a
  `TEAM-ROCKET.md` wiring snippet, and the caveat to read MCP tool names off the running
  instance rather than guessing. Referenced from the README and `blast-off`.

## [1.4.1]

### Changed
- **Replaced the data-engineering-specific "EDA" prereq with a generic "Discovery"
  step.** Exploratory data analysis is data-platform jargon; the pre-implementation
  task is now framed for general software work — read the relevant code and subsystems,
  map dependencies and integration points, identify constraints and risks, map
  acceptance rows to tests. Updated the Beads story formula (step id `eda` → `discovery`),
  `scheme`, and `plan`. (Discovery is the agents' homework on the code; the plan huddle's
  Phase 1 is aligning the problem with the lead — complementary, not redundant.)

## [1.4.0]

### Changed
- **The planning huddle now puts the lead at the centre.** `/team-rocket:plan` runs
  in two phases. **Phase 1** is a relentless, text-based interrogation of the lead to
  reach a shared understanding of the problem *before* any design: vague/ambiguous
  answers are rejected and drilled into concrete, testable ones; nothing is assumed or
  inferred; agents cross-examine each other and route disagreements back to the lead as
  questions. The phase ends only when the cluster writes back a problem statement and
  **the lead confirms it in text** — no confirmation, no design. **Phase 2** is the
  existing three-lens design interrogation.
- Added a "Prime Directive" (understand before designing), a questioning protocol, a
  vague-vs-concrete table, and a Shared-Understanding gate to the skill; a matching
  Definition-of-Ready item ("problem statement confirmed by the lead in text"); and
  Phase-1 guidance in each agent's huddle section and the playbook.

## [1.3.0]

### Added
- **Planning huddle — a collaborative plan phase before implementation.** New skill
  `/team-rocket:plan` convenes the cluster in *planning mode* (no code, no branch) to
  interrogate a story from three lenses before any code exists: Meowth (prior context
  & landmines), James (buildability & scope), Jessie (testability, spec consistency,
  design quality). The lead arbitrates and locks the goals; the output must meet a
  **Definition of Ready** before `/team-rocket:rally` implements it.
- Each agent gained an "In the Planning Huddle" section describing its planning lens;
  the playbook expanded Planning Mode with the huddle + Definition of Ready and added
  the plan→ready→implement step to the session lifecycle; `scheme` now routes to
  `/team-rocket:plan` after the discovery prereq.

## [1.2.0]

### Changed
- **Quality is the explicit north star; methodology is subordinate to it.** Reframed
  the plugin so the goal is the *quality of what ships* (correct, simple, honest,
  right-sized, maintainable), not adherence to a method. `philosophy.md` now opens
  with that bar; the playbook leads with "the goal: quality, not process" and a
  "rule zero"; James and Jessie are reframed to judge the diff, not the ceremony.
- **TDD demoted from mandate to default technique.** The non-negotiable is the
  *result* — behaviour pinned by tests strong enough to fail on a real regression —
  not the test-first sequence.
- **Rituals reframed as tools, not scorecards.** The 5-whys log, the named
  failure-modes list, and the review passes are diagnostic aids to reach quality;
  use the one that's biting, skip ceremony that isn't catching anything. This makes
  the surface consistent with `philosophy.md`'s own "principles are residue" stance.

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
