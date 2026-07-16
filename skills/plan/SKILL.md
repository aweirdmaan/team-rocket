---
description: Plan together before building. Convene the cluster in planning mode to interrogate the lead, reach a shared understanding of the problem, and make it implementation-ready. Run before /team-rocket:rally.
---

Hold a planning huddle — convene the cluster (James, Jessie, Meowth lenses) in **planning mode** to interrogate the problem *with the lead* until everyone shares one mental model, then turn it into an implementation-ready plan. Run this *before* `/team-rocket:rally`.

The point isn't ceremony — it's catching the most expensive bug there is: a confidently-built solution to a misunderstood problem. The cluster does not design in a vacuum and does not guess what the lead meant. But the human's time is the scarcest resource in the huddle: **every question that the repo, the tracker, or prior sessions can answer is answered there first.** The human gets the residue — the questions only they can answer — with evidence attached.

## The Two Prime Directives

1. **Do not propose a solution until you and the lead share the same mental model of the problem.** Understanding comes first, design second.
2. **Do not ask the human what the evidence can answer.** Interrogation is for genuine unknowns, not for homework the cluster skipped.

## When To Use

- After `/team-rocket:scheme` scaffolded the story and the discovery task is done — the placeholder goals now need to become real, interrogated goals.
- Whenever a story or goal isn't implementation-ready: vague acceptance, untestable outcomes, an unknown nobody has sized, a design that smells, or a problem nobody has pinned down.
- Skip it only for genuinely trivial, single-file changes the lead fully understands (the same bar as the solo exception in the playbook).

## Prerequisites

The project is already wired (`TEAM-ROCKET.md` exists from `/team-rocket:blast-off`). If not, run blast-off first. Read `TEAM-ROCKET.md` for the tracker access pattern, codebase vocabulary, and companion-file paths.

## How The Huddle Runs — Two Phases

1. **Phase 1 — Understand the problem *with the lead*.** Evidence-first Q&A until a shared-understanding gate is passed.
2. **Phase 2 — Interrogate the solution.** The three lenses stress-test the design until the Definition of Ready is met.

Phase 2 does not start until Phase 1's gate is passed.

---

## Phase 1 — Understand the Problem, Then Ask What Only the Human Knows

The cluster's only job here is to understand **WHAT** problem we're solving and **WHY** — not HOW. Each role questions from its lens; disagreements about what the lead meant become questions *for the lead*, never guesses.

Who asks what:

- **Meowth lens — the problem & the why.** What is actually being asked for? Why does it matter, and to whom? Who is the user, what does success look like? What's the history — has this been attempted or discussed before?
- **James lens — behaviour & boundaries.** What are the concrete inputs and outputs? The edge cases? What's explicitly in scope and out of scope? What constraints (data, performance, compatibility, deadlines) bound the solution?
- **Jessie lens — done & verifiable.** How will we *know* it's done? What does each outcome look like as a testable statement? What setup (env, data, commands) will proving it at runtime need? Where do the stated requirements contradict each other or the existing system?

### The Evidence Gate (before any question reaches the human)

For **every** candidate question, first attempt to answer it from:

1. **The discovery output** — the discovery task did homework on the code; don't re-ask what it answered.
2. **The codebase** — read the module, grep the vocabulary, run the existing tests' names past the question.
3. **The project overlay** — `TEAM-ROCKET.md`, `CLAUDE.md`, rules files, README.
4. **The tracker + persistent memory** — the story's history, sibling tasks, prior failed approaches, recorded decisions, earlier huddle answers.

Then triage:

- **Answered by evidence** → it never reaches the human. Fold the answer into the problem statement, cite the source.
- **Evidence suggests an answer but doesn't settle it** → present as a **confirm/deny**: "The code does X (see file:line), so we assume Y — confirm?" One line to confirm beats an open question.
- **Evidence is silent** → ask openly, and say what was checked: "Checked the DAG, TEAM-ROCKET.md, and ADA-NNN's history; couldn't determine Z because …".

A question that reaches the human without its evidence trail is a protocol violation, not diligence.

### The Questioning Protocol

