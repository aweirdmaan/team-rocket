---
description: Rally the team. Resume work on stories and drive the goal loop — brief, implement (James), verify (Jessie), record, close, next — without stopping between goals. Use at the start of every session.
---

Rally the team — pick up where we left off and **drive the work to completion** using the team-rocket playbook.

Read @playbook.md first — it contains the full behavioural ruleset.

You (the lead session) are the driver. In the default **lead-driven mode** you run the loop below yourself: you compile the briefs (the memory duty), spawn James and Jessie as subagents per goal, record every goal as it completes, close with reasons, and move straight to the next goal. The human is the arbiter for genuine scope/irreversibility calls — not a checkpoint between steps.

## Tooling Context

Team Rocket is tool-agnostic. Before doing anything, identify what task tracker and source control this project uses, so you can drive them on the lead's behalf. **Read `TEAM-ROCKET.md` first** — blast-off already recorded all of this. Only if it's missing or stale, detect by hand:

- **Task tracker** — could be a local DB, a hosted tracker (Jira / Linear / GitHub Issues / GitLab / Asana / Shortcut), or a flat markdown / spreadsheet. Look in the project root + `~/.config/` for hints: tracker-specific directories, CLI binaries on `$PATH`, env vars (`JIRA_*`, `LINEAR_*`, `GH_TOKEN`), CLAUDE.md / README references.
- **Source control + default branch** — run `git remote -v` and `git symbolic-ref refs/remotes/origin/HEAD` (or read CI config). Note the default branch name so agents stay off it.
- **CI / pre-commit gates** — check `.pre-commit-config.yaml`, `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, or the lead's session notes.
- **Toolchain pins** — note where the project pins language versions (`.tool-versions`, `mise.toml`, `package.json` engines, `pyproject.toml`, `Dockerfile`, etc.). Agents must not modify these.

If something material is genuinely undiscoverable from the repo and tracker, ask the human — with what you checked and your best guess attached.

## Steps

1. **Find actionable work.** Query the work queue: items in progress and items that are ready (no blockers). Prioritise in-progress items the lead may want to resume.

2. **For each candidate item**, read:
   - WHY (description) — why does this matter
   - WHAT (acceptance criteria) — testable outcomes
   - HOW (technical design) — the approach locked at planning
   - Comments / notes / prior session history — discoveries, failed approaches, manual / environment changes, handoff comments
   - Persistent team memories that touch on this area

3. **Confirm the target once, up front.** If the human already named the story (argument, or earlier in the conversation), don't ask — start. If several stories are ready and nothing points at one, ask **once**, before the loop starts. Never re-ask between goals.

4. **Run the goal loop** (below) until there are no ready goals left.

## Cluster vs Solo Decision

**Clusters are the default. Solo is a deliberate call, not an omission.**

Solo (lead implements directly, no James/Jessie) allowed only when ALL THREE hold:
- One file.
- No new design decisions.
- The lead just worked in that file (within the last few turns).

Otherwise: run the goal loop.

## The Goal Loop (lead-driven mode — the default)

For each ready goal, in dependency order:

```
┌── One goal ────────────────────────────────────────────────────┐
│                                                                │
│  1. LEAD compiles the brief (the memory duty)                  │
│       ↓                                                        │
│  2. Spawn JAMES (subagent): implement to the quality bar       │
│       ↓                                                        │
│  3. James returns DONE (evidence) or BLOCKED (question)        │
│       BLOCKED → lead resolves from plan/tracker/code,          │
│                 re-spawns; human only for genuine calls        │
│       ↓                                                        │
│  4. Spawn JESSIE (subagent): verify + review                   │
│       ↓                                                        │
│  5. Jessie returns SIGN-OFF or findings                        │
│       findings → back to James with the list (max 3 rounds,    │
│                  then escalate to the human)                   │
│       ↓                                                        │
│  6. LEAD records THIS goal on the tracker (immediately)        │
│  7. LEAD closes the goal with a reason                         │
│  8. CONTINUE to the next ready goal — do not stop to ask       │
└────────────────────────────────────────────────────────────────┘
```

**Step 1 — the brief.** Before spawning anyone, compile from the tracker and memory (this was Meowth's job; in lead-driven mode it's yours):
- WHY in one sentence; WHAT verbatim from the goal; HOW with file/component pointers.
- Prior discoveries and prior **failed approaches** on this story or its siblings, with reasons.
- The **verification setup** the plan specified for this goal (env, data, commands) — Jessie's spawn depends on it.
- File-ownership boundaries if other work is in flight.

**Step 2 — every spawn prompt (James and Jessie) must include:**
- The story / item ID and the brief from step 1.
- The **feature branch** to work on (NOT a default branch).
- **Environment guardrails** — no build-file / toolchain / CI edits, no default-branch pushes, no gate bypasses.
- The specific work-tracker commands to use, and the gates that must pass before "done" (from `TEAM-ROCKET.md`).
- The paths to `TEAM-ROCKET.md` and the companion files (philosophy, failure-modes, examples).
- Today's date in absolute form.

**Step 3 — BLOCKED returns.** Subagents can't chat mid-task; James returns BLOCKED with the question, the options he sees, and their costs. **You resolve it yourself if the locked plan, the tracker history, or the codebase answers it** — record the decision on the goal and re-spawn. Escalate to the human only when the plan is silent AND the call is irreversible, scope-changing, or guardrail-shaped. Reversible calls: decide, log, keep moving.

**Step 6 — record before closing.** Post the goal-completion comment on the task (see Worklog Convention in the playbook): progress against acceptance, what Jessie flagged and what was fixed, discoveries, failed approaches, environment/manual changes, decisions. Incremental beats batch — this happens per goal, not at session end.

**Step 8 — continuing is the default.** The human chose to run rally; that choice covers the whole ready queue. Stop the loop only when:
- No ready goals remain.
- A guardrail fires or a BLOCKED question genuinely needs the human (see step 3).
- Jessie and James disagree after 3 rounds.
- The plan turns out to contradict reality (that's a `/team-rocket:plan` problem — say so and stop).

## Native Cluster Variant (experimental)

With Agent Teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`), the same loop runs with a live cluster instead of sequential subagents: spawn James + Jessie + Meowth **simultaneously** per story (single message, parallel calls), named by story (`james-PROJ-123`, …); Jessie reviews live as James works; Meowth briefs and records. Shutdown: one "Cluster done. Shut down." to each member in the same turn. Known platform caveats (idle teammates, no session resumption) are documented in the playbook — prefer lead-driven mode until Agent Teams is GA.

