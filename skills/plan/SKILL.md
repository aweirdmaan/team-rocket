---
description: Plan together before building. Convene the cluster in planning mode to interrogate a story from each role's perspective and make it implementation-ready. Run before /team-rocket:rally.
---

Hold a planning huddle — convene the cluster (James, Jessie, Meowth) in **planning mode** to interrogate a story from three perspectives and turn it into an implementation-ready plan. Run this *before* `/team-rocket:rally`.

The point isn't ceremony — it's catching design problems where they're cheapest to fix: before a line of code exists. A plan that survives three lenses (memory, buildability, testability) produces better code than a design that's only stress-tested mid-implementation. **Judge the plan against whether it's ready to build amazing code, not against whether the huddle happened.**

## When To Use

- After `/team-rocket:scheme` scaffolded the story and the EDA / discovery is done — the placeholder goals now need to become real, interrogated goals.
- Whenever a story or goal isn't implementation-ready: vague acceptance, untested-able outcomes, an unknown nobody has sized, a design that smells.
- Skip it only for genuinely trivial, single-file changes the lead fully understands (the same bar as the solo exception in the playbook).

## Prerequisites

The project is already wired (`TEAM-ROCKET.md` exists from `/team-rocket:blast-off`). If not, run blast-off first. Read `TEAM-ROCKET.md` for the tracker access pattern, codebase vocabulary, and companion-file paths.

## Steps

1. **Pick the story / goal(s) to plan.** Read everything that exists: WHY (description), the draft WHAT (acceptance), any draft HOW, EDA findings, prior session notes, related items, and persistent memories for this area.

2. **Spawn the cluster in PLANNING MODE** — James, Jessie, Meowth, simultaneously (single message, parallel calls), named by story. The spawn prompt must say, explicitly:
   - **PLANNING MODE: no production code, no feature branch, no commits.** The output is a *ready plan*, not a diff.
   - The story ID and the draft WHY + WHAT + HOW.
   - Each agent's planning lens (below) — tell them to interrogate, not to agree.
   - The companion files + `TEAM-ROCKET.md` (codebase vocabulary, conventions, exceptions).
   - Today's date in absolute form.

3. **Run the huddle.** The three lenses fire in parallel; the lead arbitrates:
   - **Meowth — prior context & landmines.** Opens with what's already known: relevant conventions/vocabulary, prior discoveries, and especially *prior failed approaches* so the plan doesn't walk into a known wall.
   - **James — buildability & scope.** Can this be built without a workaround? Does any single acceptance row force a multi-file/multi-layer change? What's unknown and needs a spike? What's the simplest thing that satisfies the acceptance?
   - **Jessie — testability, spec consistency, design quality.** For each acceptance row, can she name a concrete regression a test would catch? Are the rows internally consistent? Does the proposed design carry speculative generality or a premature abstraction? What will make this hard to review or maintain?
   - **Lead — resolve.** Answer each question, make scope calls, and record decisions (options considered, choice, trade-off). Goals (WHY + WHAT) get **locked** once approved; the HOW can still iterate.

4. **Iterate the HOW until it's ready.** Send the design back through the lenses until the Definition of Ready (below) is met. A question with no answer is not "ready" — it's either resolved or scoped into a named spike.

5. **Persist the ready plan.** Meowth records, in the tracker: the locked goals (WHY + WHAT), the agreed HOW with concrete file/component pointers, decisions made, open spikes, and file-ownership boundaries. This is what `rally` will consume — the tracker is the source of truth, so a fresh implementation cluster can pick it up cold.

6. **Shut the planning cluster down.** Send "Cluster done. Shut down." to all three in one turn. Planning is over; implementation gets a fresh cluster.

7. **Tell the lead the verdict.** Either: "Plan is ready — run `/team-rocket:rally` to implement," or "Not ready — blocked on [open question / spike], here's what's needed first."

## Definition of Ready

A goal is ready for implementation only when ALL hold:

- [ ] **WHY** is clear in one paragraph; **WHAT** is testable acceptance meeting INVEST; both locked.
- [ ] **HOW** is sketched with concrete file/component pointers, mirroring the codebase's current preferred pattern.
- [ ] **Testable:** Jessie can name a concrete regression a test would catch for each acceptance row.
- [ ] **Buildable:** James confirms no workaround is required and the blast radius is proportionate to the requirement.
- [ ] **No repeat:** Meowth has checked prior failed approaches — this plan isn't one of them.
- [ ] **Unknowns handled:** every unknown is either resolved or scoped into a named throwaway spike.
- [ ] **No unresolved design smell** and no internal contradiction between acceptance rows.
- [ ] **File-ownership boundaries** identified, so parallel clusters won't collide.

If any box can't be ticked, the plan goes back — or the gap becomes a spike. Don't lock a goal you can't test.

## The Three Lenses (what each role interrogates)

| Role | Lens | The questions they own |
|---|---|---|
| **Meowth** | Memory / context | Have we tried this before and lost? What conventions, vocabulary, and constraints already exist here? |
| **James** | Buildability / scope | Can I build this without a hack? Is the scope right-sized? What's unknown? What's the simplest thing that works? |
| **Jessie** | Testability / quality | Can I name a regression a test would catch for each row? Are the rows consistent? Is the design simple and honest? |

The lead is the fourth voice: arbiter and decision-recorder. Goals are immutable once the lead locks them; the HOW stays negotiable.

## Anti-Patterns

- **Writing code in the huddle.** Planning mode produces tracker artefacts, not diffs. If you're reaching for the editor, stop.
- **Locking a goal that isn't testable.** "Improve X" / "make it better" is not acceptance. Send it back.
- **Handing a raw, un-interrogated design straight to `rally`.** That's the failure this skill exists to prevent — the design gets stress-tested at implementation time instead, which is the expensive place.
- **Analysis paralysis.** The huddle makes the plan *ready*, not *perfect*. Timebox it; unknowns that can't be resolved cheaply become spikes, not blockers. A plan that's ready beats a plan that's exhaustively debated.
- **Agreeing instead of interrogating.** If James and Jessie just nod, the huddle did nothing. Their job is to find the holes.
