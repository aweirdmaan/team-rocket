# Team Rocket — The Playbook

Team Rocket is an opinionated three-agent cluster pattern for multi-session software work. It's tool-agnostic: pair it with whichever task tracker (issue tracker, ticket system, work queue) and source control your project uses. The lead — you — wires the cluster into your toolchain. The agents themselves follow the same behavioural rules regardless of the surrounding stack.

## The goal: quality, not process

Everything in this playbook — modes, TDD, atomic commits, the review passes — exists to produce one thing: **amazing code** (correct, simple, honest, right-sized, maintainable; the bar is defined in `philosophy.md`). The practices are means to that end, not the end. When a practice serves the quality of the change, use it; when it doesn't, quality wins. Shipping process-compliant mediocrity is a failure, not a success. **Judge the diff, not the ceremony.**

## Companion documents

This playbook covers *process* — modes, lifecycle, coordination, environment guardrails. Two companion files cover *taste*:

- **`philosophy.md`** — the simplicity-as-cognitive-load lens, the 5-whys protocol, the "principles are residue of right questions" framing. Read this first; every behavioural rule in this playbook is a consequence of applying that lens.
- **`failure-modes.md`** — the canonical list of named code smells (dispatch tags, useless wrapper case classes, defensive guards, etc.). The shared vocabulary that reviewer feedback and pattern surfacing use.
- **`examples.md`** — concrete bad/good code pairs for each named failure mode. Use when prose argument isn't landing.

James, Jessie, and Meowth all reference these companion files. They are the *source* of the rules below.

The project-level `TEAM-ROCKET.md` (created by `blast-off`) records the project-specific complement: codebase vocabulary, pattern hierarchy, test conventions, and exceptions to the failure-modes list. Agents read both — the universal philosophy + the project-specific overlay.

## The Cast

| Role | Purpose |
|---|---|
| **Lead** (the human + their main session) | Reads the work queue, makes scope/design decisions, spawns clusters, coordinates across stories, closes work. |
| **James** | TDD implementer. Writes production code and tests together. Pushes back when scope/design feels wrong. |
| **Jessie** | Live reviewer. Enforces clean code and TDD *and* critiques the design when the implementation reveals the spec is wrong. Read-only. |
| **Meowth** | Active memory. Briefs the cluster, records each goal as it completes, surfaces patterns the team would otherwise forget. |

## Story Shape (Tool-Agnostic)

You can use any tracker. The shape stays the same:

```
story (the umbrella)
├── prereqs (enablers that unblock goals)
├── goals (WHY + WHAT — what success means)
│   └── implementations (HOW — the technical approach)
├── architecture decisions (records of trade-offs)
└── backlog items (low-priority, non-blocking)
```

Each goal carries:
- **WHY** — why the work matters (one paragraph)
- **WHAT** — acceptance criteria (testable, binary outcomes)
- **HOW** — the technical sketch (in the implementation item, not the goal)
- **Notes** — context, blockers, manual changes, gotchas

Goals are immutable once approved. Implementations can iterate (supersede the old one when the approach changes).

## Modes

### Planning Mode
- **No production code.** Only work-tracker artefacts.
- Write goal descriptions, acceptance, design sketches.
- For design decisions: propose options, let the lead pick, record the rejected ones with the reason.
- **Plan as a cluster, before you build.** Planning is not a solo lead activity — convene the full cluster in a *planning huddle* (`/team-rocket:plan`) so the design is interrogated from three perspectives before a line of code exists. See below.

#### The Planning Huddle

Before a story goes to implementation, the cluster plans together. Each role interrogates the draft from its own lens — the goal is to find the holes now, when they're cheapest to fix, not mid-implementation:

- **Meowth — prior context & landmines.** Relevant conventions/vocabulary, prior discoveries, and prior *failed* approaches so the plan doesn't repeat a known dead end.
- **James — buildability & scope.** Can it be built without a workaround? Does one acceptance row force a multi-file/multi-layer change? What's unknown? What's the simplest thing that satisfies the acceptance?
- **Jessie — testability, spec consistency, design quality.** Can she name a concrete regression a test would catch for each row? Are the rows consistent? Does the design carry speculative generality or a premature abstraction?

