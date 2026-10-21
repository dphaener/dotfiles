# Building the route

How to turn a pile of changed files into 5–12 groups that read as one story. This is the highest-leverage part of the tour: a good route makes an unfamiliar codebase legible, and a bad one is just `git diff` with extra words.

> **Terminology.** This file predates the move to one-hunk stops and says "stop" throughout where it now means **act**. An act is the unit of intent; a stop is one hunk inside it. Everything below about grouping, ordering, and `WHY HERE` applies to acts — and `WHY HERE` is now the act banner. The 5–12 target is a target for acts, not stops; stops routinely run 30–50 on a real PR.

## Contents

- [The principle](#the-principle)
- [Finding the arc](#finding-the-arc)
- [Grouping files into stops](#grouping-files-into-stops)
- [Per-stack layering](#per-stack-layering)
- [When narrative order is the wrong answer](#when-narrative-order-is-the-wrong-answer)
- [Two changes wearing one hat](#two-changes-wearing-one-hat)
- [Route smells](#route-smells)

## The principle

The author didn't write this change in alphabetical order. They had a sequence in their head: this has to exist before that can work, and once that works this other thing becomes possible. Recovering that sequence is the job.

The test for whether you've got it: each stop should have a **WHY HERE** line that references the previous stop and is actually true. "Stop 2 added the column; this is its only writer." "Stop 4 made the service return a Result; this is the caller that has to handle the failure branch." If you find yourself writing "this is another part of the change," the route is arbitrary and you should reorder before starting.

## Finding the arc

Cheap, high-signal inputs, roughly in order of usefulness:

1. **Commit messages on the branch**, from `gh pr view "$PR" --json commits`. The author's own chapter titles. A branch with clean incremental commits has usually handed you the route already — don't discard it for a theory of your own.

   Take these from `gh`, not from `git log origin/main..HEAD`. The local `origin/main` ref lags the PR's real merge base, so that command reports tens of KB of unrelated history and can blow a tool result. And in a **squash-merge repo there is only ever one commit**, so this top-ranked input is structurally absent — don't read its absence as a signal about the PR. Where that's the case, the PR body and the review threads carry the ordering, and `[why]` leans on them plus `git blame` rather than the commit list.
2. **The PR description.** Especially any numbered list of changes. Authors describe changes in the order they think about them.
3. **Dependency direction in the diff itself.** Grep the new symbols. A method defined in one changed file and called in another orders those two files with no ambiguity.
4. **The linked ticket**, if the branch name or body references one. Tells you the *goal*, which is what separates the load-bearing stops from the incidental ones.
5. **File type layering.** The fallback when the above is thin — see below. Use it last, not first; it's a heuristic standing in for the author's intent, not a substitute for it.

## Grouping files into stops

A stop is a unit of intent. Some shapes that come up constantly:

**Split across files, one stop.** A migration plus the model change that depends on it. A new service plus the interface it implements. A React component plus its hook plus its test, when the test is what documents the intended behavior. If explaining one requires the other, they're one stop.

**One file, several stops.** A 600-line controller where the PR touched auth in one place and pagination in another. Two concerns, two stops, same file listed twice with different line ranges. That's fine and clearer than one sprawling stop.

**Many files, one sentence.** Lockfiles, generated API clients, protobuf output, codemod renames across 40 files, formatting-only churn. Fold them into a single stop, place it last, describe it in a sentence or two, and move on. Reading `yarn.lock` teaches nothing; spending a stop on it teaches the reviewer that stops are sometimes a waste of their attention.

**Mechanical means generated or repetitive. It never means small.** This is the distinction that goes wrong most often. A `+3` diff to a status union looks like noise and is load-bearing if a poller elsewhere branches on that union — fold it away and you've buried the only forward-facing risk in the PR at stop 9. Ask what switches on the thing being changed, not how many lines changed. When a small diff alters a contract, it belongs with that contract: "one fact, three places" is a good stop, pairing a PG enum, a Ruby enum, and the TypeScript union that mirror each other.

**Small central-registry additions go with the behavior they enable.** Feature flags, enum values, i18n translation keys, route tables, constants files — these are too thin to hold a stop, aren't generated so they don't belong in the mechanical fold, and they show up together constantly. Fold each into the stop whose feature it switches on: the flag with the gate that reads it, the translation keys with the component that renders them, the route entry with the page it points at. They're the seam of the change, not scenery.

**Tests: inline or terminal, depending on what they are.** A test that *documents the new behavior* belongs with the code it documents — it's often the clearest explanation of intent in the whole PR. A test that's mechanical fallout from a signature change (fifty specs updated to pass one more argument) goes in the mechanical stop. Judge each test file, don't apply one rule.

Rough target is 5–12 stops. Under 5 and you're listing files rather than telling a story. Over 12 and the reviewer loses the thread — merge the small ones.

## Per-stack layering

The fallback ordering when the commits and description don't reveal an arc. Each is "what has to exist before the next thing can work."

**Rails**

1. `db/migrate/` — schema. Everything else assumes it.
2. `db/data/` or batch migrations — backfills that make the schema meaningful.
3. `app/models/` — validations, associations, scopes, and any `account_scoped` declaration.
4. `app/services/`, `app/interactors/`, jobs — the behavior.
5. `app/controllers/`, serializers, routes — the surface.
6. `app/abilities/` / CanCan — who's allowed. Frequently the real risk in a PR and frequently unremarked.
7. `spec/` — with their subject, or in the mechanical stop.

Auth and account scoping deserve their own stop even when small. In a multi-tenant Rails app that's where the expensive mistakes live.

**React / TypeScript**

1. Types, schemas, generated API clients — the contract.
2. Services / query hooks / React Query keys — data access, and cache-invalidation changes that are easy to miss.
3. Shared hooks and utilities.
4. Leaf components.
5. Composed components, pages, routes.
6. Tests.

Cache key and invalidation changes are worth calling out explicitly: they're two-line diffs with effects that show up three components away.

**Go**

1. Types, interfaces, protobuf/generated code.
2. Core packages with no internal dependencies.
3. Packages that depend on them, inner to outer.
4. `cmd/`, handlers, wiring.
5. Config and deployment.
6. Tests.

Watch for interface changes with implementations in files the PR didn't touch — the compiler caught it, but the reviewer should see the blast radius.

**Terraform / Terragrunt**

1. Variables, locals, module inputs.
2. Data sources and IAM — read these carefully, they're the security surface.
3. Resources, ordered by dependency.
4. Outputs.
5. Per-environment `terragrunt.hcl`.

For infra, "what does this destroy and recreate" outranks narrative order. Anything with a `force_new` effect belongs in a stop of its own, early.

**Mixed-stack PR (Rails API + React client, say).** Follow the data: schema → model → service → controller → generated client → query hook → component → tests. One story crossing the boundary, not two parallel tours. The boundary crossing is usually the most instructive stop in the whole PR.

## When narrative order is the wrong answer

**A one-line bug fix.** The story is the bug, not the sequence. One stop: what broke, why this line fixes it, whether a test now covers it. Don't manufacture nine stops out of a two-file PR.

**A revert.** Order by what comes back and what stays gone. The interesting question is whether the revert is clean or whether something downstream now dangles.

**A pure refactor with no behavior change.** Order by risk instead: the places where the refactor could have changed behavior, then the mechanically safe bulk. "Is this actually behavior-preserving?" is the only question the reviewer has.

**A dependency upgrade.** Order by blast radius: breaking API changes first, then call-site updates, then the lockfile. The changelog is a legitimate input here.

**A PR where migrations lock a hot table.** Narrative order would bury it at stop 1 as boring setup. Say plainly at the top that this one is irreversible and everything downstream isn't, then continue.

## Two changes wearing one hat

Sometimes a PR is a feature plus an unrelated drive-by fix. Signals: the diff has two clusters with no symbols in common, or the commit log has an "also, while I was in here" commit.

Don't interleave them — that's what makes such PRs hard to review. Say so up front ("this is really two changes; touring the auth fix first, then the pagination work, 4 stops each"), then tour each as its own arc.

Worth mentioning to the reviewer that it *could* have been two PRs, once, in one sentence. Not more — the author isn't going to split it now and it's not what the reviewer asked you for.

## Route smells

Reorder before you start touring if any of these are true:

- A **WHY HERE** line you can't write without hand-waving.
- A stop that's one lockfile, one generated file, or one formatting change.
- Something small folded into the mechanical stop that another file switches on. Check what reads it before you call it noise.
- The reviewer would have to hold an unexplained symbol in their head for three stops before you explain it.
- The riskiest thing in the PR shows up at stop 8.
- Stop 1 is a test file. Tests explain intent, but only once the reviewer knows what's being tested.
- More than 12 stops. Merge.
