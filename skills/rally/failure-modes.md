# Team Rocket — Named Failure Modes

This is the canonical list of code smells that James must self-check against before commit, and Jessie must check against during review. Each entry: the smell, why it's a smell, the simpler alternative.

These are the patterns we keep hitting. Recognising them by name short-circuits the design conversation.

This list is a diagnostic tool in service of the quality bar in `philosophy.md` — not a checklist to complete. Reach for the entry that's biting; don't run the whole list as a ritual on a diff that plainly doesn't warrant it. The goal is simpler code, not a clean scan.

**See `examples.md` for code snippets of each smell** — visual bad/good pairs cut through the prose argument when it isn't landing.

> **Note on language.** Several entries name Scala-specific shapes (sealed traits, implicit classes, case-class wrappers, currying), because that's where these examples read most cleanly. The *underlying smell* in each is language-neutral — unnecessary indirection, premature abstraction, dispatch logic in the wrong place, names that lie. Read past the Scala vocabulary to the principle, and translate the example to your language's equivalent (a TypeScript discriminated union, a Python dataclass wrapper, a Go interface with one impl). Record genuinely language-specific exceptions for your codebase in `TEAM-ROCKET.md` under "Codebase exceptions to the failure-modes list".

---

## Dispatch tags

**Smell.** A sealed trait (or enum) whose only purpose is to be matched on by a dispatcher, where each case is wired to a different function. The trait carries no behaviour, only identity.

**Why bad.** The "type" of the variant is a label the dispatcher reads to look up the function. The dispatcher could just hold the function directly. The trait + dispatcher is two layers of indirection where one would do.

**Better.** Put the function in the data structure directly. `Map[Key, T => U]` instead of `Map[Key, Tag]` + `match { case Tag => fn }`.

---

## Useless wrapper case classes

**Smell.** `case class Wrapper(read: Reader, apply: Apply)` where both halves are functions. The wrapper exists "to group them" but adds nothing.

**Why bad.** Reading the code becomes "look up the type, look up its fields, look up what each field does". The wrapper is grouping that costs a hop.

**Better.** If a pair of functions is always called together, name the *combined behaviour* and have one function. If they're independent, hold them in separate slots.

---

## Some/None pattern matching inside a transformation

**Smell.** A transform function that takes `Option[X]` and pattern-matches `Some` vs `None` internally to produce the same output column either way.

**Why bad.** The case is dispatch logic, and dispatch is the caller's job. The function should take only what it operates on. Splitting Some/None inside the function couples the function to the caller's knowledge of when data is present.

**Better.** Push the case to the call site. The caller decides whether to call the function or skip; the function does its job assuming inputs are present.

---

## for-yield-if generating tests

**Smell.** A `Seq.foreach` or for-comprehension in a test file that generates N tests by iterating over a list of (input, expected) pairs.

**Why bad.** It hides the test names, hides the test count, and obscures *what* each test is checking. It's also un-Scala — the language has direct test constructs; using comprehensions to generate them is fighting the framework.

**Better.** If the cases are independent, write them as separate `in` blocks. If they're the same logical test, fold them into a single assertion with a single expected structure (e.g. structural equality on a whole `case class`).

---

## Helper methods wrapping one-liners

**Smell.** A private method whose body is a single expression that could be inlined. Common when a name is added "to be DRY" but the expression itself is self-documenting.

**Why bad.** Reader has to jump to the helper, read the one line, and jump back. The cost is the jump; the benefit was supposed to be reuse or clarity, but if it's used once or the name doesn't add meaning, neither benefit exists.

**Better.** Inline. If the expression is genuinely cryptic, give the value a local `val` name at the call site instead of extracting a method.

---

## Single-use constants

**Smell.** `private val SomethingNameColumn = "NAME"` referenced exactly once in the same file.

**Why bad.** Same as one-liner helpers — the indirection costs more than it saves. The literal at the call site is usually shorter and clearer than the reference.

**Better.** Inline the literal. Keep the constant only when:

- It's used in three or more places, *or*
- The literal value is non-obvious and the name documents the convention (e.g. `HttpOk = 200`).

---

## Defensive guards for impossible cases

**Smell.** `if (x.isEmpty) return identity; else doWork(x)` or `Option.fold(identity)(doWork)` where production guarantees the value is present.