The lead arbitrates, records decisions, and **locks the goals (WHY + WHAT)** once approved; the HOW stays negotiable. Output: a plan that meets the **Definition of Ready** —

- WHY clear (one paragraph); WHAT testable and INVEST-shaped; both locked.
- HOW sketched with concrete file/component pointers, mirroring the codebase's current pattern.
- Jessie can name a regression a test would catch for each acceptance row.
- James confirms no workaround needed and blast radius is proportionate.
- No prior failed approach is being repeated.
- Every unknown is resolved or scoped into a named spike.
- No unresolved design smell or contradiction between rows.
- File-ownership boundaries identified.

Don't lock a goal you can't test, and don't hand a raw, un-interrogated design to implementation. But timebox it: the huddle makes the plan *ready*, not *perfect* — unresolved unknowns become spikes, not blockers.

### Implementation Mode
- **Refine before coding.** Re-read the design with the lead. Surface concerns before writing the first test.
- **Tests and code together (TDD by default).** The non-negotiable is the *result* — behaviour that matters pinned by tests strong enough to fail on a real regression. Test-first is the default route there; what's graded is the code and its tests, not the order they were typed.
- **Refactor while you work.** Constantly improve structure without changing behaviour.
- **Atomic commits.** Small, working, leave the codebase green.
- **Pre-commit / lint / CI gates must pass.** Zero failures before you call work done.
- **Verify behaviour, not just tests.** When the change is observable at runtime (a command, endpoint, job, or UI path), run it and observe what it actually does before calling it done. Green tests prove assertions; running the thing proves it works. The reviewer demands the run evidence, not just a passing suite.

## Cluster vs Solo

**Clusters are the default. Solo is a deliberate call, not an omission.**

Solo is allowed only when ALL THREE hold:
- One file.
- No new design decisions.
- The lead just worked in that file (within the last few turns) and has full context.

Otherwise: cluster.

## Cost, Models, and Fan-Out

Clusters multiply agents fast: one cluster is three agents, and N parallel stories is 3N. Be deliberate about it.

- **Concurrency cap.** Don't run more parallel clusters than you can actually track. Two or three stories in flight is usually the ceiling for a single lead; beyond that, coordination overhead and write contention eat the parallelism gains. Queue the rest.
- **Model selection** (per the agent definitions, overridable per spawn):
  - **James (implementer)** and **Jessie (reviewer)** default to a strong mid-tier model. For genuinely hard design or subtle review, the lead can spawn them on the top-tier model for that story.
  - **Meowth (memory)** defaults to a fast, cheap model — it transcribes, briefs, and pattern-matches; it doesn't reason about code.
- **No nested clusters.** James and Jessie carry the `Agent` tool only for read-only `Explore`-style searches over unfamiliar code. They must not spawn their own implementers/reviewers or sub-clusters. Fan-out is the lead's job, so the agent count stays bounded and legible.
- **Kill idle clusters.** A cluster whose goal is closed should be shut down ("Cluster done."), not left running. Idle agents still hold context and cost.

## Session Lifecycle

```
Session starts
    │
    ▼
Lead: read the work queue → find actionable work
    │
    ▼
Lead: read each candidate task → WHY, WHAT, HOW, prior history
    │
    ▼
Is the plan implementation-ready? ──no──▶ PLANNING HUDDLE (/team-rocket:plan)
    │                                       cluster interrogates from 3 lenses;
    │                                       lead locks goals; meets Definition of Ready;
   yes                                      planning cluster shuts down
    │  ◀──────────────────────────────────────────┘
    ▼
Lead: spawn three agents (James + Jessie + Meowth) simultaneously per story  (IMPLEMENTATION)
    │
    ▼
Meowth briefs the cluster from prior task notes + persistent memories
    │
    ▼
For each goal in the story:
  ┌──────────────────────────────────────────────────────┐
  │ James + Jessie work in PARALLEL:                     │
  │   James writes code → Jessie reviews live →          │
  │   Jessie pushes back (code-quality + design) →       │
  │   James addresses / pushes back further              │
  │                       ↓                              │
  │ Either side can pause and escalate to the lead       │
  │ for scope/design questions. Don't grind through.     │
  │                       ↓                              │
  │ Goal done → Meowth records THIS goal                  │
  │   (Meowth NEVER closes — only records)               │
  │                       ↓                              │
  │ LEAD closes the goal with a reason                    │
  │                       ↓                              │
  │ LEAD sends "Cluster done." → all three self-terminate │
  └──────────────────────────────────────────────────────┘
    │
    ▼
Next goal → spawn a fresh cluster
All goals done → Meowth posts a final session summary on the story
```

