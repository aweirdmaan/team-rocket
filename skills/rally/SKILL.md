---
description: Rally the team. Resume work on stories, load the playbook, spawn clusters. Use at the start of every session.
---

Rally the team — pick up where we left off using the team-rocket playbook.

Read @playbook.md first — it contains the full behavioural ruleset.

## Tooling Context

Team Rocket is tool-agnostic. Before doing anything, identify what task tracker and source control this project uses, so you can drive them on the lead's behalf:

- **Task tracker** — could be a local DB, a hosted tracker (Jira / Linear / GitHub Issues / GitLab / Asana / Shortcut), or a flat markdown / spreadsheet. Look in the project root + `~/.config/` for hints: tracker-specific directories, CLI binaries on `$PATH`, env vars (`JIRA_*`, `LINEAR_*`, `GH_TOKEN`), CLAUDE.md / README references.
- **Source control + default branch** — run `git remote -v` and `git symbolic-ref refs/remotes/origin/HEAD` (or read CI config). Note the default branch name so agents stay off it.
- **CI / pre-commit gates** — check `.pre-commit-config.yaml`, `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, or the lead's session notes.
- **Toolchain pins** — note where the project pins language versions (`.tool-versions`, `mise.toml`, `package.json` engines, `pyproject.toml`, `Dockerfile`, etc.). Agents must not modify these.

If anything is ambiguous, ask the lead.

## Steps

1. **Find actionable work.** Query the work queue: items in progress and items that are ready (no blockers). Prioritise in-progress items the lead may want to resume.

2. **For each candidate item**, read:
   - WHY (description) — why does this matter
   - WHAT (acceptance criteria) — testable outcomes
   - HOW (technical design) — the approach the lead has sketched
   - Comments / notes / prior session history — discoveries, failed approaches, manual / environment changes
   - Persistent team memories that touch on this area

3. **Brief the lead.** Tight summary:
   - What's in progress
   - What's ready and unblocked
   - What's blocked and why
   - Recent discoveries or failed approaches worth surfacing

4. **Ask the lead which item(s) to work on.** Don't auto-pick.

## Cluster vs Solo Decision

**Clusters are the default. Solo is a deliberate call, not an omission.**

Solo allowed only when ALL THREE hold:
- One file.
- No new design decisions.
- The lead just worked in that file (within the last few turns).

Otherwise: cluster.

## Spawning Clusters

For each story the lead picks, spawn three agents **simultaneously** per story (single message, three parallel tool calls):

- **James** (implementer) — TDD, atomic commits, pushes back on scope/design
- **Jessie** (reviewer) — watches James live, pushes back on code quality AND design
- **Meowth** (historian) — briefs the cluster, records each goal as it completes

Name them by story (e.g. `james-PROJ-123`, `jessie-PROJ-123`, `meowth-PROJ-123`) so messages route correctly.

**Every spawn prompt must include:**
- The story / item ID and a one-paragraph WHY + WHAT + HOW
- The **feature branch** to work on (NOT a default branch)
- **File ownership boundaries** — what they own; what's off-limits because another cluster owns it
- **Environment guardrails** — they must not edit build files, toolchain pins, or CI config; must not push to default branches; must not bypass gates
- The specific work-tracker commands they should use (if the tracker has a CLI, give the syntax; if it's a hosted system, give the access pattern)
- Today's date in absolute form (relative dates get stale fast)

## The Goal Cycle

For each goal within the story:

```
┌── Cluster active for this goal ───────────────────────────────┐
│                                                                │
│  Meowth: brief the cluster (prior context, file ownership)     │
│       ↓                                                        │
│  James + Jessie work in PARALLEL:                              │
│    James writes tests + code                                   │
│    Jessie reviews live; sends targeted feedback                │
│    Either side escalates to the lead for scope/design          │
│       ↓                                                        │
│  Goal complete → Meowth records THIS goal (incrementally)      │
│  (Meowth NEVER closes — only records)                          │
│       ↓                                                        │
│  LEAD reviews + closes the goal with a reason                  │
│       ↓                                                        │
│  LEAD sends "Cluster done." → all three self-terminate         │
└────────────────────────────────────────────────────────────────┘
     ↓
Next goal — fresh cluster
```

For multiple stories in parallel, spawn multiple clusters (one per story). Each cluster owns its story's file set.

## Cluster Shutdown

When a goal is complete and closed, send a shutdown message to each cluster member in the **same turn** (parallel tool calls):
```
"Cluster done. Shut down."
```

All three agents self-terminate. For N clusters finishing simultaneously, that's N×3 messages — but one round-trip if you batch them.

## Write Serialisation

Many task trackers serialise writes per item. Within a cluster:
- The lead issues create / close / dep-mutation calls **sequentially**, not in parallel tool calls.
- Agents within a cluster: serialise their own writes. Historian writes first when there's contention; implementer second.
- If a write fails with a lock error, retry once after a short pause.

## Anti-Patterns

- Spawn James alone first, wait, then spawn Jessie. (Spawn all three simultaneously — they coordinate live.)
- Have Meowth record the previous goal when the current one finishes. (Each goal gets its own record at the moment of completion.)
- Batch all of Meowth's recording to session end. (Incremental beats batch — context is lost across goal boundaries.)
- Let Meowth close issues. (Meowth records; lead decides; only lead closes.)
- Parallelise tracker-mutation calls on a single-writer tracker.
- Let agents push to default branches.
- Let agents modify build files, CI config, or toolchain pins to make local environment work.

## Session End

Meowth posts a final session summary on the story epic (all goals touched, total commits, total tests, key discoveries, what's unblocked next, what was deferred and why).

The lead does any final state-syncing the tracker needs (push to remote, sync the tracker store, post to Slack, etc.).

## Session Resume After Compaction / Restart

If resuming a session where the previous cluster's agents are no longer addressable (the cluster ID exists but the agents are gone), don't re-read the full playbook — go straight to spawning fresh clusters. The work tracker is the source of truth; whatever the tracker says is in progress is where you resume.
