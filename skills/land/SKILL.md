---
description: Land the story. Verify the Definition of Done, integrate and open the PR, close with reasons, and run a retro that feeds the team's memory and the plugin. The exit bookend to /team-rocket:plan. Run after implementation.
---

Land the story — verify it's actually done, get it integrated, close it with reasons, and capture what the work taught us. This is the **exit bookend**: where `/team-rocket:plan` gates *entry* to implementation with a Definition of Ready, `land` gates *exit* with a **Definition of Done**, then runs a short retro so the team — and the plugin — get better.

Landing isn't paperwork. It's the proof the change works and shipped well, and the moment the system learns. "Done" is **shown, not asserted.**

## When To Use

- After the implementation cluster has finished a story's goals (via `/team-rocket:rally`).
- Per goal as it completes, or for the whole story — whichever matches how the lead is closing work.
- Don't skip it. An unlanded story is "done" only in someone's head, and a story that never gets a retro is a lesson thrown away.

## Prerequisites

- The **locked goals + acceptance** from `/team-rocket:plan` — the Definition of Done is measured against them. Read them first.
- `TEAM-ROCKET.md` (project wiring, vocabulary, conventions).

## How Landing Runs

1. **Phase 1 — verify the Definition of Done.** Prove each acceptance row is met.
2. **Phase 2 — integrate & open the PR.**
3. **Phase 3 — close with reasons** (lead only).
4. **Phase 4 — retro** — did the plan hold up; what to write down; what to propose.

## Phase 1 — Definition of Done

Re-read the locked acceptance. The story is done only when ALL hold:

- [ ] **Every locked acceptance row is demonstrably met** — point to the test that pins it *and* the runtime evidence (you ran it and observed the behaviour, not just green unit tests).
- [ ] **All gates green** — pre-commit, lint, format, CI. Zero failures.
- [ ] **Behaviour verified at runtime**, not just asserted.
- [ ] **No environment / build / toolchain drift**, and the work is on a feature branch, not a default branch.
- [ ] **No obvious security regression** introduced — a leaked secret, an injection path, broken authz, a risky new dependency. (A light pass, not a full audit; flag anything that smells.)
- [ ] **Discoveries, failed approaches, and manual / environment changes are recorded.**

If any row isn't actually met, it is **NOT done** — route back to implementation (`/team-rocket:rally`). Don't close it and don't paper over it.

Jessie owns the acceptance↔diff mapping; James produces the evidence (test names, what was run, what was observed).

## Phase 2 — Integrate & Open the PR

- Confirm the feature branch and that all gates pass. **Never push to a default branch.**
- Open the PR / MR: title carries the story id; body states the **WHY**, the acceptance met, and the **verification evidence** (tests + what you ran and saw).
- Route review per the project's convention (human approval, parallel review agents, etc.). **Don't merge to a default branch without the lead's explicit approval.**

## Phase 3 — Close With Reasons (lead only)

- Only the lead closes. Each goal is closed with a **reason** that says what was accomplished.
- Superseded implementations are **linked, not deleted** — history stays intact.
- Manual / environment changes are tagged for codifying later.

## Phase 4 — Retro: close the learning loop

Short and pointed. This is what makes the team and the plugin improve; the cluster runs it, the lead approves what gets written.

1. **Did the plan hold up?** Hold the outcome against the Definition of Ready's predictions:
   - Buildable without a workaround, as James predicted — or did a hack sneak in?
   - Scope right-sized — or did the blast radius blow past the plan?
   - Acceptance rows as testable as Jessie predicted?
   - Did we hit a wall a prior failed approach should have warned us about?

   **Name where the plan was wrong.** A wrong prediction is the highest-value output here — it's the lesson.
2. **What did we learn?** Discoveries, gotchas, non-obvious behaviour worth saving.
3. **What goes in `TEAM-ROCKET.md`?** New codebase vocabulary, a pattern-hierarchy update, a new exception to the failure-modes list, a test-convention note. Meowth drafts the delta; the lead approves; it gets written. This is how the *project* memory compounds.
4. **What goes in the plugin?** If a smell recurred three+ times, or a one-off review rationale generalises, file a plugin-update proposal for `failure-modes.md` / `examples.md`. This is how the *plugin* improves.

Keep it tight and timeboxed. For a trivial story the retro can be one line ("plan held; nothing new"). Don't turn it into ceremony — but don't skip the plan-held-up check, which is most valuable exactly when things went smoothly (it confirms the model) and when they didn't (it fixes it).

## Steps

1. Read the locked goals / acceptance and the plan.
2. (Re)convene the cluster if it has shut down — landing wants James's evidence, Jessie's acceptance check, and Meowth's retro.
3. Run **Phase 1**. If the Definition of Done isn't met, route back to `/team-rocket:rally` — don't close.
4. Run **Phase 2** (integrate / PR).
5. The lead runs **Phase 3** (close each goal with a reason).
6. Run **Phase 4** (retro). Meowth records the learnings, writes the lead-approved `TEAM-ROCKET.md` delta, and files any plugin-update proposals.
7. Shut the cluster down. Tell the lead what landed and what the retro added (or that it added nothing — honestly).

## Anti-Patterns

- **Closing a story whose acceptance you can't demonstrate.** Done is shown, not asserted.
- **Skipping the retro because it shipped fine.** The plan-held-up check earns its keep on the smooth stories too.
- **Merging to a default branch without explicit lead approval.**
- **Letting the retro balloon into a meeting.** Tight bullets; write the delta; move on.
- **A retro that produces no delta and no proposal every single time.** If nothing is ever learned, either the planning is perfect (unlikely) or the retro isn't being honest.