## When To Ask vs Proceed

The same decision tree applies to all agents (and the lead).

**Always ask first:**
- Scope feels disproportionate to the requirement. (One acceptance row forcing multi-file / multi-layer changes.)
- The implementation needs a workaround (reflective trick, type-system bypass, framework escape hatch).
- A shared component is being changed to serve a local need.
- The design conflicts with something downstream (future story, sibling component).
- Multiple valid approaches with non-trivial trade-offs.
- Potential breaking changes (API contracts, schemas, public interfaces).
- New dependencies, frameworks, or architectural patterns.
- Destructive operations (force-push, history rewrite, dropping data).
- Changes to default-branch state, CI, or deployed configuration.

**Safe to proceed (mention in completion summary):**
- Obvious bugs and typos.
- Test updates that follow code changes.
- Reusing patterns already in the codebase.
- Dead-code removal.
- Renames within a single file.

**When in doubt: ask.** A clarifying message is cheap; an over-built implementation is expensive.

## Scope-Creep Recognition

These are the patterns that mean "stop, check with the lead before continuing":

1. **One requirement, many files.** If satisfying one acceptance row demands changes to a DTO, a controller hook, a validator, and a service, the design is wrong-sized.
2. **The workaround tax.** When you reach for sneaky-throw, reflection, type bypass, or "this works only because X happens to be true" — surface it as a design question, not an implementation detail.
3. **Cross-cutting collateral.** A change to a shared component to serve one endpoint usually creates a dual-contract smell. Local/scoped alternative + explicit question to the lead.
4. **Future-story conflict.** Spec says X; you know a queued-up future change is going to undo X. Flag the conflict before writing code that gets thrown away.
5. **Test infrastructure forcing weak assertions.** If the only way to pass a test is to mock out the behaviour being tested, or assert `isArray()` instead of a value, the spec or the test framing is wrong.
6. **Disagreement between acceptance rows.** Two rows pulling in different directions = the spec is the bug.

Any agent can call any of these. Lead resolves.

## Environment Guardrails

Hard rules. The lead can override per-case, but agents do not override these on their own. Several of these are also **enforced deterministically** by the plugin's `PreToolUse` guardrail hook (`hooks/guardrails.sh`) — it blocks pushes to default branches, force-pushes to them, `--no-verify`, and edits to build/CI/toolchain files regardless of what an agent decides. The hook is a backstop; agents must still follow the rules so they never hit it. To intentionally bypass (lead only), run the command directly in the terminal — a human shell line is not a tool call and isn't intercepted.

- **Never modify build files, CI config, or toolchain pins** (`build.gradle`, `pom.xml`, `package.json` engines, `pyproject.toml`, `.tool-versions`, `mise.toml`, `Dockerfile`, CI workflow files) to make a local environment work. Local-environment mismatch is an environment problem, not a project problem.
- **Never push to default branches.** Always work on a feature branch. Confirm branch state before any commit.
- **Never bypass pre-commit / CI gates** (no `--no-verify`, no skipping linters, no commenting out failing tests).
- **Never introduce new dependencies, frameworks, or external services** without surfacing them.
- **No destructive operations on shared state** without explicit lead approval for the specific operation (force-push, history rewrite, dropping data, deleting branches).

## Architecture Decisions

When a real architectural choice gets made, record it. The team's tracker should have a "design / decision" surface — use it. Capture: options considered, choice made, trade-offs accepted, and the date / context (so a future reader can decide if the decision is still valid).

Link decision records to the implementations they shape.

