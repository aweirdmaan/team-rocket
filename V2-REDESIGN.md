# team-rocket v2 — design

For review before the rebuild. Decisions already made by Amaan are marked [locked].

## What it is

team-rocket becomes an Archon workflow plus the files it reads. No skills, no plugin hooks, no run-mode options [locked]. Archon owns control flow. Our files own the behaviour.

Verified on Archon v0.5.0 (installed via brew, spike run ada-83r.1): worktree-per-run isolation, per-node models, loop nodes with fresh context, human approval gates, per-node PreToolUse hooks, `archon validate workflows`.

Spike verdict (2026-07-17): a real story ran end to end in ~10 minutes, 4/4 nodes green. The opus plan node produced a cited, decision-reason-evidence plan unprompted. The sonnet implement loop finished in one iteration with one 13-line commit matching the plan verbatim. The opus review node re-ran the gates, attacked the change with 8 adversarial inputs, and checked for regressions. Full log on ada-83r.1. Not yet exercised: interactive approval gates and `$ARTIFACTS_DIR` command files; both get tested during the rebuild.

## The workflow

One file: `.archon/workflows/team-rocket.yaml`. Six nodes. Node prompts are short pointers to command files (`.archon/commands/*.md`), which point to the artifacts. No long prose in the YAML.

| Node | Who | Model | What happens |
|---|---|---|---|
| ideate | meowth | large (opus) [locked] | Turn the story idea into WHY + WHAT. Create the beads story. |
| plan | meowth + jessie | large [locked] | Meowth digs the code and drafts the HOW. Jessie challenges it. They converge between themselves first. Open questions go to the human as one batch. Human approves the plan (approval gate). Every task split to grape size. |
| implement | james | medium (sonnet) [locked] | Loop node, fresh context each iteration. Read the next beads task. Do exactly what it says. One logical change per commit. Stop and return the task if code contradicts plan. |
| verify | jessie | large [locked] | One node: run the gates, run the change, try to break it, review the diff, confirm nothing that worked before broke [locked: validate+review merged]. Verdict: pass or a findings list back to implement. |
| pr | deterministic + AI | small | Push branch, open MR/PR with story id, WHY, evidence. GitLab repos use glab, GitHub uses gh. |
| retro | meowth | small | Did the plan hold? Write the delta to beads. Propose plugin updates. |

Second trigger for retro [per feedback]: when human review comments land on the MR, run `team-rocket-retro <mr-url>`. It harvests the comments into beads and turns repeated ones into plugin-update proposals. That loop is how the plugin learns.

## Roles

- **Meowth (planner-discoverer).** Given WHY and WHAT, he finds everything needed to write the HOW: reads the code, cites every source, logs every decision. He does not guess. His notes go straight into beads.
- **Jessie (reviewer-verifier).** In planning she challenges the HOW. After implementation she proves it works: runs it, attacks it, checks for regressions. She writes test probes only, never production code.
- **James (executor).** The task tells him what and how. No discovery, no design decisions. If the code doesn't match the task, he stops and returns it. The plan is never wrong from where he stands; fixing it is planning's job.

Agent behaviour lives in three command files that say WHAT each role does. HOW code should be written is not in them; it lives in OPINIONS.md.

## OPINIONS.md

Amaan's preferences on how code gets written. Planning bakes them into every task. Contents:

- One logical change per commit. That comes first. Then size: aim 50–150 changed lines, flag anything above 300 [locked: logical change is the headline, size second].
- Spec-driven: the plan defines behaviours and test cases before code. James implements code and tests to that spec.
- Plain naming, no speculative abstractions, match the codebase pattern.
- Good code, not "amazing code". Short sentences in docs. No filler.

## Beads [locked: mandatory]

- Beads is the backbone. If the project uses an external tracker (Jira), planning mirrors the story into beads and the pr/retro nodes sync status back.
- Meowth's planning notes are beads comments with a fixed shape:
  ```
  DECISION: <what>
  REASON: <why>
  EVIDENCE: <file:line, doc, or command output>
  REJECTED: <alternatives and why not>
  ```
- Story shape in beads: epic = story, task = grape, dependencies as real edges, dotted IDs for hierarchy. Exact type mapping decided during rebuild after reviewing beads' native types.
- All nodes get `BEADS_DIR` in their environment. Archon worktrees live outside the workspace, so `bd` cannot resolve the DB without it (reproduced during the spike).

## The grape

A grape is a task one implement iteration finishes: one logical change, 1–3 small commits. If a task is bigger, planning splits it. That's the whole rule.

## Guardrails

- Worktree isolation: work never touches main; the PR is the only path in.
- Planning writes the repo's no-touch files (toolchain pins, CI config) into each task. Jessie rejects diffs that touch them.
- The implement node carries two PreToolUse deny hooks in the workflow YAML: `--no-verify`, and edits to files the plan marked no-touch. This is repo-level config, not plugin code.
- GitLab/GitHub protected branches guard main server-side. To verify per repo during rebuild.

## What gets deleted

All five skills, hooks/, guardrails.sh, the playbook, blast-off, TEAM-ROCKET.md generation, the settings templates, the beads adapter's dead event hooks. philosophy.md and failure-modes.md survive as short artifacts (failure modes: one line per smell). examples.md shrinks to one bad/good pair per smell that needs one.

## Open items (decided during rebuild, not blockers)

- Beads type mapping for the story shape.
- Whether plan is one node with an internal meowth/jessie loop or two nodes with a convergence loop. Depends on how `agents:` maps behave in practice.
- Interactive-gate reliability (community reports past fragility; not covered by the spike, which ran unattended).
- CLI shows run-level status only, no per-node progress. Live progress needs the stream log or the web UI. Decide what we monitor with.
