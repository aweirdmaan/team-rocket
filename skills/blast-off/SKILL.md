---
description: Prepare for trouble. Initialize team-rocket conventions in the current project against whichever task tracker the project uses. Run this once per project.
---

Prepare the launch pad. Wire team-rocket conventions into the current project against the task tracker, source control, and CI gates the project uses.

Team Rocket is tool-agnostic — this skill adapts the cluster pattern to whatever stack the project has. The goal is to verify that the lead can drive the work queue and that agents know what tools/branches/gates to respect.

## Steps

1. **Detect the task tracker.** Look for evidence in this order:
   - Local DB / CLI tracker — directory like `.beads/`, `.dewey/`, a binary on `$PATH` matching the tracker, or a `tracker.toml`.
   - Hosted tracker — env vars (`JIRA_*`, `LINEAR_API_KEY`, `GH_TOKEN`, `GITLAB_TOKEN`), config (`.jira/`, `.gh/`), or references in `README` / `CLAUDE.md`.
   - Inline tracker — markdown files like `TODO.md`, `BACKLOG.md`, `ISSUES.md`.
   - If nothing found, **ask the lead** which tracker the project uses (and offer to set up a local file-based tracker as a fallback).

2. **Detect source control + default branch.** Run `git remote -v`. Identify the default branch via `git symbolic-ref refs/remotes/origin/HEAD` (or look at the most recent merge-into branch). Record both — agents must stay off the default branch.

3. **Detect CI / pre-commit gates.** Check:
   - `.pre-commit-config.yaml`, `.husky/`, `.lefthook.yaml` for local commit hooks
   - `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines.yml`, `.circleci/` for remote CI
   - Project scripts: `package.json` scripts, `Makefile`, `Justfile`, build files

   Note which gates run locally vs only on CI. Agents need to know what their local pre-commit will catch.

4. **Detect toolchain pins.** Note all version-management files: `.tool-versions`, `mise.toml`, `package.json` engines field, `pyproject.toml`, `Gemfile`, `Dockerfile`. These are no-touch for agents.

5. **Confirm a "story" structure exists in the tracker.** Team-rocket expects a 3-level hierarchy:
   - **Story / epic** (the umbrella)
   - **Goal** (WHY + WHAT — one acceptance row)
   - **Implementation** (HOW — technical sketch)
   plus optional prereq / architecture-decision / backlog items.
   If the tracker doesn't natively support hierarchy, agree on a labelling convention with the lead (prefixes, parent links, label sets).

6. **Establish persistent-memory conventions.** Team-rocket relies on cross-session memory for "this is what we learned":
   - If the tracker has a memory feature (some local DBs do), use it.
   - Otherwise: use a `MEMORY.md` / `LEARNINGS.md` at the project root, organised by topic.
   - The lead must know where the memory lives so they can reference it in spawn prompts.

7. **Enable Agent Teams and merge permissions.** A plugin manifest cannot apply user/project settings on its own, so this is a manual (one-time) step the lead must do:
   - **Agent Teams** must be enabled for clusters to work: set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in the environment, or copy the `env` block from the plugin's `settings.json` into your `~/.claude/settings.json` / project `.claude/settings.json`. If clusters won't spawn, this is almost always why.
   - **Permissions**: the plugin's `settings.json` is a *template* of the allow-list agents need (read/edit/write, build/test runners, git, tracker CLI). Merge the entries you want into your project `.claude/settings.json`. Don't grant more than the project needs.

8. **Confirm the deterministic guardrails are active.** The plugin's core `PreToolUse` hook (`hooks/guardrails.sh`) already blocks pushes to default branches, force-pushes to them, `--no-verify`, and edits to build/CI/toolchain files — automatically, once the plugin is installed. Verify it loaded (a no-op test edit to a fake `build.gradle` should be refused). This is the real insurance against the "agent pushed to main" / "agent bumped the JDK pin" failure modes; prose rules alone are not.
   - If your tracker has a matching adapter, wire it (e.g. `adapters/beads/` for Beads — event hooks that validate goals/closes). Note the access pattern in `TEAM-ROCKET.md`. (Separately, `adapters/archon/` runs the whole team-rocket process on the Archon *harness* — a different integration, not a tracker; see its README.)