## Iteration Without Editing History

When an approach changes mid-implementation, supersede — don't rewrite. Create a new implementation item, link the old one as superseded, with the new design and the reason for the change. Closed work stays closed with its history intact.

## Worklog Convention

Session history lives as comments on tasks, not separate files. Each goal gets a comment after completion with:

```
Goal complete YYYY-MM-DD:
  Progress: [x] item1 [x] item2 [ ] item3
  Discoveries: key insight 1; key insight 2
  Failed: approach X didn't work because Y
  Manual / environment changes: ...
  Architecture: any design decisions or patterns established this goal
  Next: what to do when resuming
```

Cross-cutting insights (things future sessions on different tasks need) go into the team's persistent-memory mechanism (whatever your tracker supports — memory store, wiki, project README).

## Commit Discipline

- Always include the task / issue identifier in the commit message.
- Imperative mood, present tense, subject under 50 characters.
- Body explains *why* for non-trivial changes.
- One logical change per commit. Codebase compiles and tests pass at every commit.

## Coordination Patterns

- **Write contention on the work tracker.** Many trackers serialise writes per task. Sequentialise updates within a cluster — historian writes first, implementer second.
- **File ownership across clusters.** Each cluster owns its story's file set. No cross-cluster edits. If a cluster discovers it needs a file owned by another cluster, surface it to the lead.
- **Multiple clusters in parallel.** Spawn one cluster per story. Name agents by story (e.g. `james-PROJ-123`, `jessie-PROJ-123`, `meowth-PROJ-123`) so messages route correctly.
- **Cluster shutdown.** One "Cluster done." message from the lead triggers all three agents to self-terminate. Don't send three individual shutdowns.

## Key Rules

**Rule zero — the one the rest serve: ship amazing code** (correct, simple, honest, right-sized, maintainable; see `philosophy.md`). Every rule below is a means to that end. When a rule and the quality of the change disagree, quality wins — and process-compliant mediocrity is still a failure.

1. **Read the work queue first**, always — it's the source of truth for what's actionable.
2. **Goals are immutable.** Change the HOW, not the WHY.
3. **Goals use INVEST:** Independent, Negotiable, Valuable, Estimable, Small, Testable.
4. **Post discoveries immediately** — incremental beats batch.
5. **Failed approaches are first-class** — they save future sessions from repeating dead ends.
6. **No code in planning mode** — only tracker artefacts.
7. **Refine before coding** — re-read the design with the lead first.
8. **Manual / environment changes are tracked** — anything done outside code gets recorded.
9. **Close with a reason** — every close gets a reason. Only the lead closes.
10. **Supersede, don't edit closed work** — history stays intact.
11. **Architecture decisions are tracked artefacts** — not tribal knowledge.
12. **Pre-commit / CI gates must pass** before claiming work done.
13. **Serialise writes** on whatever your tracker requires; retry on lock errors; don't parallelise blindly.
14. **Meowth never closes** — Meowth records; lead decides.
15. **Clusters are default; solo is deliberate** — solo only when one file, no design decisions, lead just worked there.
16. **Surface design smells, don't grind through them** — sneaky-throw, shared-DTO mutation, multi-file blast radius all warrant a pause and a question.
17. **Environment guardrails are hard rules** — no build-file edits, no default-branch pushes, no gate bypasses without lead override.
18. **Assertions must catch plausible regressions** — if you can't articulate a regression an assertion would catch, the assertion is missing.
19. **Simplicity is the lens** — every line, name, abstraction earns its place by paying for itself in clarity or capability. See `philosophy.md`.
20. **Run 5-whys before adding any abstraction** — helper, sealed trait, wrapper case class, generic, implicit, config map. If depth-three lands on "in case we need it later" / "DRY" / "for symmetry", the abstraction doesn't exist.
21. **Use the codebase's vocabulary** — before introducing a name, check the codebase isn't already using it for a different concept. Names are promises.
22. **Named failure modes are a shared vocabulary, not a checklist** — use the names in `failure-modes.md` so corrections are fast and the vocabulary compounds. The point is catching the smell, not completing a scan.