**Why bad.** The guard says "the caller can't be trusted". If the caller really can't be trusted, the upstream contract is wrong and you should fix it. If the caller is trustworthy, the guard is dead weight that obscures the actual contract.

**Better.** Trust the contract. Let it fail loud if violated. Production failures are easier to fix than silently-degraded behaviour.

---

## Initial pre-fill then overwrite

**Smell.** "Create N null columns, then for each transformation, drop the matching null and add the real value." Two operations doing the work of one, with extra coordination.

**Why bad.** The pre-fill exists to satisfy a "every column must exist by the end" invariant. Each transformation then has to *undo* the pre-fill before it can act. The cost of the pre-fill is paid twice (once to add, once to drop).

**Better.** Don't pre-fill. Each transformation adds the columns it owns. A single post-step fills missing columns with null. One pass, no coordination.

---

## Useless intermediate variable names

**Smell.** `val deduped = ...; val enriched = deduped.transform(...).transform(...)`. The intermediate name promises a concept (`deduped`) that the codebase already uses for a different thing, or is just a label for "the value at this point in the pipeline".

**Why bad.** The name lies (when it overloads existing vocabulary) or adds no information (when it just labels a pipeline stage).

**Better.** Use a name that reflects what the value IS, not where it sits in the pipeline. `invoices` for the invoices dataframe stays `invoices` throughout — the transformations chain onto it. If a meaningful step changes what the value represents, name it after the new thing, not the stage.

---

## Methods that wrap themselves

**Smell.** A class with `read: (Spark, String) => DataFrame` and `apply: (DataFrame, Option[DataFrame]) => DataFrame`, where `apply` has `case Some(loaded) / case None` branches and the caller pre-loads with `read`.

**Why bad.** The class is doing the dispatch the caller should do. The `apply` function's internal cases are a re-implementation of the conditional that the caller already knew.

**Better.** Two functions, separately stored. Caller calls `read` if applicable, then calls `apply` with the loaded result. Or — better — the caller stores both as members of a single value and threads them itself.

---

## Currying for no reason

**Smell.** `def foo(a: A)(b: B)(c: C): D` when no caller ever partially applies. Three parameter lists for what is functionally a 3-arity function.

**Why bad.** Currying signals partial application is meaningful here. If it's not, the curry is misleading.

**Better.** One parameter list, all args together. Curry only when partial application is part of the API.

---

## Implicit class extensions for one operation

**Smell.** `implicit class XOps(val x: X) extends AnyVal { def doThing: Y = ??? }` where `doThing` is called from one place.

**Why bad.** The extension class adds a chain-method form (`x.doThing`) for stylistic chaining. If chaining isn't the point, a plain function is shorter and explicit.

**Better.** Use plain functions. Reserve implicit class extensions for *operations* on a type that genuinely deserve a method-shaped form (used many times across the codebase).

---

## Misuse of vocabulary

**Smell.** Introducing a name that's already in use elsewhere in the codebase for a different concept. E.g. `withNormalizedFields` in a codebase where `normalize` already means record deduplication.

**Why bad.** Names are promises. Reusing a loaded word makes the reader expect the established meaning and find a different one.

**Better.** Before naming, search the codebase for the word. If it's in use, use it the same way or pick a different word.

---

## Generic abstractions for one concrete case

**Smell.** `case class LevelOp(read: (Spark, String) => DataFrame, apply: (DataFrame, String, DataFrame) => DataFrame)` to encapsulate "read then apply", when there are exactly four uses and each is its own concrete pair.

**Why bad.** The case class generalises across uses that aren't actually unified. Each pair would be clearer as its own function in a flat module.

**Better.** Flat module of named functions. The "structure" is in the function names, not in a wrapping case class.

---

## Speculative configuration

**Smell.** CLI flags or config knobs for behaviour that's static per (market, stage) — e.g. `--stage-N-type=csv` when the story already says market A/B/C stage N is always type T.

**Why bad.** The configuration recreates a fact that's already known. The DAG (and the test, and the human) has to specify it every time. One typo in the wrong place silently changes behaviour.

**Better.** Hardcode the static fact. The flag/knob exists only for variation that's genuinely runtime-determined.

---

## When you find a new failure mode

Add it here. The list grows. The principle behind each entry is the same — see `philosophy.md`.
