# Archon adapter — run team-rocket on the Archon harness

[Archon](https://github.com/coleam00/Archon) (current `main`) is an open-source **harness / workflow engine** for AI coding: you define your development process as a YAML workflow — a DAG of AI (`prompt:`) and `bash:` nodes, with loops, human gates, and automatic branch/worktree isolation — and run it deterministically and repeatably across projects.

This runs **team-rocket's process on that harness**, and it is the **recommended way to run team-rocket** (see "Run modes" below). The split is clean:

- **Archon owns the deterministic control flow** — the node DAG, the implementation loop, the human gate, branch/worktree isolation, re-runs.
- **team-rocket owns the behaviour at each node** — the discovery homework, the relentless plan interrogation of the lead, the quality bar, the review lens, the Definition of Done, the retro.

That resolves the "two harnesses, pick one" tension: there's **one orchestrator (Archon)**, and team-rocket is the taste it executes. You get repeatability *and* the roles/interrogation/quality bar.

## Run modes

team-rocket can run two ways, and **Archon is the default**:

1. **Archon (recommended)** — what this adapter sets up. Works **today**, no experimental flags. Archon orchestrates; team-rocket's roles live in the workflow's node prompts.
2. **Native cluster (experimental)** — the lead spawns a live James + Jessie + Meowth cluster via Claude Code's **Agent Teams**, so Jessie reviews James *live as he works*. This needs `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and is the better fit for the live-review dynamic — **once Agent Teams is generally available.** Until then, prefer Archon.

The two modes run the *same* lifecycle (discovery → plan → implement → land) and the *same* behavioural rules; only the orchestration differs.

> This targets the **harness** on `main`. It is **not** the archived `archive/v1-task-management-rag` branch (MCP task-management + RAG) — that's a different product and not what this wires.

## What ships

- **`workflows/team-rocket.yaml`** — team-rocket's lifecycle as an Archon workflow: `discovery → plan (human gate) → implement (loop) → validate (bash) → review`.

## Setup

1. **Install Archon** (per its README): Bun, Claude Code, and the GitHub CLI; then `git clone` Archon, `bun install`, run `claude` and say *"Set up Archon."*
2. **Install the workflow:** copy `adapters/archon/workflows/team-rocket.yaml` into your project's **`.archon/workflows/`**. A same-named file in your repo overrides a bundled default.
3. **Fill in the `validate` node** with your project's real test/lint command (`bun run validate`, `make test`, `pytest -q`, …).
4. *(Optional)* split long node prompts into `.archon/commands/*.md` and reference them, if your Archon version supports it.

## Run it

In Claude Code: *"Use archon to run the team-rocket workflow on <task>."* Archon handles workflow selection, branch naming, and worktree isolation for you.

## How the nodes map to team-rocket

| Archon node | team-rocket behaviour |
|---|---|
| `discovery` | The discovery prereq — understand the problem space and the code; no code. |
| `plan` (`interactive: true`) | The planning huddle. **Phase 1** interrogates the lead relentlessly in text until the problem statement is confirmed; **Phase 2** interrogates the design to the Definition of Ready. The human gate is what makes "involve the lead completely" real. |
| `implement` (`loop`, `fresh_context`) | TDD-by-default implementation to the quality bar; atomic commits; verify behaviour at runtime, not just tests. |
| `validate` (`bash`) | The deterministic gate — your test/lint command must pass. |
| `review` | Jessie's review lens — judge the diff against the plan and the quality bar; confirm tests fail on a plausible regression. |
| `land` | The Definition of Done — every locked acceptance row demonstrated (test + runtime evidence), a light security pass, then open the PR. Done is shown, not asserted. |
| `retro` (`interactive: true`) | Close the learning loop — did the plan hold up? Draft the `TEAM-ROCKET.md` delta (lead approves) and file plugin-update proposals where a smell recurred. |

## Caveats

- **Verify the YAML schema against your Archon version.** The node keys (`prompt` / `bash` / `loop` + `until` + `fresh_context` / `depends_on` / `interactive`) follow Archon's documented example; your build may differ. The workflow is a **template to adapt**, not a guaranteed-valid file.
- **AI nodes take prompts, not explicit roles.** The harness (as documented) passes a prompt to Claude Code per node; it doesn't expose per-node subagents. So James/Jessie/Meowth live *in the prompts* here rather than as separate agents. If your Archon version supports per-node agents, you can split the roles out.
- **Isolation overlaps the guardrails.** Archon's branch/worktree isolation covers "stay off the default branch"; the plugin's own `PreToolUse` guardrail still applies at the Claude Code level as a backstop.
- **Archon is beta.** Expect rough edges; pin/verify behaviour before relying on it.
