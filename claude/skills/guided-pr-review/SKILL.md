---
name: guided-pr-review
description: Walk a GitHub pull request hunk by hunk, as a conversation the user takes part in — one real colored diff per message in narrative order, each with why it exists, plus callers, tests, and conventions read from a checkout of the PR head so the user learns the codebase while reviewing it. Use this when the user asks to be walked or taken through a specific PR, wants to review a PR interactively rather than receive a finished report, or is reviewing in a repo or subsystem they don't know: "walk me through PR 4412", "guided review of <PR url>", "review this with me", "take me through this PR piece by piece", "I'm the reviewer on this and I've never touched this pack", "I'd rather understand this code than skim it for bugs". Reach for it whenever a PR review request carries any signal that the user wants to participate or to learn, even a faint one. Do NOT use it when the user wants the review done for them and simply delivered, however it's phrased — including "review PR 123 and post the comments" or a bare "review this PR"; those belong to the built-in code-review skill. Also not for uncommitted local changes, a diff with no PR, summarizing a PR, exploring a codebase with no PR involved, or rewording a comment the user already wrote.
user-invocable: true
---

# Guided PR Review

Walk someone through a pull request the way a senior engineer on that team would: in the order the change actually happened, with the surrounding code pulled in so each piece makes sense, stopping after every piece so they can ask about it.

The point isn't finding more. It's being right about less, out loud, in a way that teaches. The reviewer should come out understanding a codebase they didn't understand before, and the review that lands on GitHub should be theirs — in their voice, containing only what they read and approved.

Five things carry that, and each one fails in a way the reviewer can't detect from the output:

**Show the diff; don't describe it.** The reviewer wants to read the change, not your summary of it. Every stop opens with real diff output and the prose comes after. This is the failure this skill is most prone to: an earlier version of this file put `[relevant hunk, trimmed]` *after* a prose paragraph and told the agent "don't narrate the diff line by line," and the predictable happened — the prose grew, the diff shrank to an illustrative snippet, and a reviewer got a summary they didn't ask for. Prose that displaces the diff is the defect, not the deliverable.

**Read from a checkout of the PR head.** Not the diff alone, not the user's working tree. A review written against a stale local `main` doesn't just miss things — it manufactures confident false claims. Real example: an agent reviewing an August PR from a July checkout announced "this is the first `add_enum_value` migration in the repo" (a July migration already used it, on the same enum type) and criticized the author for a `safety_assured` block that was copied byte-identically from a migration merged two days earlier. Both claims were about *convention*, which is exactly what the reviewer is relying on you for.

**Stop after every stop.** A tour that prints six hunks in one message is not a tour, it's a report. The reviewer asked to be walked through it because they want to interrupt — to ask what a class does, to disagree, to say "wait, go back." Emitting several stops at once converts the mode they asked for into the mode they didn't. One hunk per message, then stop talking.

**Go look; don't infer.** "This looks fine" teaches nothing, and a plausible guess about a caller is worse than silence. The legwork is the product — and it earns its cost mostly by *removing* wrong findings. In one session two concerns were drafted and retracted before display, both because reading a Ruby file settled a question raised by a TypeScript diff. Those retractions were the session's best output.

**Nothing posts that the reviewer didn't read.** Comments are shown one at a time, approved one at a time, and submitted as one review at the end. An agent that quietly appends four more findings to the payload has published four opinions under someone else's name.

## Resolve the target

Accept a PR number (`4412`), a URL, or `owner/repo#4412`. A bare number means the current repo.

```bash
gh pr view "$PR" --json number,title,body,author,url,state,isDraft,mergedAt,\
baseRefName,headRefName,isCrossRepository,additions,deletions,changedFiles,commits,reviews
```

If `gh` isn't authenticated or the PR can't be resolved, say so and stop — don't fall back to guessing from local branches.

**Prior discussion lives on a different endpoint than you'd expect.** `reviews` carries review-level bodies, which are very often all empty — one real PR returned 13 review records with no body text at all, because every substantive point was an inline comment. Fetch those too:

```bash
gh api "/repos/$OWNER/$REPO/pulls/$PR/comments" --paginate \
  -q '.[] | "\(.path):\(.line // .original_line) \(.user.login): \(.body)"'
```

Read them before building the route. Re-raising a point the team already settled is the fastest way to look like a bot, and skipping this is how that happens.

**Check `state` and `mergedAt`.** A merged or closed PR is a legitimate thing to walk — reviewing merged code is one of the better ways to learn a codebase — but it changes what the session *is*. Say so up front, tour normally, and frame concerns as follow-ups rather than change requests. Don't offer to submit a review unless the reviewer asks; `REQUEST_CHANGES` on merged code is meaningless and `[comment]` mostly is too. If they do ask, a post-merge comment is a fine way to leave a note for whoever touches it next.

