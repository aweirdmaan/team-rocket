# Team Rocket — plugin gaps to fix

Running log of gaps found in the team-rocket plugin itself (skills, hooks, docs) while actually using it, not gaps in whatever story is being planned. Append as we discover more; don't prune without checking off / resolving.

## Open

_(none)_

## Resolved

### 1. `guardrails.sh`'s toolchain blocklist doesn't extend automatically when `blast-off` wires a new stack ✅ 2026-07-16
The hook now blocks by **shape** first — `*.lock` / `*.lockb` / `*-lock.json` / `*-lock.yaml` (lockfiles, any ecosystem), `.*-version` / `.tool-versions` (version-pin dotfiles), `*requirements*.txt` — with the explicit basename list kept only for names shape can't infer (`build.gradle`, `gradle.properties`, `pytest.ini`, …). Also picked up files the old list missed entirely (`gradle.properties`, `pip-requirements.txt`, `Dockerfile.*`, `.husky/`, lefthook). `blast-off` step 8 now has an explicit sub-step: for every pin file detected in step 4, *test* that the hook refuses an edit to it, and extend the list if one slips through — "the hook loaded" ≠ "the hook protects this stack". Verified with a 27-case synthetic-event suite (all pass).

### 2. `blast-off` has no documented path for *extending* an existing multi-repo `TEAM-ROCKET.md` ✅ 2026-07-16
Step 10 is now "Write — or extend": if `TEAM-ROCKET.md` exists, extend it section-by-section (source-control table row, CI/gates subsection, vocabulary rows, pattern-hierarchy entries, failure-mode exceptions), keep existing content untouched unless now wrong, and re-run step 8's coverage check for the new stack.

### 3. `plan` skill has no explicit step to audit the persisted plan against the conversation ✅ 2026-07-16
`plan` now has a dedicated step 6 ("Audit the persisted plan against the conversation") checking: (a) no entity in more than one goal, (b) no execution order that isn't an enforced dependency edge, (c) no hedged pointers where the huddle confirmed an answer, (d) parent linkage wired, (e) every human answer findable in the tracker. Also in the playbook's Definition of Ready and Key Rule 27.

### 4. `plan` skill has no prescribed pattern for a deferred cross-cutting decision ✅ 2026-07-16
Named explicitly: the **named-spike pattern** — its own tracker issue that blocks only its dependents, never the epic or sibling goals. In `plan`'s Phase 2, the Definition of Ready ("unknowns handled" row), and the playbook.

### 5. `plan`'s persist step doesn't enforce the dotted-ID parent/child hierarchy ✅ 2026-07-16
`plan` step 5 now says: wire the hierarchy the tracker natively supports — set parent links (e.g. `--parent`), don't rely on prose grouping — and wire ordering as enforced dependency edges. The step 6 audit checks parent linkage explicitly (item d).

### 6. No convention for handoff comments before a session ends ✅ 2026-07-16
`rally`'s Session End now mandates a handoff comment on the epic (state, blocked-vs-not-started, uncommitted changes, deferred-not-forgotten decisions) plus a one-liner per open goal; `plan` step 7 does the same when a session ends at planning. Session Resume reads handoff comments first, explicitly to avoid re-asking.

---

Also fixed in the same pass (from the 2026-07-16 eval):

- **Run modes made honest**: lead-driven mode (main session drives the goal loop, James/Jessie as subagents) is now the documented default; Archon demoted to an optional adapter with an explicit "if it isn't installed, there is no Archon mode" warning; native cluster stays experimental with its caveats listed.
- **The plan is the authority**: James (and the Archon implement node) proceed on anything the locked plan answers, decide-and-log reversible calls, and return BLOCKED only for genuine plan-silent, irreversible/scope-changing questions. The lead absorbs BLOCKED questions it can answer from plan/tracker/code before anything reaches the human.
- **Evidence gate in planning**: no question reaches the human that the repo/tracker/overlay can answer; surviving questions carry their evidence trail; the three lenses' questions are consolidated by the lead (no triple-asking). Answers are persisted the moment they're confirmed.
- **Jessie redesigned around production confidence**: she executes the change per the plan's per-goal verification setup (now a Definition-of-Ready row), attacks adversarial inputs / failure paths / env variance / repeatability, and returns SIGN-OFF / FINDINGS / BLOCKED. Test-only write access; `permissionMode: plan` dropped.
- **No-op hooks removed**: `TeammateIdle` / `Stop` echo hooks never reached the model (stdout on exit 0 isn't injected for those events); recording duties live in `rally`'s explicit steps instead.
- **Goal-loop continuity**: rally stops only on enumerated conditions (no ready goals, guardrail, genuine human call, 3-round James/Jessie disagreement, plan-contradicts-reality); stopping between goals to ask "continue?" is a named anti-pattern.