1. **The lead consolidates.** The three lenses generate questions; the lead dedups them against each other and the evidence gate, and puts **one batch per topic** to the human. Three agents asking overlapping variants of the same question is an interrogation transcript, not a conversation.
2. **Text in, text out.** Every question that survives the evidence gate is asked in plain text and expects a written answer. Never proceed on a question the human hasn't answered — but remember: an answer found in the evidence IS an answer; only genuine unknowns block.
3. **No vague answers accepted.** A vague or ambiguous answer is not an answer. Push until it's concrete and specific (see the table below).
4. **Don't take answers at face value.** Play the answer back in your own words, test it against concrete examples and edge cases, and surface any contradiction with an earlier answer, a prior doc, or how the codebase actually behaves. Make the human confirm or correct your restatement.
5. **Drill until testable.** A topic is settled only when the answer is specific enough that a test could be written against it. "Roughly" and "probably" are not settled.
6. **Persist each answer the moment it's confirmed.** Write it into the goal's tracker item (description or notes) right away — not at the end of the huddle. An answer that lives only in the conversation will be re-asked next session; that is a defect, not a nuisance.

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

Phase 1 ends only when the cluster **writes back a problem statement** — in text — covering: the problem, the why, who it's for, what success looks like, what's explicitly **out of scope**, and the key constraints and edge cases. The human must confirm it in writing ("yes, that's it"). If they correct any part, loop on that part and re-confirm.

**No written confirmation, no Phase 2.** Designing on an unconfirmed problem statement is the exact failure this skill exists to prevent.

---

## Phase 2 — Interrogate the Solution

Now — and only now — turn the shared understanding into a plan. The same three lenses stress-test the *design*; the lead arbitrates and records decisions. Interrogate, don't agree — and keep the evidence gate: design questions answerable from the code get answered there.

- **Meowth lens — prior context & landmines.** Relevant conventions/vocabulary, prior discoveries, and prior *failed* approaches so the plan doesn't repeat a known dead end.
- **James lens — buildability & scope.** Can it be built without a workaround? Does one acceptance row force a multi-file/multi-layer change? What's unknown and needs a spike? What's the simplest thing that satisfies the acceptance?
- **Jessie lens — testability, verifiability, spec consistency.** Can she name a concrete regression a test would catch for each row? Are the rows consistent? Does the design carry speculative generality? And per goal: what is the **verification setup** — the env, data, and commands she'll use to prove it at runtime? If nobody can say how a goal will be demonstrated, the goal isn't ready.

The lead **locks the goals (WHY + WHAT)** once approved; the HOW stays negotiable. Iterate until the Definition of Ready is met.

### Deferred decisions — the named-spike pattern

A genuinely undecided cross-cutting question must not block the whole plan and must not be silently answered to avoid an open item. Give it a **named spike**: its own tracker issue (priority reflecting urgency), which **blocks only its dependents** — not the parent epic, not sibling goals. The ready queue keeps surfacing everything the spike doesn't touch, and the deferral stays visible instead of forgotten.

## Definition of Ready

A goal is ready for implementation only when ALL hold:

- [ ] **Problem understood:** the cluster's written problem statement was **confirmed by the human in text** (Phase 1 gate passed).
- [ ] **WHY** is clear in one paragraph; **WHAT** is testable acceptance meeting INVEST; both locked.
- [ ] **HOW** is sketched with concrete file/component pointers, mirroring the codebase's current preferred pattern.
- [ ] **Testable:** a concrete regression a test would catch is named for each acceptance row.
- [ ] **Verification setup specified:** the env, data, and commands needed to demonstrate each goal at runtime are written into the goal — Jessie must be able to run the proof without asking anyone how.
- [ ] **Buildable:** no workaround required and the blast radius is proportionate to the requirement.
- [ ] **No repeat:** prior failed approaches checked — this plan isn't one of them.
- [ ] **Unknowns handled:** every unknown is either resolved or scoped into a **named spike** (see the pattern above) that blocks only its dependents.
- [ ] **No unresolved design smell** and no internal contradiction between acceptance rows.
- [ ] **File-ownership boundaries** identified, so parallel work won't collide.

If any box can't be ticked, the plan goes back — or the gap becomes a spike. Don't lock a goal you can't test.