A draft PR is usually mid-thought — worth mentioning before spending an hour on it.

## Check out a worktree

You need the whole tree, not just the diff. Callers, tests, and sibling files all live outside the changed lines, and they're where both the understanding and the false-claim protection come from.

```bash
git fetch origin "pull/$PR/head:pr-$PR-review" --force   # works for forks too
git worktree add /absolute/path/to/wt "pr-$PR-review"
```

**Resolve that path once, print it, and use the literal absolute path from then on.** Each Bash call is a fresh shell, so a `$WT` built from `$TMPDIR` gets re-derived every time — and `$TMPDIR` is not guaranteed to resolve the same way twice. A worktree created under one value and looked for under another simply isn't there, which has cost real sessions real time.

Read code from the worktree, never from the user's checkout — theirs is on some other branch, and mixing two versions of the code into one review is how the stale-`main` failure above happens.

Remove the worktree when the session ends (see Cleanup).

## Build the route

Read the entire diff before touring anything (`gh pr diff "$PR"`). You can't order a story you haven't read.

**A stop is one hunk.** Not one file, not one unit of intent. One hunk, one message, one `WHY`. A twelve-file PR is commonly 30–50 stops, and that is the expected shape rather than a problem to optimize away. The reviewer asked to see diffs; a hunk is the unit a diff comes in.

**Scale the unit to decision density, and say when you switch.** One hunk per stop is right where the code makes a decision every few lines — a transport with retry and redirect handling, an auth path, a state machine, anything with an invariant attached. It is wrong where a file is a *list*: test modules (a sequence of cases), fixtures, lockfiles, generated clients, codemod churn, translation files. There, one stop per **file** is the honest unit, with the diff shown in full and the `WHY` covering what the file now proves rather than what each hunk does.

Get this wrong in the tedious direction and the reviewer tells you, several stops after you lost them. So decide it per file during enumeration, count it into the total, and name the switch when you reach it ("the next four stops are one per file — they're test modules"). If a reviewer says the walk is dragging, this is the knob: drop to file-level for what remains, don't drop the diffs.

The reason this asymmetry is worth the trouble: walking production hunks individually is what surfaces findings a file-level read cannot. Errors escaping a `try` that ends two lines early, a parameter audited across every call site, a guard nothing reaches. Those come from being forced past every line. Test files have no equivalent payoff — their findings are "this case is missing" and "this fake lies," both visible from the whole file at once.

Hunks still need an order and they still need a story, so that work moves up one level. Group the hunks into **acts** — an act is the old unit of intent, and everything `references/narrative-ordering.md` says about ordering "stops" now applies to acts. Then order the acts as the change's own narrative and order the hunks inside an act the way the code reads. Six acts over forty hunks is a normal shape.

