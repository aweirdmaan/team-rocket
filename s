1. One workflow file. The nodes for ideate → plan → implement → validate → review → retro.
-> validate and review is same
- Meowth is the planner-discoverer. Given WHY and WHAT, he digs through the code, drafts the HOW, cites every source, and logs every decision with its reason. Straight into beads as comments. I'll design a small comment structure: decision, reason, evidence, alternatives rejected.
-> meowth should use opus
- Jessie reviews the HOW in planning and verifies the result after implementation, including your new point: prove nothing that already worked broke.
-> jessie also uses opus
- James executes. No discovery, no design thinking. The task tells him what and how. Agreed that discovery-while-implementing was a sign the plan wasn't done.
-> james uses sonnet

Commit size. My recommendation: your option 1. One logical change, target 50–150 changed lines, hard flag above 300. Reasons: it's measurable in review with git diff --stat, needs no per-language tooling (cyclomatic complexity does), and "one function/class" breaks on config and DAG changes. It also connects to estimation: a grape-sized task should land in 1–3 such commits, or it wasn't a grape.
-> the highlight here is on a logical change and then the diff size.

Estimation. I'll pull the fruit-salad article and draft our grape definition in the redesign doc: the unit task one implement iteration finishes. Planning splits until everything is grapes.
-> be vary of what all you put in there, don't want ai slop again
