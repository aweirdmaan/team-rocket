# Changelog

All notable changes to team-rocket are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow semver.

## [1.9.0]

Driven by a field eval (2026-07-16): the plugin was interrogating the human instead of
the evidence, stalling between goals, and its "default" run mode had never actually been
installed. This release optimises for **cheap recovery** (decide, log, keep moving —
guardrails catch the dangerous cases) over **never being wrong** (always ask).

### Changed
- **Lead-driven mode is now the default run mode.** The main session drives the goal loop
  itself — compile brief → spawn James (subagent) → spawn Jessie (subagent) → iterate
  (max 3 rounds) → record → close → **continue to the next ready goal without asking**.
  Works today, nothing to install, no experimental flags. Archon is demoted to an
  optional adapter with an explicit warning that without an actual install there *is* no
  Archon mode (improvising its YAML by hand gets role-play without enforcement); the
  native Agent-Teams cluster stays experimental, with its platform caveats named.
  `rally` rewritten as the driver loop with enumerated stop conditions.
- **The plan is the authority.** James proceeds on anything the locked plan answers,
  makes-and-logs reversible calls the plan is silent on, and returns BLOCKED only for
  plan-silent irreversible/scope-changing questions. The lead absorbs BLOCKED questions
  it can answer from the plan/tracker/code; the human is the arbiter, not the first
  responder. "When To Ask vs Proceed" now runs through these filters everywhere.
- **Planning got an evidence gate.** No question reaches the human that the discovery
  output, the codebase, `TEAM-ROCKET.md`/CLAUDE.md, or the tracker history can answer;
  surviving questions carry their evidence trail ("checked X and Y; couldn't determine
  Z") or arrive as confirm/deny with the evidence attached. The lead consolidates the
  three lenses' questions (no triple-asking). Confirmed answers are **persisted to the
  tracker the moment they land**.
- **Jessie is now the verification owner, not a read-only reviewer.** Her charter:
  prove the change survives production — run it per the plan's verification setup,
  attack it (adversarial inputs, failure paths, env/region variance, repeatability),
  map every acceptance row to runtime evidence she produced herself — then review code
  quality against the spec and the named failure modes. Verdicts: SIGN-OFF / FINDINGS /
  BLOCKED. She may write **test-only** probes (declared in the verdict), never
  production code; `permissionMode: plan` dropped. James's own runtime check is now a
  smoke run — necessary evidence, not the verification of record.
- **`guardrails.sh` blocks toolchain pins by shape, not by list.** Generic patterns
  (`*.lock`, `*.lockb`, `*-lock.json`, `*-lock.yaml`, `.*-version`, `.tool-versions`,
  `*requirements*.txt`) cover new stacks automatically; the explicit basename list
  remains only for names shape can't infer, and now includes `gradle.properties`,
  `pytest.ini`, `Dockerfile.*`, `.tflint.hcl`, `.husky/`, and lefthook configs.
  Verified with a 27-case synthetic-event suite.

### Added
- **Definition of Ready: verification setup per goal.** The env, data, and commands
  that will demonstrate each goal at runtime are written into the goal at planning time
  ("setup is called out earlier") — Jessie runs the proof without asking how.
- **Post-persist plan audit** (`plan` step 6): diff the persisted tracker artefacts
  against the conversation — no duplicated entities across goals, no prose-only
  ordering (edges required), no hedged pointers where an answer was confirmed, parent
  links wired, every human answer findable in the tracker.
- **Named-spike pattern** for deferred cross-cutting decisions: own tracker issue,
  blocks only its dependents, never the epic or sibling goals.
- **Handoff comments** before a session ends (rally session-end; plan step 7): state,
  blocked-vs-not-started, uncommitted changes, deferred-not-forgotten decisions —
  resume reads them first, explicitly to avoid re-asking.
- **`blast-off` extend path**: wiring an additional repo into an existing
  `TEAM-ROCKET.md` extends it section-by-section instead of rewriting; step 8 now
  *tests* hook coverage for each detected pin file instead of assuming the list covers
  the stack; step 7 names the permissions merge as "the autonomy step" for every mode.
- Playbook Key Rules 25–29 (plan authority, evidence before interrogation, persist on
  confirmation, continue between goals, verification setup as part of Ready).

### Removed
- **The `TeammateIdle` / `Stop` echo hooks** — stdout on exit 0 is never injected for
  those events, so they were behavioural no-ops. Recording duties live in `rally`'s
  explicit per-goal and session-end steps instead.

## [1.8.0]

### Changed
- **Archon is now the default run mode; the native Agent-Teams cluster is the optional,
  experimental mode** — kept for the live-review dynamic, recommended once Agent Teams
  graduates from experimental. team-rocket runs the same lifecycle and rules either way;
  only the orchestration differs. Agent Teams is no longer a flat requirement — it's
  needed *only* for native mode. Repositioned across the README (new "Run modes" table,
  Requirements split by mode, session example labelled native), the playbook (a "Run
  modes" section; the cluster lifecycle marked as the native shape), `blast-off` (step 7
  is now "pick a run mode," Archon-first), and the Archon adapter README.

### Added
- **The shipped Archon workflow now covers the full lifecycle.** Added `land` (Definition
  of Done — every acceptance row demonstrated, light security pass, open the PR) and
  `retro` (interactive — did the plan hold up? draft the `TEAM-ROCKET.md` delta, file
  plugin proposals) nodes to `adapters/archon/workflows/team-rocket.yaml`, matching the
  `/team-rocket:land` skill.

## [1.7.0]

### Added
- **`/team-rocket:land` — the exit bookend, closing the lifecycle.** Where `plan` gates
  *entry* with a Definition of Ready, `land` gates *exit* with a **Definition of Done**:
  every locked acceptance row demonstrated (test + runtime evidence — done is shown, not
  asserted), gates green, no drift, a light security pass, on a feature branch. Then it
  integrates/opens the PR, the lead closes each goal with a reason, and a **retro closes
  the learning loop** — "did the plan hold up against its Definition-of-Ready
  predictions?" — drafting a `TEAM-ROCKET.md` delta (vocabulary, pattern-hierarchy,
  failure-modes exceptions) and filing plugin-update proposals when a pattern recurred.
- Each agent gained a "When Landing" lens (James: produce the evidence; Jessie: own the
  Definition of Done + a light security pass; Meowth: run the retro and write the delta).
  The playbook gained a Landing & Definition-of-Done section, two key rules ("done is
  shown, not asserted"; "close the learning loop"), and the land/retro step in the
  lifecycle. README and `scheme` updated so the loop reads end-to-end.

## [1.6.0]

### Changed
- **The Archon adapter now targets the *harness*, not the v1 RAG backend.** Replaced the
  1.5.0 adapter (which wired Archon's archived v1 task-management + RAG server as a
  tracker/memory backend) with an integration against Archon's current workflow engine
  (`main`). Ships `adapters/archon/workflows/team-rocket.yaml` — team-rocket's lifecycle
  (`discovery → plan with a human gate → implement loop → validate → review`) as an Archon
  workflow. Archon owns the deterministic control flow (DAG, loops, human gate, worktree
  isolation); team-rocket supplies the behaviour at each node (the roles, the relentless
  plan interrogation, the quality bar). This is the "one orchestrator, team-rocket as the
  taste" resolution to the two-harnesses overlap. The README and `blast-off` were updated;
  the YAML is a template to verify against your Archon version (its AI nodes take prompts,
  so the roles live in the prompts).

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
