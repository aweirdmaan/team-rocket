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
/team-rocket:land PROJ-123                   # Land the story — verify Definition of Done, PR, close, retro
```

Or just say: *"Start a team to work on PROJ-123 and PROJ-456"*

## Run modes

team-rocket runs the same lifecycle and the same behavioural rules three ways — and **lead-driven is the default**:

| Mode | Orchestration | Status | Use when |
|---|---|---|---|
| **Lead-driven (default)** | Your main session drives the goal loop: it compiles briefs and records goals, and spawns **James and Jessie as ordinary subagents per goal** (implement → verify → iterate → close → next). | **Works today.** Nothing to install, no experimental flags. | Default — pick this. |
| **Native cluster (experimental)** | The lead spawns a live James + Jessie + Meowth cluster, so Jessie reviews **live as James works**. | Needs `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Known caveats: no session resumption for teammates, task-status lag, idle teammates. | Once Agent Teams is GA — for the live-review dynamic. |
| **Archon (optional adapter)** | The [Archon](https://github.com/coleam00/Archon) harness runs the lifecycle as a workflow (`adapters/archon/`); roles live in node prompts. | Requires actually installing Archon **and** copying the workflow into `.archon/workflows/`. The YAML is a template to adapt, not a guaranteed-valid file. | You already run Archon and want it to own control flow across projects. |

**If Archon isn't installed, there is no Archon mode** — don't improvise the lifecycle from its YAML; that gets you a single session role-playing a process with none of its enforcement. Lead-driven mode is the same lifecycle with your session as the driver, and it's what `/team-rocket:rally` implements. The roles, the planning interrogation, the quality bar, and the Definition of Done are identical in all three modes — only *who drives the steps* differs.

## The Squad

Every story gets a cluster. Always. No solo missions (with one narrow exception — see the playbook).

| Agent | Role | Catchphrase |
|---|---|---|
| **James** | Writes code + tests. TDD. Atomic commits. Posts discoveries. **The locked plan is his authority** — he pushes back on what it doesn't answer, and proceeds on what it does. | *"Prepare for trouble."* |
| **Jessie** | **Proves the change survives production**: runs it, attacks it with adversarial inputs and failure paths, maps every acceptance row to runtime evidence — and reviews code quality against the spec. Writes test-only probes, never production code. | *"And make it double."* |
| **Meowth** | The memory duties: briefs, per-goal records, pattern surfacing. In lead-driven mode the lead performs them; in native mode Meowth runs as its own agent. | *"That's right!"* |

The **lead** (your main session) drives the loop: reads the work queue, spawns James and Jessie per goal, **answers their questions from the plan/tracker/code before anything reaches you**, records and closes each goal, and moves to the next without stopping to ask. You are the arbiter for scope changes and irreversible calls — not a checkpoint between steps.

## How a Session Works

A new story is planned before it's built: `/team-rocket:plan PROJ-123` convenes the cluster in planning mode, interrogates the design from all three lenses, and brings it to a Definition of Ready. Then `rally` implements the ready plan — and `/team-rocket:land` closes it: verify the Definition of Done (every acceptance row *demonstrated*, not asserted), open the PR, close with reasons, and run a retro that asks "did the plan hold up?" and feeds what it learns back into the team's memory and the plugin.

The example below shows **lead-driven mode** (the default):

```
You: /team-rocket:rally

Lead:  reads the work queue → PROJ-123 has 3 ready goals
       compiles the brief for goal 1 (WHY/WHAT/HOW, prior discoveries,
         failed approaches, verification setup, boundaries)

       spawns james (subagent) → implements, commits, smoke-runs
         james returns BLOCKED: "requirement X forces a shared-DTO change"
         lead checks the locked plan → the plan chose the scoped alternative
         lead re-spawns james with the answer (you never saw the question)

       spawns jessie (subagent) → runs the job, attacks edge cases,
         reviews the diff → FINDINGS: "assertion too weak at file:line"
       spawns james with the findings → fixed
       spawns jessie → SIGN-OFF (every acceptance row: test + run evidence)

       records goal 1 on the tracker, closes it with a reason
       → continues STRAIGHT to goal 2. No "shall I continue?"

       ...goal 3 hits a genuine scope question the plan is silent on
       → NOW you get asked. One question, evidence attached.

You: answer it once — it's persisted to the tracker, never asked again.
Lead: finishes, posts the session summary + handoff comment, closes out.
```

## What's Inside

```
team-rocket/
├── .claude-plugin/plugin.json        # Manifest (declares agents, skills, hooks)
├── agents/
│   ├── james.md                      # The implementer (with pushback + verify rules)
│   ├── jessie.md                     # The verifier (production confidence + review)
│   └── meowth.md                     # The memory (active, not passive)
├── skills/
│   ├── blast-off/SKILL.md            # /team-rocket:blast-off — wire into your stack
│   ├── scheme/SKILL.md               # /team-rocket:scheme — scaffold a story
│   ├── plan/SKILL.md                 # /team-rocket:plan — planning huddle → ready plan
│   ├── land/SKILL.md                 # /team-rocket:land — Definition of Done + retro → closed
│   └── rally/
│       ├── SKILL.md                  # /team-rocket:rally — resume a session
│       ├── playbook.md               # Process: modes, lifecycle, guardrails, fan-out
│       ├── philosophy.md             # The simplicity lens + 5-whys (the "why")
│       ├── failure-modes.md          # Canonical named code smells
│       └── examples.md               # Bad/good code pairs per smell
├── hooks/
│   ├── hooks.json                    # PreToolUse guardrails
│   └── guardrails.sh                 # Deterministic enforcement of the hard rules
├── adapters/                         # OPTIONAL integrations (opt-in)
│   ├── beads/                        #   Beads tracker adapter (hooks + story formula)
│   └── archon/                       #   Archon harness — team-rocket's process as an Archon workflow
├── scripts/validate.sh               # Self-checks (JSON, manifest, hooks, shellcheck)
├── Makefile                          # `make validate`
├── settings.json                     # Template: Agent Teams env + permission allow-list
├── global-settings.json              # Template: tighter read-mostly permission set
├── LICENSE · CHANGELOG.md
└── README.md                         # You are here
```

> **Settings don't auto-apply.** A plugin manifest can't ship user/project settings, so
> `settings.json` is a *template*. **In every mode**, merge the permission allow-list into your
> own `.claude/settings.json` — without it, agents stall on permission dialogs and "autonomous"
> means "asks you to approve every command". The `env` block
> (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) is needed for **native cluster mode only**.
> `/team-rocket:blast-off` walks you through both.

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

**Planning** — no code. The cluster convenes in a *planning huddle* (`/team-rocket:plan`). It interrogates the problem until everyone shares one mental model — but through an **evidence gate**: anything the codebase, the tracker, or `TEAM-ROCKET.md` can answer never reaches you; what does reach you arrives consolidated, with the evidence trail attached, and vague answers get drilled into concrete, testable ones. Nothing proceeds until you confirm the written problem statement, and every answer you give is persisted to the tracker the moment you give it — you will not be asked twice. Only then does it interrogate the *design* from three lenses — memory (Meowth), buildability (James), testability + verification setup (Jessie) — until it meets a Definition of Ready. Catching a misunderstood problem here is far cheaper than discovering it mid-implementation. When you're not sure, you're in this mode.

**Implementation** — ship amazing code; TDD is the default route there, not the goal. Refine the design with the lead first. Tests and code together, strong enough to fail on a real regression. Atomic commits. Pre-commit gates must pass — and the story is only finished when it's *landed* against a Definition of Done (every acceptance row demonstrated) and a retro has asked whether the plan held up.

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

**Core stays agnostic; tool specifics live in adapters.** Anything that hard-codes a tool lives under `adapters/` as opt-in, not in the always-loaded core:

- **Beads** (`adapters/beads/`) — a local task-tracker adapter (`bd` event hooks + a story formula). Write your own for Jira / Linear / GitHub Issues by mirroring it.
- **Archon** (`adapters/archon/`) — runs team-rocket's process on the [Archon](https://github.com/coleam00/Archon) **harness** (workflow engine). Archon owns the deterministic control flow (DAG, loops, human gate, worktree isolation); team-rocket supplies the behaviour at each node. One orchestrator, team-rocket as the taste.

## Requirements

- [Claude Code](https://claude.ai/code) v2.1.32+ — that's all the default (lead-driven) mode needs.
- **For native cluster mode only (experimental):** Agent Teams enabled — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. This gated surface (live inter-agent messaging) is what lets the lead spawn the live cluster. Recommended once it's GA.
- **For the Archon adapter only:** [Archon](https://github.com/coleam00/Archon) installed (Bun, Claude Code, GitHub CLI) and the workflow copied into `.archon/workflows/`. See `adapters/archon/`.
- A task tracker of your choice (the plugin doesn't bundle one; a Beads adapter ships in
  `adapters/beads/`)
- A source-control workflow with a default branch agents stay off of

---

*To protect the codebase from devastation. To unite all tests within our nation.*
