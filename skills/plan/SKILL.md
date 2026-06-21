---
description: Plan together before building. Convene the cluster in planning mode to interrogate the lead relentlessly, reach a shared understanding of the problem, and make it implementation-ready. Run before /team-rocket:rally.
---

Hold a planning huddle — convene the cluster (James, Jessie, Meowth) in **planning mode** to interrogate the problem *with the lead* until everyone shares one mental model, then turn it into an implementation-ready plan. Run this *before* `/team-rocket:rally`.

The point isn't ceremony — it's catching the most expensive bug there is: a confidently-built solution to a misunderstood problem. The cluster does not design in a vacuum and does not guess what the lead meant. It **questions the lead relentlessly, in text, until the problem is genuinely shared** — then, and only then, designs.

## The Prime Directive

**Do not propose a solution until you and the lead share the same mental model of the problem.** Understanding comes first, design second. The lead is a full participant in this phase, not a spec-giver who hands off — every question is put to them and answered before anything is built.

## When To Use

- After `/team-rocket:scheme` scaffolded the story and the EDA / discovery is done — the placeholder goals now need to become real, interrogated goals.
- Whenever a story or goal isn't implementation-ready: vague acceptance, untested-able outcomes, an unknown nobody has sized, a design that smells, or a problem nobody has pinned down.
- Skip it only for genuinely trivial, single-file changes the lead fully understands (the same bar as the solo exception in the playbook).

## Prerequisites

The project is already wired (`TEAM-ROCKET.md` exists from `/team-rocket:blast-off`). If not, run blast-off first. Read `TEAM-ROCKET.md` for the tracker access pattern, codebase vocabulary, and companion-file paths.

## How The Huddle Runs — Two Phases

1. **Phase 1 — Understand the problem *with the lead*.** Relentless text Q&A until a shared-understanding gate is passed.
2. **Phase 2 — Interrogate the solution.** The three lenses stress-test the design until the Definition of Ready is met.

Phase 2 does not start until Phase 1's gate is passed.

---

## Phase 1 — Interrogate the Lead Until You're On The Same Page

The cluster's only job here is to understand **WHAT** problem we're solving and **WHY** — not HOW. Each role questions the lead from its lens, and the agents question each other; disagreements about what the lead meant become new questions *for the lead*, never guesses.

Who asks what:

- **Meowth — the problem & the why.** What is actually being asked for? Why does it matter, and to whom? Who is the user, what is their job, what does success look like? What's the history — has this been attempted or discussed before?
- **James — behaviour & boundaries.** What are the concrete inputs and outputs? The edge cases? What's explicitly in scope and out of scope? What constraints (data, performance, compatibility, deadlines) bound the solution?
- **Jessie — done & verifiable.** How will we *know* it's done? What does each outcome look like as a testable statement? Where do the stated requirements contradict each other or the existing system?

### The Questioning Protocol (the rules)

1. **Text in, text out.** Every question is asked in plain text and expects a written answer. Never infer, default, assume, or proceed on a question the lead hasn't answered. If a question goes unanswered, re-ask it — do not fill the gap yourself.
2. **No vague answers accepted.** A vague or ambiguous answer is not an answer. Push until it's concrete and specific. (See the table below.)
3. **Don't take answers at face value.** Play the answer back in your own words, test it against concrete examples and edge cases, and surface any contradiction with an earlier answer, a prior doc, or how the codebase actually behaves. Make the lead confirm or correct your restatement.
4. **Cross-examine.** Ask a lot — between yourselves and with the lead. When two agents read the lead's answer differently, that gap is a question for the lead, resolved in writing.
5. **Drill until testable.** A topic is settled only when the answer is specific enough that Jessie could write a test against it. "Roughly" and "probably" are not settled.
6. **Volume is fine; vagueness is not.** Fifty pointed questions now are cheaper than one wrong build later. But ask in topic-sized batches, not a wall of thirty at once — keep it a conversation, not an interrogation transcript.

### Vague vs Concrete — reject the left, demand the right

| The lead says (reject) | Drill until you get (demand) |
|---|---|
| "Make it fast." | "p95 under what load, measured how, against what budget?" |
| "Handle errors gracefully." | "Which error cases exactly, and the precise behaviour for each one?" |
| "It should be flexible / configurable." | "Which axis actually varies at runtime, who sets it, and what are the allowed values?" |
| "Like the old one, but better." | "Which behaviours stay identical, which change, and what is the new behaviour precisely?" |
| "Users want X." | "Which users, doing what job, and how do we know — evidence or assumption?" |
| "Just the usual validation." | "List the fields and the exact rule and error for each." |

### The Shared-Understanding Gate

Phase 1 ends only when the cluster **writes back a problem statement** — in text — covering: the problem, the why, who it's for, what success looks like, what's explicitly **out of scope**, and the key constraints and edge cases. The lead must confirm it in writing ("yes, that's it"). If the lead corrects any part, loop on that part and re-confirm.

