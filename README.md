# Team Rocket

> *Prepare for trouble — and make it double-tested.*

A Claude Code plugin that turns your AI into a coordinated squad. Pluggable into whatever task tracker you use. The playbook keeps everyone honest.

Install once. Works everywhere. No files to maintain.

## Blast Off

```bash
claude --plugin-dir /path/to/team-rocket
```

Or make it permanent:

```bash
cp -r team-rocket ~/.claude/plugins/team-rocket
```

## The Motto

```
/team-rocket:blast-off                       # First time in a project — wires team-rocket into your stack
/team-rocket:scheme PROJ-123 "My Feature"    # Hatch a new scheme — scaffold a story
/team-rocket:plan PROJ-123                   # Plan together — interrogate the design until it's ready to build
/team-rocket:rally                           # Rally the team, pick up where you left off (implementation)
```

Or just say: *"Start a team to work on PROJ-123 and PROJ-456"*

## The Squad

Every story gets a cluster. Always. No solo missions (with one narrow exception — see the playbook).

| Agent | Role | Catchphrase |
|---|---|---|
| **James** | Writes code + tests. TDD. Atomic commits. Posts discoveries. **Pushes back on scope/design before implementing.** | *"Prepare for trouble."* |
| **Jessie** | Reviews James's code **live as he works**. Clean code, SOLID, no shortcuts. **Critiques the spec when the implementation reveals it's wrong.** Read-only. | *"And make it double."* |
| **Meowth** | The memory. Briefs the cluster, tracks everything, surfaces patterns the team would otherwise forget. | *"That's right!"* |

The **lead** (your main session) reads the work queue, spawns one James+Jessie+Meowth cluster per story, and coordinates across clusters. Multiple stories run in parallel — each cluster owns its story.

## How a Session Works

A new story is planned before it's built: `/team-rocket:plan PROJ-123` convenes the cluster in planning mode, interrogates the design from all three lenses, and brings it to a Definition of Ready. Then `rally` implements the ready plan:

```
You: /team-rocket:rally

Lead:  reads the work queue → PROJ-123 has 2 tasks, PROJ-456 has 1 task
       "Spawning two clusters."

       Cluster 1 (PROJ-123):
         james-123, jessie-123, meowth-123
       Cluster 2 (PROJ-456):
         james-456, jessie-456, meowth-456

meowth-123: briefs cluster from prior task notes + persistent memories
james-123 + jessie-123 work in real time:
  james pauses to flag a scope concern → lead resolves
  james writes code → jessie reviews live → "this assertion is too weak" → james fixes
  jessie spots a shared-DTO smell → escalates to lead
  goal complete → meowth records this goal

meowth-456 + cluster 2: working in parallel on PROJ-456

You: "wrap up"
Both meowths: post final session summaries; lead closes finished work.
```

## What's Inside

```
team-rocket/
├── .claude-plugin/plugin.json        # Manifest (declares agents, skills, hooks)
├── agents/
│   ├── james.md                      # The implementer (with pushback + verify rules)
│   ├── jessie.md                     # The reviewer (with design-critique role)
│   └── meowth.md                     # The memory (active, not passive)
├── skills/
│   ├── blast-off/SKILL.md            # /team-rocket:blast-off — wire into your stack
│   ├── scheme/SKILL.md               # /team-rocket:scheme — scaffold a story
│   ├── plan/SKILL.md                 # /team-rocket:plan — planning huddle → ready plan
│   └── rally/
│       ├── SKILL.md                  # /team-rocket:rally — resume a session
│       ├── playbook.md               # Process: modes, lifecycle, guardrails, fan-out
│       ├── philosophy.md             # The simplicity lens + 5-whys (the "why")
│       ├── failure-modes.md          # Canonical named code smells
│       └── examples.md               # Bad/good code pairs per smell
├── hooks/
│   ├── hooks.json                    # PreToolUse guardrails + idle/stop reminders
│   └── guardrails.sh                 # Deterministic enforcement of the hard rules
├── adapters/
│   └── beads/                        # OPTIONAL Beads tracker adapter (opt-in)
│       ├── hooks.json, on_create.sh, on_close.sh, story.formula.json, README.md
├── scripts/validate.sh               # Self-checks (JSON, manifest, hooks, shellcheck)
├── Makefile                          # `make validate`
├── settings.json                     # Template: Agent Teams env + permission allow-list
├── global-settings.json              # Template: tighter read-mostly permission set
├── LICENSE · CHANGELOG.md
└── README.md                         # You are here
```