## Steps

1. **Pick the story / goal(s) to plan.** Read everything that exists: draft WHY/WHAT/HOW, discovery findings, prior session notes, related items, persistent memories. This read IS the first pass of the evidence gate.
2. **Convene the cluster in PLANNING MODE.** In lead-driven mode, spawn James, Jessie, and Meowth as subagents (parallel calls) whose only output is their lens's question list + design critique — each spawn prompt states: PLANNING MODE, no code, the story ID and draft WHY/WHAT/HOW, the lens, the evidence gate (they must attach evidence trails to every question), the companion files + `TEAM-ROCKET.md`, and today's date. In the native cluster variant, spawn the live cluster with the same content.
3. **Run Phase 1.** The lead merges the lenses' questions through the evidence gate, puts the consolidated batches to the human, plays back answers, and **persists each confirmed answer to the tracker immediately**. End with the written problem statement and the human's confirmation.
4. **Run Phase 2.** Stress-test the design through the three lenses until the Definition of Ready is met — including the verification setup per goal.
5. **Persist the ready plan.** Record in the tracker: the confirmed problem statement, the locked goals (WHY + WHAT), the agreed HOW with file pointers, the verification setup per goal, decisions made, open spikes, and file-ownership boundaries. Wire the hierarchy the tracker natively supports — **set parent links** (e.g. `--parent`), don't rely on prose grouping — and wire execution-order dependencies as **enforced dependency edges**, not narration.
6. **Audit the persisted plan against the conversation** before calling it done. Re-read every created/updated issue and diff it against the confirmed problem statement + locked HOW, checking specifically:
   - (a) no entity appears in more than one goal;
   - (b) no execution order exists only as prose — every real dependency is an edge;
   - (c) no hedged/uncertain pointer ("if exists; check…") survives where the huddle already confirmed the answer;
   - (d) parent linkage is wired, not just dependency edges;
   - (e) every human answer from Phase 1/2 is findable in the tracker, not just in the conversation.
   Fix drift now — this audit is what prevents next session's re-asking.
7. **Leave a handoff comment** on the epic if the session is ending here: plan state, open spikes (deferred-not-forgotten), anything uncommitted outside the tracker.
8. **Tell the human the verdict.** "Plan is ready — run `/team-rocket:rally`," or "Not ready — blocked on [open question / spike]."

## The Three Lenses (what each role owns)

| Lens | Phase 1 — understand the problem | Phase 2 — interrogate the solution |
|---|---|---|
| **Meowth** | the problem, the why, the history | prior context & landmines |
| **James** | concrete behaviour, edges, scope, constraints | buildability & scope |
| **Jessie** | how we'll know it's done; contradictions | testability, verification setup, design quality |

The lead is the fourth voice: runs the evidence gate, consolidates the questions, arbitrates the design, records the decisions. The human is the source of truth for the problem — and only for the problem; the repo is the source of truth for the code.

## Anti-Patterns

- **Asking the human what the repo already answers.** The evidence gate exists precisely for this. "What's the default branch?", "which module does X?", "what does the test convention look like?" are homework, not questions.
- **Accepting a vague answer to move faster.** "Roughly", "probably", "you know what I mean" are prompts to drill, not to proceed.
- **Designing before the problem statement is confirmed.** Phase 2 on an unconfirmed Phase 1 is building on sand.
- **Inferring an answer the human didn't give — on a question evidence can't settle.** Silence is not consent. Re-ask. (But an answer found in the evidence is an answer; asking anyway is the opposite failure.)
- **Asking everything at once, or three lenses asking the same thing thrice.** The lead consolidates; batch by topic; follow the thread.
- **Leaving confirmed answers only in the conversation.** Persist at the moment of confirmation; audit before closing the huddle.
- **Agreeing instead of interrogating.** If the lenses just nod, the huddle did nothing. Find the holes.
- **Writing code in the huddle.** Planning mode produces tracker artefacts, not diffs.
- **Analysis paralysis.** Drill hard on what makes the *problem* clear; genuine external unknowns become named spikes, not blockers. The huddle makes the plan ready, not perfect.