9. **Probe the codebase for vocabulary and pattern hierarchy.** This is the project-specific complement to `failure-modes.md` and `philosophy.md`. Find:
   - **Established vocabulary** — words the codebase already uses for specific concepts (e.g. "normalize" means record deduplication; "enrich" means a lookup join; "stage" is one step of the pipeline). Sample sibling modules; grep for repeated terminology.
   - **Pattern hierarchy** — which modules represent the current preferred pattern vs older ones being superseded (e.g. `orders-pipeline-v2` over a `legacy-orders-job`; typed `Dataset[T]` over untyped `DataFrame`). The lead probably knows; ask if unsure.
   - **Test conventions** — where component tests live, where integration tests live, what the assertion style is.

10. **Write a `TEAM-ROCKET.md`** at the project root capturing the wiring AND the codebase taste:
   ```
   # Team Rocket — project wiring

   ## Task tracker
   Tool: <name>
   CLI / API: <commands or access pattern>
   Story hierarchy convention: <e.g. parent labels, link types>
   Persistent memory: <where it lives>

   ## Source control
   Default branch (off-limits to agents): <main / master / develop>
   Feature-branch pattern: <e.g. PROJ-NNNN, feature/JIRA-123>

   ## CI / gates
   Pre-commit: <what runs locally>
   CI: <what runs on push>
   Toolchain pins: <files agents must not touch>

   ## Codebase vocabulary
   Words the codebase already uses for specific concepts. Do not overload them.

   | Word | Meaning here | Example |
   |------|--------------|---------|
   | <e.g. normalize> | <e.g. record deduplication, see the dedup module> | <module reference> |
   | <e.g. enrich> | <e.g. lookup join against reference data> | <module reference> |

   ## Pattern hierarchy
   Newer patterns to prefer when adding modules; older patterns to avoid mirroring.

   - **Prefer:** <list of reference modules and what makes them current>
   - **Avoid mirroring:** <list of older modules and why>

   ## Test conventions
   - Component / unit tests: <where they live, naming pattern>
   - Integration tests: <where they live, naming pattern>
   - Assertion style: <e.g. structural equality on case classes; one assertion per test>

   ## Codebase exceptions to the failure-modes list
   Some failure modes don't apply here because of language / framework idiom.
   List exceptions explicitly with the reason; agents won't flag them.

   | Failure-mode entry | Why it's OK here |
   |--------------------|------------------|
   | <e.g. methods that wrap themselves> | <e.g. Spark DataFrames carry .sparkSession; reaching up via df.sparkSession is idiomatic, not a smell> |
   | <e.g. implicit class extensions> | <e.g. the current pipeline module uses extension methods on DataFrame; mirror that, don't avoid it> |

   ## Companion files (read first)
   Resolve <plugin-root> by running `echo "$CLAUDE_PLUGIN_ROOT"` and write the ABSOLUTE paths here, so agents don't have to guess the install location.
   - <plugin-root>/skills/rally/philosophy.md — the simplicity lens
   - <plugin-root>/skills/rally/failure-modes.md — named code smells
   - <plugin-root>/skills/rally/examples.md — bad/good code pairs for each smell
   - <plugin-root>/skills/rally/playbook.md — process

   ## Spawn-prompt boilerplate
   Every james / jessie / meowth spawn must include the four companion files plus this file.
   ```
   This is the lead's reference. Spawn prompts should quote from it.

11. **Tell the lead what was set up and what's missing.** If you couldn't detect the tracker, say so explicitly so the lead can configure it. Confirm whether Agent Teams is enabled and the guardrail hook loaded — if not, the lead is relying on agent discipline alone. If you couldn't infer codebase vocabulary or pattern hierarchy from sampling, leave the placeholders in `TEAM-ROCKET.md` and ask the lead to fill them in before spawning the first cluster.

12. **Point the lead at the next step:** "You can now hatch a story scaffold with `/team-rocket:scheme`."
