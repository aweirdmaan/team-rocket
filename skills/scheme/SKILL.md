---
description: Hatch a new scheme. Scaffold a story (umbrella + goals + implementations) in the project's task tracker. Pass the story ID as argument.
---

Hatch a new scheme — scaffold the team-rocket story structure for a new piece of work in whichever task tracker the project uses.

The lead provides: `$ARGUMENTS` — at minimum a story / ticket ID. Title and description are optional; ask if not provided.

## What "Scaffolding a Story" Means

Team Rocket expects a three-level hierarchy:

```
story (umbrella)                ← the thing being worked on
├── EDA / discovery (prereq)    ← understand the problem before implementing
├── goal 1 (WHY + WHAT)         ← acceptance row N
│   └── implementation 1 (HOW)
├── goal 2 (WHY + WHAT)
│   └── implementation 2 (HOW)
└── ...
```

Goals are immutable once approved. Implementations can iterate.

## Steps

1. **Parse the arguments.** Extract the story ID. If title/description aren't provided, ask the lead.

2. **Read `TEAM-ROCKET.md`** (created by `/team-rocket:blast-off`) to find:
   - Which task tracker the project uses
   - The CLI / API access pattern
   - The story-hierarchy convention (parent links, labels, prefixes)

   If `TEAM-ROCKET.md` doesn't exist, the project isn't set up — run `/team-rocket:blast-off` first.

3. **Create the umbrella story** with the title and description the lead provided. Use whatever the tracker calls a parent type (epic, story, feature).

4. **Create the EDA / discovery prereq** as a child task. Description: "Understand the problem space before defining goals. Read the relevant files, map the dependencies, identify constraints, and (if the story comes with a test matrix or acceptance row list) map each row to either an existing test or a new one. No code." Acceptance: "Problem space documented. Goal candidates drafted with INVEST. Ready to define WHY + WHAT for each goal."

5. **Create 2-3 placeholder goal items** as children. Each with:
   - Title: "Goal N — define after EDA"
   - Description: "WHY: to be defined after EDA. WHAT: to be defined after EDA."
   - Acceptance: "To be defined. Use INVEST criteria: Independent, Negotiable, Valuable, Estimable, Small, Testable."

6. **Wire dependencies** so the goals are blocked by the EDA prereq (the lead's tracker should support this; if not, note it in the umbrella).

7. **Don't create implementation tasks yet** — those get filled in after EDA when the design is real.

8. **Tell the lead:**
   - The story has been scaffolded with an EDA prereq and placeholder goals.
   - Next: work the EDA task to understand the problem space.
   - Then run `/team-rocket:plan` — convene the cluster to interrogate the draft from all three lenses, turn the placeholder goals into real WHY + WHAT (INVEST), sketch the HOW, and bring the plan to the Definition of Ready.
   - Only once the plan is ready does `/team-rocket:rally` pick it up for implementation.
   - Whatever your tracker's "show ready work" command is, that's the lead's regular check-in to find what's actionable next.

## INVEST Reminder

When refining placeholder goals into real ones:

- **Independent** — can ship without the other goals
- **Negotiable** — scope is open to discussion
- **Valuable** — ties back to a real acceptance criterion the user / stakeholder cares about
- **Estimable** — clear enough to size
- **Small** — one PR-sized change, not "do everything"
- **Testable** — a binary outcome you can write a test for

If a goal violates any of these, split or rephrase it.

## Anti-Patterns

- Don't create implementations before goals are defined. The design depends on the acceptance.
- Don't skip the EDA prereq. The most common project failure is implementing before understanding.
- Don't approve a goal whose WHAT is "improve X" or "make it better" — that's not testable.
- Don't create goals that depend on each other in a chain (violates Independent). Split or merge.
