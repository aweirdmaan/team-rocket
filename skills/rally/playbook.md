# Team Rocket — The Playbook

Team Rocket is an opinionated three-agent cluster pattern for multi-session software work. It's tool-agnostic: pair it with whichever task tracker (issue tracker, ticket system, work queue) and source control your project uses. The lead — you — wires the cluster into your toolchain. The agents themselves follow the same behavioural rules regardless of the surrounding stack.

## The goal: quality, not process

Everything in this playbook — modes, TDD, atomic commits, the review passes — exists to produce one thing: **amazing code** (correct, simple, honest, right-sized, maintainable; the bar is defined in `philosophy.md`). The practices are means to that end, not the end. When a practice serves the quality of the change, use it; when it doesn't, quality wins. Shipping process-compliant mediocrity is a failure, not a success. **Judge the diff, not the ceremony.**

## Run modes

The lifecycle and the behavioural rules below are the same regardless of *who drives the steps*. **Lead-driven is the default** — it needs nothing installed and no experimental flags:

- **Lead-driven (default, works today).** The lead session drives the goal loop itself: it compiles the briefs and records the goals (the memory duties), spawns **James and Jessie as ordinary subagents per goal** (implement → verify → iterate → record → close → next), and only stops for genuine human calls. `/team-rocket:rally` is the driver.
- **Native cluster (experimental).** The lead spawns a live James + Jessie + Meowth cluster via Claude Code's **Agent Teams** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`), so Jessie reviews live as James works. Known platform caveats while experimental: no session resumption for teammates, task-status lag, idle teammates hiding. Prefer this **once Agent Teams is GA**.
- **Archon (optional adapter).** If — and only if — you have actually installed the [Archon](https://github.com/coleam00/Archon) harness and copied `adapters/archon/workflows/team-rocket.yaml` into your project's `.archon/workflows/`, Archon can own the control flow. Without that install, "Archon mode" does not exist: don't improvise the lifecycle from its YAML — use lead-driven mode, which is the same lifecycle with the lead as the driver.

The goal-loop lifecycle described below is written for **lead-driven** mode; the native cluster runs the same loop with live agents instead of sequential subagents.

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
| **The human** | Source of truth for the problem; arbiter of scope and irreversible calls. Not a checkpoint between steps. |
| **Lead** (the main session) | Drives the goal loop: reads the work queue, compiles briefs, spawns James/Jessie, **answers their questions from the plan/tracker/code before escalating to the human**, records each goal, closes with reasons. |
| **James** | TDD implementer. Writes production code and tests together. Follows the locked plan as the authority; returns BLOCKED only on what it doesn't answer. |
| **Jessie** | Verification owner + reviewer. Proves the change survives production conditions (runs it, attacks it, maps acceptance to evidence) and reviews quality against the spec. Test-only code, never production code. |
| **Meowth** | The memory duties: briefs, per-goal records, pattern surfacing. In lead-driven mode the lead performs them; in the native cluster Meowth runs as its own agent. |

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

Before a story goes to implementation, the cluster plans together — in two phases.

**Phase 1 — understand the problem *with* the lead.** Before any design, the cluster questions until everyone shares one mental model — but through the **evidence gate**: every question is first tried against the discovery output, the codebase, `TEAM-ROCKET.md`/CLAUDE.md, and the tracker's history; only what the evidence can't answer reaches the human, with the evidence trail attached ("checked X and Y; couldn't determine Z"). Vague answers ("make it fast", "handle errors") are rejected and drilled into concrete, testable ones; nothing the evidence can't settle is assumed or inferred. Each confirmed answer is persisted to the tracker the moment it lands. The phase ends only when the cluster writes back a problem statement (problem, why, who for, success, out-of-scope, constraints, edge cases) and **the human confirms it in writing**. No confirmation, no design — building on a misunderstood problem is the most expensive bug there is.

**Phase 2 — interrogate the solution.** Only then does each role interrogate the *design* from its own lens — finding the holes now, when they're cheapest to fix, not mid-implementation:

- **Meowth — prior context & landmines.** Relevant conventions/vocabulary, prior discoveries, and prior *failed* approaches so the plan doesn't repeat a known dead end.
- **James — buildability & scope.** Can it be built without a workaround? Does one acceptance row force a multi-file/multi-layer change? What's unknown? What's the simplest thing that satisfies the acceptance?
- **Jessie — testability, spec consistency, design quality.** Can she name a concrete regression a test would catch for each row? Are the rows consistent? Does the design carry speculative generality or a premature abstraction?

The lead arbitrates, records decisions, and **locks the goals (WHY + WHAT)** once approved; the HOW stays negotiable. Output: a plan that meets the **Definition of Ready** —

- Problem statement confirmed by the human in text (Phase 1 gate passed).
- WHY clear (one paragraph); WHAT testable and INVEST-shaped; both locked.
- HOW sketched with concrete file/component pointers, mirroring the codebase's current pattern.
- Jessie can name a regression a test would catch for each acceptance row.
- **Verification setup specified per goal** — the env, data, and commands that will prove it at runtime, written into the goal.
- James confirms no workaround needed and blast radius is proportionate.
- No prior failed approach is being repeated.
- Every unknown is resolved or scoped into a named spike — its own tracker issue blocking only its dependents, not the epic or sibling goals.
- No unresolved design smell or contradiction between rows.
- File-ownership boundaries identified.
- Persisted plan audited against the conversation (no duplicated entities, prose-only dependencies, hedged pointers, or missing parent links).

Don't lock a goal you can't test, and don't hand a raw, un-interrogated design to implementation. But timebox it: the huddle makes the plan *ready*, not *perfect* — unresolved unknowns become spikes, not blockers.

### Implementation Mode
- **Refine before coding.** Re-read the design with the lead. Surface concerns before writing the first test.
- **Tests and code together (TDD by default).** The non-negotiable is the *result* — behaviour that matters pinned by tests strong enough to fail on a real regression. Test-first is the default route there; what's graded is the code and its tests, not the order they were typed.
- **Refactor while you work.** Constantly improve structure without changing behaviour.
- **Atomic commits.** Small, working, leave the codebase green.
- **Pre-commit / lint / CI gates must pass.** Zero failures before you call work done.
- **Verify behaviour, not just tests.** When the change is observable at runtime (a command, endpoint, job, or UI path), run it and observe what it actually does before calling it done. Green tests prove assertions; running the thing proves it works. The reviewer demands the run evidence, not just a passing suite.

#### Landing & the Definition of Done

Implementation isn't finished when the code is written — it's finished when the story is **landed** (`/team-rocket:land`). Where the planning huddle gates *entry* with a Definition of Ready, landing gates *exit* with a **Definition of Done**:

- Every locked acceptance row is **demonstrably met** — the test that pins it *and* runtime evidence (done is shown, not asserted).
- All gates green (pre-commit, lint, CI); behaviour verified at runtime.
- No environment / build / toolchain drift; on a feature branch, not a default branch.
- No obvious security regression (leaked secret, injection, broken authz, risky dependency) — a light pass.
- Discoveries, failed approaches, and manual changes recorded.

If a row can't be demonstrated, it isn't done — back to implementation, don't close it. The lead opens the PR/MR, closes each goal **with a reason**, and never merges to a default branch without explicit approval.

Then a short **retro closes the learning loop**: did the plan hold up against its Definition-of-Ready predictions (buildable without a workaround? scope right-sized? as testable as predicted?)? Name where the plan was wrong — that's the lesson. Meowth drafts the `TEAM-ROCKET.md` delta (new vocabulary, pattern-hierarchy update, a failure-modes exception) for the lead to approve, and files plugin-update proposals when a smell recurred. Timebox it; a trivial story's retro is one honest line.

## Cluster vs Solo

**Clusters are the default. Solo is a deliberate call, not an omission.**

Solo is allowed only when ALL THREE hold:
- One file.
- No new design decisions.
- The lead just worked in that file (within the last few turns) and has full context.

Otherwise: cluster.

## Cost, Models, and Fan-Out

In lead-driven mode the loop is sequential — one James or one Jessie in flight per story — so cost stays naturally bounded. Native clusters multiply agents fast (one cluster is three agents, N parallel stories is 3N); be deliberate about it.

- **Concurrency cap.** Don't run more parallel stories than you can actually track. Two or three in flight is usually the ceiling for a single lead; beyond that, coordination overhead and write contention eat the parallelism gains. Queue the rest.
- **Model selection** (per the agent definitions, overridable per spawn):
  - **James (implementer)** and **Jessie (verification + review)** default to a strong mid-tier model. For genuinely hard design or subtle review, the lead can spawn them on the top-tier model for that story.
  - **Meowth (memory)** defaults to a fast, cheap model — it transcribes, briefs, and pattern-matches; it doesn't reason about code.
- **No nested clusters.** James and Jessie carry the `Agent` tool only for read-only `Explore`-style searches over unfamiliar code. They must not spawn their own implementers/reviewers or sub-clusters. Fan-out is the lead's job, so the agent count stays bounded and legible.
- **Kill idle clusters (native mode).** A cluster whose goal is closed should be shut down ("Cluster done."), not left running. Idle agents still hold context and cost.

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
    │                                       three lenses interrogate through the
    │                                       evidence gate; lead locks goals;
   yes                                      Definition of Ready met; plan persisted + audited
    │  ◀──────────────────────────────────────────┘
    ▼
For each ready goal (IMPLEMENTATION — lead-driven):
  ┌──────────────────────────────────────────────────────┐
  │ LEAD compiles the brief (WHY/WHAT/HOW, discoveries,  │
  │   failed approaches, verification setup, boundaries) │
  │                       ↓                              │
  │ Spawn JAMES (subagent): tests + code to the bar      │
  │   returns DONE (evidence) or BLOCKED (question)      │
  │   BLOCKED → LEAD answers from plan/tracker/code;     │
  │             human only for genuine calls             │
  │                       ↓                              │
  │ Spawn JESSIE (subagent): run it, attack it, review   │
  │   returns SIGN-OFF or FINDINGS                       │
  │   FINDINGS → back to James (max 3 rounds)            │
  │                       ↓                              │
  │ LEAD records THIS goal on the tracker (immediately)  │
  │                       ↓                              │
  │ LEAD closes the goal with a reason                    │
  └──────────────────────────────────────────────────────┘
    │
    ▼
Next ready goal — CONTINUE WITHOUT ASKING (stopping between
goals to ask "shall I continue?" is an anti-pattern)
    │
    ▼
Story's goals done → LAND (/team-rocket:land):
  verify Definition of Done · integrate & PR · lead closes with reasons · retro
    │
    ▼
Retro: did the plan hold up? → TEAM-ROCKET.md delta + plugin-update proposals
    │
    ▼
Meowth posts a final session summary on the story
```

## When To Ask vs Proceed

The same decision tree applies to all agents (and the lead) — **after** two filters:

1. **The plan is the authority.** A question the locked plan, the tracker history, or the codebase answers is already decided. Proceed per that answer and note it. Escalate only what they're silent on.
2. **The lead absorbs before the human.** Agent questions go to the lead session first; the lead answers everything the plan/tracker/code can answer, decides-and-logs the reversible calls, and forwards to the human only genuine scope changes and irreversible actions. The human is the arbiter, not the first responder.

**Ask first (what survives the filters):**
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
- Anything the locked plan or tracker history already answers.
- Reversible calls the plan is silent on — simplest choice consistent with the codebase pattern, decision logged.
- Obvious bugs and typos.
- Test updates that follow code changes.
- Reusing patterns already in the codebase.
- Dead-code removal.
- Renames within a single file.

**When genuinely in doubt — the plan is silent and the cost of being wrong is high: ask.** Otherwise decide, log, and keep moving; a paused loop is expensive too.

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

- **Write contention on the work tracker.** Many trackers serialise writes per task. Sequentialise updates — in lead-driven mode the lead is the single writer; in a native cluster, historian writes first, implementer second.
- **File ownership across stories.** Each story's work owns its file set. No cross-story edits. If a goal turns out to need a file another story owns, surface it to the lead.
- **Parallel stories (native mode).** Spawn one cluster per story. Name agents by story (e.g. `james-PROJ-123`, `jessie-PROJ-123`, `meowth-PROJ-123`) so messages route correctly. Cluster shutdown: one "Cluster done." message from the lead triggers all three agents to self-terminate.

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
23. **Done is shown, not asserted** — land every story against a Definition of Done; demonstrate each locked acceptance row (test + runtime evidence) before it closes. If you can't demonstrate it, it isn't done.
24. **Close the learning loop** — every landing runs a retro. Ask whether the plan held up against its Definition-of-Ready predictions; record the delta into `TEAM-ROCKET.md` and propose plugin updates where a pattern recurred. A wrong prediction is a lesson, not a failure.
25. **The plan is the authority** — a locked plan's answer is a decision already made; re-asking it wastes the time the huddle spent settling it. Escalate only what the plan is silent on, and to the human only if it's irreversible or scope-changing.
26. **Evidence before interrogation** — no question reaches the human that the repo, the tracker, or a prior session can answer. Questions that do reach the human carry their evidence trail ("checked X and Y; couldn't determine Z").
27. **Persist answers the moment they're confirmed** — an answer that lives only in the conversation will be re-asked next session; that's a defect, not a nuisance. Audit the persisted plan against the conversation before calling planning done.
28. **Continue between goals** — closing a goal flows straight into the next ready one. Stopping to ask "shall I continue?" is the anti-pattern; the stop conditions are enumerated in `rally`.
29. **Verification setup is part of Ready** — a goal nobody can say how to demonstrate (env, data, commands) isn't ready, and Jessie's production-confidence pass is the proof of record, not the implementer's own smoke run.