## Write Serialisation

Many task trackers serialise writes per item. Issue create / close / dep-mutation calls **sequentially**, not in parallel tool calls. If a write fails with a lock error, retry once after a short pause.

## Anti-Patterns

- **Stopping between goals to ask "shall I continue?"** — continuing is the default; the stop conditions are listed above.
- **Forwarding a BLOCKED question to the human that the plan or the repo already answers.** Resolve it, log it, re-spawn.
- Batching all recording to session end. (Each goal gets its own record at the moment of completion.)
- Spawning Jessie before James has returned, in lead-driven mode. (Sequential per goal; the live overlap is the native variant's dynamic.)
- Re-asking the human something answered in an earlier session — read the goal's comments and handoff notes first.
- Letting agents push to default branches or modify build/CI/toolchain files.
- Parallelising tracker-mutation calls on a single-writer tracker.

## Session End

Before ending (or when the human calls it):

1. Post a **final session summary** on the story epic: goals completed / deferred (with reasons), total commits and tests, cross-cutting discoveries, reviewer findings that became follow-ups, environment/manual changes needing codifying, what's unblocked next.
2. Post a **handoff comment** on the epic (and a one-liner on each open goal): current state, what's genuinely blocked vs just not started, any uncommitted/unpushed changes outside the tracker, decisions deferred (deferred-not-forgotten). A future session must be able to resume from the tracker alone.
3. Do any final state-syncing the tracker needs (push to remote, sync the tracker store).

## Session Resume After Compaction / Restart

The work tracker is the source of truth: whatever it says is in progress is where you resume. Read the handoff comments first — they exist so you don't re-ask. Then re-enter the goal loop.
