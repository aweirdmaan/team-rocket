# Team Rocket

> *Prepare for trouble — and make it double-tested.*

A development process for AI coding, packaged as [Archon](https://github.com/coleam00/Archon) workflows. Plan with citations, build in grape-sized tasks, prove the result survives production. Beads holds every decision.

## The team

| Role | Job | Model |
|---|---|---|
| **Meowth** | Plans and discovers. Given WHY and WHAT, he digs through the code, drafts the HOW, cites every source, and logs every decision in beads. | opus |
| **Jessie** | Challenges the plan, then proves the built thing works: runs it, attacks it, checks nothing regressed. Test probes only, never production code. | opus |
| **James** | Executes. The task tells him what and how. If reality disagrees with the task, he stops and returns it. | sonnet |

The human is in two places: answering the one consolidated question batch during planning, and approving the plan. Everything else runs on its own.

## The workflow

```
ideate → plan (human gate) → implement (loop) → verify → fix → confirm → pr → retro
```

- **ideate** — story id or description in, beads epic with WHY + WHAT out.
- **plan** — meowth discovers and drafts, jessie challenges, the human approves. Output: grape-sized beads tasks, each carrying its spec, file pointers, gates, and verification setup.
- **implement** — james executes one task per iteration, fresh context each time. Beads is the memory.
- **verify / fix / confirm** — jessie proves it works and reviews the diff; james addresses findings; jessie confirms. A broken change cannot reach the PR.
- **pr** — push, open the MR/PR (`glab` or `gh`) with the story and the evidence.
- **retro** — did the plan hold? Lessons go to beads.

A second workflow, **team-rocket-harvest**, runs when human review comments land on the MR: it records each comment in beads and files improvement proposals for recurring themes. That is how the process learns.

## A grape

A grape is a task one implement iteration finishes: one logical change, 1 to 3 small commits. Planning splits work until everything is a grape.

## Install

1. Install Archon: `brew install coleam00/archon/archon` (or see [archon.diy](https://archon.diy)). Set `CLAUDE_BIN_PATH` to your Claude Code binary.
2. Copy this repo's `.archon/` directory into your project root.
3. Write the absolute path of your beads database into `.archon/team-rocket/beads-dir` (see `beads-dir.example`).
4. Check: `archon doctor`, then `archon validate workflows`.

## Run

```bash
archon workflow run team-rocket "ADA-1234"
archon workflow run team-rocket "add rate limiting to the export endpoint"
archon workflow run team-rocket-harvest "<mr-url>"
```

Or from Claude Code: *"Use archon to run team-rocket on ADA-1234."*

## What's inside

```
.archon/
├── workflows/
│   ├── team-rocket.yaml          # the lifecycle
│   └── team-rocket-harvest.yaml  # review comments → memory
├── commands/team-rocket-*.md     # one file per node: the role and its steps
└── team-rocket/
    ├── opinions.md               # how code gets written here (commits, spec-driven, style)
    ├── philosophy.md             # the lens the rules fall out of
    ├── failure-modes.md          # named smells, one line + minimal bad/good pair each
    └── beads-dir.example         # points bd at your workspace database
```

## Requirements

- [Archon](https://github.com/coleam00/Archon) with Claude Code
- [beads](https://github.com/steveyegge/beads) (`bd`) — the decision and task memory
- `glab` or `gh` for the PR node
- A git remote with a default branch the workflow stays off (Archon isolates every run in its own worktree and branch)