> **Settings don't auto-apply.** A plugin manifest can't ship user/project settings, so
> `settings.json` is a *template*. To run clusters you must enable Agent Teams
> (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) and merge the permission allow-list into your
> own `.claude/settings.json`. `/team-rocket:blast-off` walks you through it.

## The Playbook (Highlights)

### Quality is the goal, not process

The practices below — TDD, atomic commits, the 5-whys, named failure modes, live review — exist to produce one thing: **amazing code** (correct, simple, honest, right-sized, maintainable). They're means, not the scorecard. When a practice isn't serving the quality of the change, the quality wins. Process-compliant mediocrity is a failure — the diff is judged, not the ceremony.

### Stories have layers

| Layer | Question | Where it lives |
|---|---|---|
| **WHY** | Why does this matter? | Story/goal description |
| **WHAT** | What does done look like? | Acceptance criteria |
| **HOW** | How do we build it? | Implementation task design |

Goals (WHY + WHAT) are locked once approved. Implementations (HOW) can iterate — supersede the old with the new.

### Two speeds

**Planning** — no code. The cluster convenes in a *planning huddle* (`/team-rocket:plan`) and interrogates the design from three lenses — memory (Meowth), buildability (James), testability (Jessie) — until it meets a Definition of Ready. Catching design problems here is far cheaper than catching them mid-implementation. When you're not sure, you're in this mode.

**Implementation** — ship amazing code; TDD is the default route there, not the goal. Refine the design with the lead first. Tests and code together, strong enough to fail on a real regression. Atomic commits. Pre-commit gates must pass before anything is "done."

### Push back is normal

The cluster's job is not "convert prompt to code." Both James and Jessie are expected to surface concerns:

- One requirement forcing multi-file/multi-layer changes? Pause and ask.
- Implementation needs a workaround (reflection, type bypass, framework escape hatch)? Surface as a design question.
- Change to a shared component to serve a local need? Propose scoped alternative.
- Conflict with a queued-up future change? Flag.
- Test assertions that can't catch plausible regressions? Demand stronger ones.

### Environment guardrails (hard rules)

- No edits to build files, CI config, or toolchain pins to make local environment work.
- No pushes to default branches (`main` / `master` / `develop`).
- No bypassing pre-commit / CI gates.
- No new dependencies without surfacing.
- No destructive ops on shared state without explicit lead approval.

Most of these aren't just prose — the `PreToolUse` hook (`hooks/guardrails.sh`) **enforces**
them: it blocks pushes/force-pushes to default branches, committing/pushing while on one,
`--no-verify`, and edits to build/CI/toolchain files, regardless of what any agent decides.
The escape hatch is a human running the command directly in the terminal (a `!`-prefixed
shell line is not a tool call, so it isn't intercepted).

### Nothing is forgotten

Session history lives on the tasks themselves. Discoveries, failed approaches, manual changes, review outcomes — all recorded incrementally as each goal completes (not batched to session end). Meowth surfaces patterns: recurring smells, repeated failures, scope creep, environment drift.

### Decisions are tracked

Real architectural choices get recorded with options-considered, choice-made, trade-offs-accepted, and the date. Linked to the implementations they shape.

## Plugging Into Your Stack

Team Rocket is tool-agnostic. The agent definitions don't reference any specific tracker, source-control host, or CI provider. `/team-rocket:blast-off` is the adapter — it detects what your project uses (Jira, Linear, GitHub Issues, GitLab, a local DB, or a markdown file) and writes a `TEAM-ROCKET.md` at the project root so the lead has one reference.

Supported via convention:
- Any tracker that supports a 3-level hierarchy (story / goal / implementation) or can simulate one via labels.
- Any source control with feature-branch workflow.
- Any CI / pre-commit setup.

The lead's job is to thread the specific commands into spawn prompts. The agents' job is to follow the behavioural rules regardless.

**Core stays agnostic; tracker specifics live in adapters.** Anything that hard-codes a tool (e.g. `bd` commands, a Beads formula, Beads event hooks) lives under `adapters/` as opt-in, not in the always-loaded core. A reference **Beads** adapter ships in `adapters/beads/`; write your own for Jira / Linear / GitHub Issues by mirroring it.

## Requirements

- [Claude Code](https://claude.ai/code) v2.1.32+
- **Agent Teams enabled** — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. This is an
  experimental, gated surface (live inter-agent messaging). Clusters can't spawn without
  it; if you can't enable it, you can still use the skills/guardrails/playbook solo, just
  without the parallel James+Jessie+Meowth pattern.
- A task tracker of your choice (the plugin doesn't bundle one; a Beads adapter ships in
  `adapters/beads/`)
- A source-control workflow with a default branch agents stay off of

---

*To protect the codebase from devastation. To unite all tests within our nation.*