Order the acts as the change's own narrative: what had to exist first for the next thing to be possible. Derive it from this PR rather than applying a template — the author had an intent and you're replaying it. The commit list from `gh pr view --json commits` is the best signal (don't reach for `git log origin/main..HEAD`; the local ref lags the real merge base and dumps tens of KB of unrelated history). In a squash-merge repo there's only ever one commit, so the PR body and the review threads carry the ordering instead.

**A change with one concern is one stop** — a one-line bug fix, a revert, a three-line ordering fix. One hunk, one act, done. Don't manufacture acts to make a small PR feel structured.

### Enumerating the hunks

Do this once, from the worktree, before stop 1, and hold the list for the rest of the session. The two cases need different handling and the second one is where this goes wrong.

**Existing files — git already knows where the hunks are.** Take them verbatim:

```bash
BASE=$(gh pr view "$PR" --json baseRefName -q .baseRefName)
git diff "origin/$BASE...HEAD" -U10 -- <path>
```

`-U10` rather than the default `-U3`: a three-line change inside a long method is unreadable at three lines of context. Three dots, not two, so the diff runs against the merge base instead of a base branch tip that has moved since.

Never re-flow, re-order, re-indent, or trim what git prints. The `@@` header, the leading space on context lines, and the `+`/`-` column all pass through untouched.

**New files — git emits the whole file as one hunk.** `@@ -0,0 +1,369 @@` is not a stop, it's a book, and this is exactly where an agent gives up and writes prose instead. Chunk it yourself at declaration boundaries: the import block, each block of module constants, each top-level `class`, each `def` together with its decorators and docstring. Read the file with the Read tool first so you have true line numbers, then give each chunk its own stop with an arithmetically honest header:

```
@@ +110,28 @@ WorkflowsClient._post
```

`110` is the real first line in the worktree and `28` is the real line count — compute both, don't estimate. Every content line keeps its `+`. Put `(new file)` on the location line so the reviewer knows git didn't draw that boundary, you did.

A chunk past ~60 lines gets split across two stops and the split is announced (`STOP 14 of 41 · part 1 of 2`). Never silently show half a function.

**Collapse the mechanical into one terminal stop and don't walk it hunk by hunk.** Mechanical means *generated or repetitive* — lockfiles, generated clients, protobuf output, codemod renames, formatting churn. A lockfile is 400 hunks and zero of them are worth a message. Name the files, give the line counts, show nothing or one representative hunk, and say what you checked for. **Mechanical never means small.** A three-line change to a union type that a live poller branches on is load-bearing, and burying it as noise hides the only forward-facing risk in the PR. When a small diff changes a contract something else switches on, it belongs in the act that owns that contract, however few lines it is.

**Count honestly and say the total.** The `of 41` in the header is a real count taken from the enumeration, not a guess you refine later. If the count lands past ~60, say so before stop 1 and offer to collapse a tail act or two — a reviewer who knows it's 74 stops can choose; one who discovers it at stop 30 has been ambushed.

Then start.

**A short preamble before stop 1 is fine and often necessary** — the PR's state, that prior discussion exists, the total stop count, or the one structural fact that reframes everything ("this diff is frontend-only; the server contract it describes doesn't exist yet"). What doesn't belong there is the route itself. The `STOP 14 of 41 · act 2 of 6` header carries position, `[map]` is there when they want the shape, and printing forty labels up front invites the reviewer to skim instead of walk.

## The tour

**The diff comes first in the message.** Before the why, before the concerns, before any prose at all. Every other rule in this section exists to protect that one. If a stop would open with a sentence about the code instead of the code, it is wrong — rewrite it.

Each stop looks like this. The shape matters: the reviewer learns to skim it, and a stop that reorders or drops sections makes them read it fresh every time.

`````
STOP 14 of 41 · act 2 of 6 · the Workflows transport
service/workflows_client.py:159-171  (new file)

```diff
@@ +159,13 @@ WorkflowsClient._post
+                if 300 <= response.status_code < 400:
+                    metrics.increment(
+                        "workflows_call_errors_total",
+                        {"flow": path, "status": str(response.status_code)},
+                    )
+                    raise WorkflowsError(
+                        f"workflows_redirect_refused: flow={path} "
+                        f"status={response.status_code}"
+                    )
```

WHY
  Two flows discard `_post`'s return value. A 3xx is neither retryable nor
  >= 400 and its body is normally empty, so without this branch `_post`
  returns `{}` and both flows read a redirect as a successful write.

FITS
  Tested by:  tests/test_workflows_client.py:125 and :137 — once through a
              flow that ignores the body, once through one that expects a model.

CONCERNS
  None.

[next] [why] [deeper] [comment] [back] [map] [skip act] [done]  — or ask me something
`````

The first stop of an act gets a banner above all that. No other stop does:

```
── ACT 2 of 6 · the Workflows transport ──────────────────────────
Act 1 built the value objects every one of these methods returns.
This is the transport that fills them. Nothing calls it yet.
```

That banner is where the old `WHY HERE` went. It ties this act to the last one and is what makes a sequence of hunks a story instead of a list. If you can't write it for a middle act, the route is wrong; reorder.

Notes on the sections:

- **The location line** is `path:first-last` read from the worktree, plus `(new file)` when you drew the chunk boundary rather than git. Both numbers are read, never counted by hand off a patch.
- **The diff** is verbatim git output in a ```diff fence, or a declaration-sized chunk of a new file with every line `+`-prefixed. See *Rendering the diff* below. It is never a paraphrase, never re-indented, and never replaced by a description of itself.
- **WHY** is one to four lines: why this change exists, or what breaks without it. It is not a restatement of the diff — "adds a `status` field" is not a why; "the notification callback has nothing to key idempotency on without it" is. When the reason isn't recoverable from the PR body, the commits, or blame, say so in one clause and move on. A fabricated rationale is worse than "no stated reason."
- **FITS** carries `Called from`, `Tested by`, and `Convention`, and **you omit every line you have nothing real for.** At hunk granularity most hunks earn one line and plenty earn none — drop the whole section rather than pad it. `Called from` means you grepped and found real call sites, or found none and say so; an uncalled new method is worth knowing. `Tested by` means you opened the test and know whether it covers *this hunk*. `Convention` means you read the neighbors. Never fill these with guesses; "I didn't find any callers" is useful and "probably called from the controller" is worse than silence.
- **CONCERNS** is severity + `file:line` + one sentence. At this granularity `None.` is the common and correct answer — most hunks are fine, and a manufactured nitpick on each one trains the reviewer to ignore the section entirely. Rank by what could actually hurt: data loss and security, then correctness, then missing tests. For latent risk — a pre-consumer feature where nothing is broken yet — grade by how likely someone is to step on the trap and how silently it fails, not by how bad it sounds in the abstract.

### Rendering the diff

Fence every diff as ```diff. That fence is what colors it: `+` lines green, `-` lines red, `@@` headers cyan, in the terminal the reviewer is actually reading. A bare ``` fence gets flat gray text, and ```python highlights syntax while erasing the change signal — which defeats the point of showing a diff.

Two constraints follow from how the highlighter works.

**Color comes from the leading character, so the leading character must survive.** Never strip the `+`/`-`/space column to make code line up, and never re-indent a hunk to look tidier. A de-prefixed diff renders as undifferentiated gray, and the reviewer loses the one signal they asked for.

**Don't reach for ANSI.** `git diff --color=always`, `delta`, and `diff-so-fancy` all emit escape codes, and this output is rendered as markdown in a terminal rather than piped to one, so the codes arrive as literal garbage. Generate plain diff, fence it, and let the renderer color it.

Inside a ```diff block you give up language highlighting. That trade is correct here: the reviewer is reading what changed, not admiring the syntax.

### Getting file:line right

Any `file:line` you show the reviewer must be **read with line numbers from the worktree** — the Read tool, or `cat -n` — never counted by hand off a patch. Hand-counting drifts by one or two, and a citation that points at real-but-wrong code (a *different* shared example 6 lines up) costs you the reviewer's trust in everything else in the stop. Hunk-header arithmetic has exactly one use, and it's computing comment anchors for the GitHub API.

Two related honesty rules. **Don't state a count you didn't count** — a table of 13 rows labelled "12 call sites" makes a reviewer re-verify the whole stop. And when a claim rests on code outside the diff, **say which tree you read it from** if that could matter: on a merged PR, `main` has moved, and a claim that's true of the PR's base can read as flatly wrong against the reviewer's checkout. One clause does it: "(on the PR's base — `main` has since changed this)".

### The verbs

- **next** — advance one hunk. Also empty input, "ok", "got it", "yep".
- **why** — the author's reasoning, from evidence: the PR body, the commit list, `git blame` on the touched lines, the review threads, the linked ticket. This is the deeper version of the stop's `WHY` line, and it's the one place prose is the whole answer. Say plainly when the reason isn't recoverable. For example: *"The PR body says the reorder was to make the timeout branch reachable. Blame says line 58 was written in #4102 six weeks ago by the same author, whose message is 'set pending_at after the charge so we don't mark unpaid invoices pending' — the exact opposite. Nothing explains the reversal; the ticket is one line. Best guess is they hit the timeout case in staging, but that's inference, not evidence."*
- **deeper** — the surrounding declaration in full, the whole changed file, the callers' bodies, the test bodies. At hunk granularity this is asked for often; answer with code, not summary.
- **comment** — draft a review comment here (see below).
- **back** — re-render the previous hunk.
- **map** — print the act list: each act, its hunk count, and which one they're in. This is the pressure valve for a forty-stop tour, because position in the header alone isn't enough to hold the shape. Print it whenever asked; printing it unasked before stop 1 is still wrong.
- **skip** — abandon this hunk, advance one.
- **skip act** — abandon the rest of this act, jump to the first stop of the next. Say how many hunks you skipped so nothing disappears silently.
- **done** — jump to submission with whatever comments exist.

Anything that isn't a verb is a question. Answer it from the worktree, then re-offer the verbs. This is the most common thing that happens and the most valuable — "what is `Retryable`?", "does anything else write this column?" are the questions that teach the codebase. Read the code and answer specifically; never answer from inference when the file is right there.

### When they push back

If the reviewer disagrees with a concern, re-examine it for real. Then either defend it with evidence they can check — a file and line, a call path, a test that doesn't exist — or retract it plainly and drop it from the review.

Both failure modes are bad in the same way: caving because agreement is comfortable, and digging in because retracting looks weak. The reviewer is calibrating against the codebase, and they can only do that if your position tracks the evidence.

## Drafting comments

When a comment is wanted, draft the full body yourself — the reviewer edits rather than dictates. Then, before showing it to them, **run it through the `humanize` skill** (`humanize:humanize`). These comments post under their name and land in a teammate's inbox; unhumanized model prose is the tell that a bot wrote their review.

Register matters, and the profile at `~/.claude/humanize/voice.md` splits by register:

- **Inline comments** are the **Slack / DM** register. A review comment is a short message to a colleague, not a document. Contractions, answer first, casual hedges, no bold labels, no bullet lists where two sentences do. Note that the register's more playful markers — emoji, sentence-final "lol", stretched words — mostly don't belong on a colleague's PR; the profile's own "zero is fine for formal registers" applies.
- **The PR-level summary** is the **PR / commit** register. A few workmanlike sentences, change first and a plain reason after. The anti-pattern to avoid is the root-cause essay: polished arc, em-dash-dense mechanism paragraph, colon-introduced bullet list, impact statement.

Show the comment exactly as it will post — path, line, side, body — then wait:

```
COMMENT → app/services/billing/charge.rb:58 (RIGHT)

  This reorder is the whole point of the change but the timeout branch
  isn't covered — charge_spec only exercises the happy path. Probably
  worth a spec that stubs the Stripe timeout?

[y] post it  [e] edit  [d] drop
```

Nothing posts yet. Keep approved comments in a running list, and append each one to an absolute path outside the worktree — `~/.cache/guided-review-pr<PR>-comments.json` or similar — as it's approved, so a crash doesn't cost the reviewer an hour of drafting. Don't put it inside the worktree; that directory gets force-removed at cleanup.

**Only approved comments go in the payload.** If the reviewer approved one comment and typed `done`, the review contains one comment. Findings you verified but never showed them are not comments — see below for where those go.

### Line numbers for anchors

GitHub rejects a comment whose line isn't part of the diff, and a 422 after nine stops of work is a miserable outcome. Compute the anchor from the hunk headers: for `side: RIGHT` the new-file line number, for `side: LEFT` the old-file one. When the concern is really about a line the PR didn't touch, don't force it — put it in the summary body with an explicit `path:line` reference. `references/gh-review-api.md` has the payload shape and the failure modes.

Before submitting, pre-flight the payload:

```bash
python3 scripts/validate_review_json.py review.json --repo "$OWNER/$REPO" --pr "$PR"
```

It checks every path against the diff and every line against the hunks, so a bad anchor surfaces now instead of as a 422 that rejects the whole review.

## Submitting

Post everything as one review. A review that arrives in fragments pings the author once per comment and reads as N unrelated thoughts.

1. Write the PR-level summary: what the change does, your overall read, and the two or three things that actually matter. Not a restatement of the inline comments.
2. **Verified findings from stops the reviewer never reached belong here**, with explicit `path:line` references, flagged as not-yet-discussed. Discarding real findings because of the order the conversation happened to take helps nobody — but they go in the summary, not into inline comments the reviewer never saw.
3. Humanize it (PR / commit register).
4. Show the complete review — summary plus every inline comment, in order — and get an explicit go-ahead. This is the last point at which anything is private.
5. Ask which event: `COMMENT`, `APPROVE`, or `REQUEST_CHANGES`. Default to `COMMENT`; never pick the other two on their behalf, since both carry weight in the team's process.
6. Submit:

```bash
gh api --method POST "/repos/$OWNER/$REPO/pulls/$PR/reviews" --input review.json
```

If the API rejects a comment's position, report which one and offer to move it into the summary rather than silently dropping it.

## Autonomous mode

If the reviewer wants no pauses — "just review it", "don't walk me through it", or they bail mid-tour — hand off to the built-in `code-review` skill rather than reimplementing it here. Pass the PR as the target, and `--comment` if they want findings posted inline.

Two things worth carrying over even then: check out the PR head rather than reviewing from a stale tree, and run any comment bodies through `humanize` before they post.

## Cleanup

```bash
git worktree remove /absolute/path/to/wt --force
git branch -D "pr-$PR-review"
```

Do this when the review is submitted or the reviewer walks away. Leave the comments JSON alone — if the session died mid-review, that file is the only copy of their drafts.

## References

- `references/narrative-ordering.md` — grouping hunks into acts and ordering them: per-stack layering, small-central-registry files, splitting a PR that's really two changes, and when narrative order is the wrong answer. It says "stop" where it now means "act"; read its own terminology note first.
- `references/gh-review-api.md` — `gh` and REST recipes: batched review payload, line vs. position, multi-line comments, fork checkout, the 422s and their causes.
- `scripts/validate_review_json.py` — pre-flight a review payload against the PR's diff.
