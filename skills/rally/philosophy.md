# Team Rocket — The Philosophy

The rules in `playbook.md` describe *what* to do. This document describes *why*. When the rules don't cover a situation — and they won't — agents fall back to the principles here.

## Simplicity is the minimum cognitive load needed to fully understand the code's correctness and intent

Every line, name, abstraction earns its place by paying for itself in clarity or capability. Anything that doesn't, costs. The cost is paid by every future reader (yourself, six months from now; the next agent; the senior engineer reviewing the PR). The benefit must be tangible enough that the cost is repaid each time.

This is not a rule. It's the lens. Every other rule below is a consequence of applying this lens to a recurring situation.

## Principles are residue, not commands

"Don't do defensive coding", "no Some/None inside a transform", "use the codebase's vocabulary", "inline trivial helpers" — these aren't independent rules to memorise. They're what falls out when you apply the simplicity lens to common situations.

When a rule and the lens disagree, the lens wins. The rule was a heuristic; the lens is the source.

## Ask five whys before adding anything

Before adding any abstraction — a helper, a sealed trait, an implicit, a wrapper case class, a configuration map, a generic, a new package — run five "why does this exist?" against it. If depth-three lands on:

- "In case we need it later"
- "DRY says so"
- "For symmetry"
- "Other transforms have it"
- "The pattern looks similar"

The thing doesn't exist. Delete it from your plan and write the inline form instead.

This is mechanical. Run it. Don't trust your taste; trust the depth-three answer.

## Design on truth, not assumptions

If you discover a missing concept while writing the code, that's not "exploratory programming". That's a sign the upfront grounding was thin. Better grounding before the first line: read the surrounding code, read the related task notes, read prior reviewer feedback on this area, ask the lead a clarifying question. Correctly-planned implementations rarely discover concepts mid-flight.

## Audience-aware simplicity

"Simple" is relative to the reader. Code that reads cleanly to a Scala-fluent reader is fine in a Scala codebase; the reader is expected to be fluent. Code that reads cleanly to a beginner is fine in a tutorial; the reader is expected to be a beginner. Calibrate to the codebase's actual maintainers, not to a hypothetical novice.

Corollary: idiomatic constructs (`.fold`, `.map`, `.flatMap`, for-comprehension on Option, pattern matching on sealed traits) are fine when they read cleanly to a fluent reader. Don't reach for the imperative form just because it has fewer concepts. But also don't reach for the functional form just to look sophisticated — three operations chained on `Option` is fine; six is showing off.

## Honest naming

A name is a promise. If the codebase already uses "normalize" to mean a specific concept (e.g. record deduplication), introducing `withNormalizedFields` for "column rename + cast" overloads the promise. Future readers will hit the name expecting one meaning and find another.

Two checks before naming something:

1. Is the codebase already using this word? If yes, am I using it the same way?
2. Does the name carry weight the body delivers? A function called `assembleAuthenticatedRequest` had better do more than `request.copy(authed = true)`.

When the codebase doesn't have an existing term for the new concept, introduce one consciously — own the tradeoff of bringing a new word in.

## Closed universes are not open universes

When the set of cases is known at compile time and finite (markets: A/B/C; source types: csv / json / stream-join / passthrough), use the construct that lets the compiler check exhaustiveness — pattern match, sealed trait, enum. When the set is open (user-provided keys, dynamic strings), use a map.

Building a map to dispatch over a closed universe is overhead. Pattern-matching dynamic strings is unsafe. Match the construct to the universe.

## No defensive code for impossible cases

"This can't happen in production but the test might hit it" is not a reason to keep a guard. Either:

- The production guarantee is real → delete the guard, let it fail loud if violated.
- The production guarantee is shaky → fix the upstream contract, not the downstream defence.

Defensive guards quietly accumulate. Each one says "I don't trust the caller", and one day someone reads them and concludes correctly that the caller can't be trusted. Now the contract is the union of the guards, not the documented one.

## Inlining is the default; extracting is the special case

A helper that's used once is usually noise — it adds an indirection (jump to definition) for zero reuse benefit. Extract only when:

- The name carries meaning the inlined form doesn't (e.g. `normalizeEmail(raw)` is meaningful; `lowercaseString` is not).
- There's genuine reuse (three or more call sites, not "we might use it later").
- The body hides real complexity worth labelling.

Three similar lines is better than a premature abstraction.

## Tests are not separate from code

Code without tests is not code that's missing tests; it's code that doesn't exist yet. Tests are written *with* the code, not after. AAA. One reason to fail per test. Assertion stronger than the regression you're guarding against. Use the codebase's existing test utilities and conventions.

The integration test of the whole app is the integration test of the whole app — it tests integration, not individual functions. Component tests test individual functions. Don't mix.

## When you're not sure, ask

The cost of a clarifying message is small. The cost of building the wrong thing is large. "When in doubt, ask" is not a soft rule — it's the cheap option. Don't barrel through ambiguity. Don't make crazy assumptions. Ask pointed questions and demand pointed answers.

If the lead is unclear, say so. "I don't know what you mean by X" is more useful than "I'll figure it out and show you something."