**No written confirmation, no Phase 2.** Designing on an unconfirmed problem statement is the exact failure this skill exists to prevent.

---

## Phase 2 — Interrogate the Solution

Now — and only now — turn the shared understanding into a plan. The same three lenses stress-test the *design*; the lead arbitrates and records decisions. Interrogate, don't agree:

- **Meowth — prior context & landmines.** Relevant conventions/vocabulary, prior discoveries, and prior *failed* approaches so the plan doesn't repeat a known dead end.
- **James — buildability & scope.** Can it be built without a workaround? Does one acceptance row force a multi-file/multi-layer change? What's unknown and needs a spike? What's the simplest thing that satisfies the acceptance?
- **Jessie — testability, spec consistency, design quality.** Can she name a concrete regression a test would catch for each row? Are the rows consistent? Does the design carry speculative generality or a premature abstraction?

The lead **locks the goals (WHY + WHAT)** once approved; the HOW stays negotiable. Iterate until the Definition of Ready is met.

## Definition of Ready

A goal is ready for implementation only when ALL hold:

- [ ] **Problem understood:** the cluster's written problem statement was **confirmed by the lead in text** (Phase 1 gate passed).
- [ ] **WHY** is clear in one paragraph; **WHAT** is testable acceptance meeting INVEST; both locked.
- [ ] **HOW** is sketched with concrete file/component pointers, mirroring the codebase's current preferred pattern.
- [ ] **Testable:** Jessie can name a concrete regression a test would catch for each acceptance row.
- [ ] **Buildable:** James confirms no workaround is required and the blast radius is proportionate to the requirement.
- [ ] **No repeat:** Meowth has checked prior failed approaches — this plan isn't one of them.
- [ ] **Unknowns handled:** every unknown is either resolved or scoped into a named throwaway spike.
- [ ] **No unresolved design smell** and no internal contradiction between acceptance rows.
- [ ] **File-ownership boundaries** identified, so parallel clusters won't collide.

If any box can't be ticked, the plan goes back — or the gap becomes a spike. Don't lock a goal you can't test.

## Steps

1. **Pick the story / goal(s) to plan.** Read everything that exists: draft WHY/WHAT/HOW, EDA findings, prior session notes, related items, persistent memories.
2. **Spawn the cluster in PLANNING MODE** — James, Jessie, Meowth, simultaneously (single message, parallel calls), named by story. The spawn prompt must say, explicitly:
   - **PLANNING MODE: no production code, no feature branch, no commits.** The output is a *ready plan*, not a diff.
   - **Phase 1 first: interrogate the lead in text until the problem is shared and confirmed.** Reject vague answers; don't assume; don't design yet.
   - The story ID and whatever draft WHY + WHAT + HOW exists.
   - Each agent's lens (above), and the questioning protocol.
   - The companion files + `TEAM-ROCKET.md`.
   - Today's date in absolute form.
3. **Run Phase 1.** The lead relays the cluster's questions to the human and the human's written answers back, pushing back on anything vague. End with the written problem statement and the lead's confirmation.
4. **Run Phase 2.** Stress-test the design through the three lenses until the Definition of Ready is met.
5. **Persist the ready plan.** Meowth records, in the tracker: the confirmed problem statement, the locked goals (WHY + WHAT), the agreed HOW with file pointers, decisions made, open spikes, and file-ownership boundaries. This is what `rally` consumes.
6. **Shut the planning cluster down.** "Cluster done. Shut down." to all three in one turn.
7. **Tell the lead the verdict.** "Plan is ready — run `/team-rocket:rally`," or "Not ready — blocked on [open question / spike]."

## The Three Lenses (what each role owns)

| Role | Phase 1 — understand the problem | Phase 2 — interrogate the solution |
|---|---|---|
| **Meowth** | the problem, the why, the history | prior context & landmines |
| **James** | concrete behaviour, edges, scope, constraints | buildability & scope |
| **Jessie** | how we'll know it's done; contradictions | testability & design quality |

The lead is the fourth voice: the source of truth for the problem, the arbiter of the design, and the decision-recorder.

## Anti-Patterns

- **Accepting a vague answer to move faster.** The whole point is to refuse vagueness. "Roughly", "probably", "you know what I mean" are prompts to drill, not to proceed.
- **Designing before the problem statement is confirmed.** Phase 2 on an unconfirmed Phase 1 is building on sand.
- **Inferring an answer the lead didn't give.** Silence is not consent and not an answer. Re-ask.
- **Asking everything at once.** A wall of thirty questions is not a conversation. Batch by topic; follow the thread.
- **Agreeing instead of interrogating.** If James and Jessie just nod — at the lead or each other — the huddle did nothing. Find the holes.
- **Writing code in the huddle.** Planning mode produces tracker artefacts, not diffs.
- **Analysis paralysis.** Drill hard on what makes the *problem* clear; genuine external unknowns become named spikes, not blockers. The huddle makes the plan ready, not perfect.
