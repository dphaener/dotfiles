---
name: humanize-init
description: Use when setting up, rebuilding, or refining the personal voice profile that the humanize skill reads — triggers on "set up humanize", "initialize my voice", "build my voice profile", "teach you how I write", "humanize doesn't sound like me yet", or when the humanize skill reports no profile exists. Asks which sources to mine, filters AI-contaminated writing, interviews per register, and writes ~/.claude/humanize/voice.md. Not for drafting or rewriting prose — that is the humanize skill. Also invocable with /humanize-init.
user-invocable: true
---

# Humanize — voice profile init

Build `~/.claude/humanize/voice.md`: a profile of how **this user** actually writes, assembled only from writing they verified as their own.

## Read the contract first

Two reference docs in this skill directory are the contract. Read **both in full** before doing anything else. Do not work from this file's summaries — they are pointers, not the rules.

- `references/voice-profile-spec.md` — the output format: frontmatter, `schema_version`, the seven fixed H2 sections, provenance fields, re-run semantics.
- `references/mining-and-curation.md` — how samples may be collected: consent scope, the AI-adoption cutoff, the co-author trailer filter, Slack handling, per-candidate curation, the zero-candidate fallback, the write boundary, the closed list of verification methods.

When the two disagree with anything below, they win.

## Hard boundaries

These are not negotiable and not overridable by user request:

- **Write only inside `~/.claude/humanize/`.** `voice.md` and `voice.md.bak-<date>` are the only files this skill produces. Never a repo-tracked path, never the plugin directory, never the project `.claude/`, never the cwd. Mined text contains other people's names — a tracked copy leaks them on the next push.
- **Never hardcode a cutoff year.** The AI-adoption date comes from the user, every run.
- **Never scan an unnamed source.** No cwd default, no home-directory walk, no org-wide repo discovery.
- **Never overwrite an existing profile silently.**
- **Slack is optional.** Its absence is one line of prose, not a warning, not a setup detour.

## Flow

### 1. Check for an existing profile (verify before acting)

```bash
ls -la ~/.claude/humanize/voice.md 2>/dev/null
```

- **Absent** → this is a first run. Continue to step 2, mode = build.
- **Present** → read it and parse `schema_version` from the frontmatter, then use AskUserQuestion:
  - `schema_version: 1` → offer both **Refine existing** (keep the file, mine/interview for additions and corrections, merge into the existing sections, set `refined`, leave `generated` alone) and **Rebuild from scratch** (back up first, then full flow, fresh `generated`, drop `refined`).
  - Missing frontmatter, missing `schema_version`, or any other value → offer **Rebuild only**, and say why in one line: the existing file isn't in a shape that can be safely merged.
  - Either way include a decline option. Declining exits immediately with the file untouched — say so and stop.

Before a rebuild writes anything:

```bash
cp ~/.claude/humanize/voice.md ~/.claude/humanize/voice.md.bak-<generated-date-from-old-frontmatter>
```

Use `bak-unknown` for the suffix if the old file has no `generated` date. Do not clobber an existing `.bak-*` with the same name — append `-2`, `-3` as needed.

### 2. Ask what to mine, and ask for the cutoff

Two questions, both before touching any source. Neither has a default.

**Sources.** Ask which repos or directories to mine, named as absolute paths to clones already on this machine. Make "none — skip mining" an explicit, unpenalized choice. An empty or declined answer sends the flow straight to step 6 (interview + pasted samples). Naming a source authorizes reading it for **this run only**; refine runs re-ask. Do not clone anything, and do not offer to — a remote URL is an invitation to widen scope past what the user can see.

**Cutoff.** Ask, in the user's own frame:

> Roughly when did you start using AI assistants for writing — commits, messages, docs? I'll only auto-trust writing from before that date.

Accept a year, a month, or "never". "Never" means no date filter, but the trailer filter in step 3 still runs. Record the stated answer verbatim; provenance entries cite it.

Also confirm the git author identity to filter on so you mine the user's commits and not their teammates':

```bash
git -C "<named-repo>" config user.email
```

Ask whether they used other addresses in that repo's history; collect all of them.

### 3. Mine the named sources

**Git.** Check each named path before reading it — a typo'd path or a directory that isn't a repo should cost one line, not a stack trace:

```bash
git -C "<repo>" rev-parse --is-inside-work-tree 2>/dev/null
```

Anything that doesn't print `true` gets reported back to the user in one line and skipped. Do not go looking for the repo they probably meant.

Then, per surviving repo, per author email:

```bash
git -C "<repo>" log \
  --author="<email>" \
  --before="<cutoff>" \
  --extended-regexp \
  --regexp-ignore-case \
  --invert-grep \
  --grep='co-authored-by:.*(claude|copilot|chatgpt|gpt-|codex|cursor|gemini|devin|aider)' \
  --pretty=format:'%H%x09%aI%x09%s%n%b%n==='
```

Notes that matter:

- `--regexp-ignore-case` is what makes the trailer filter case-insensitive, as the contract requires. `--extended-regexp` is what makes the `(a|b)` alternation portable across git's regex backends. The alternation lists AI assistants only — human co-authors must survive.
- The name list is a floor, not a ceiling. If a surviving commit carries a `co-authored-by:` trailer naming any other assistant, drop it too.
- `--before` filters on **committer** date. Rebases skew that, so re-check every surviving candidate's **author** date (`%aI`, the second field) against the cutoff and discard anything on or after it.
- Omit `--before` entirely when the user answered "never".

From the surviving commits, take **body prose**, not subjects: a one-line conventional-commit subject teaches nothing about voice. Keep bodies that are at least a sentence of real explanation. Discard template boilerplate, changelog dumps, revert/merge autotext, and anything that reads as generated.

**Slack.** Check whether a Slack MCP is connected:

- **Connected** → offer it as one more source. Same consent rule: the user names the channels or DM conversations to search; nothing is scanned unprompted. Same cutoff, same contamination caution — a message written after the user's adoption date is a candidate for *attestation*, not for automatic acceptance.
- **Not connected** → say so in one line ("No Slack connection here, so I'll skip that source") and move on. Do not tell the user to install or configure anything.

If a scratch file is genuinely unavoidable while collecting candidates, it lives in the session scratchpad and is never the deliverable.

### 4. Curate — the user confirms every candidate

Nothing enters the profile the user has not read. This is the privacy gate as much as the accuracy gate.

- Show each candidate **verbatim**, with its source and date.
- Use AskUserQuestion in batches (roughly 4–8 candidates per batch) so the flow doesn't become an interrogation. Batching the display is fine; blanket "just take them all" without display is not.
- Per candidate: keep / reject / edit. Rejected candidates are discarded and written nowhere. An edited candidate is stored in its edited form, and its provenance notes the redaction.
- Track the surviving count per source — provenance needs it.

### 5. Register interview

Run this in every mode, including when mining went well. Mined samples show what the user wrote; the interview captures rules they know about themselves that no sample exposes.

Ask per register (`Slack / DM`, `Docs / long-form`, `Email`, `PR / commit`) — a couple of targeted questions each, not a form:

- Openers and sign-offs: how do they start a DM asking for a favor? How does an email end?
- Formatting habits: bullets vs prose, headers, bold, emoji, message length, one message or several.
- Tone: how blunt, how much hedging, whether they apologize for pings.
- Punctuation and casing quirks: lowercase starts, em dashes, ellipses, exclamation marks.

Then vocabulary, in one pass across registers: words and phrases they reach for, and words and phrases they refuse. Feed anything the mined samples already suggest back to them as a question ("your commits use X a lot — is that deliberate?") rather than asserting it.

Interview answers are valid profile content on their own. Their verification method is `authored live during init`.

### 6. Zero-candidate fallback

If mining was declined, produced nothing, or everything was rejected — this is a normal path, not a failure. Say so plainly, then:

- Run the step 5 interview as the primary source.
- Invite the user to paste writing they attest is their own, pre-AI or not. Pasted text is verified by attestation: `user pasted and attested authorship`.
- Register sections that still have no samples get the exact fallback line from `references/voice-profile-spec.md`. Sections are never omitted.

Init never fails for lack of mined data.

### 7. Write the profile

```bash
mkdir -p ~/.claude/humanize
```

Write `~/.claude/humanize/voice.md` **to the spec** — re-read `references/voice-profile-spec.md` before composing rather than working from memory. Non-negotiables from it:

- Frontmatter with `schema_version: 1` (bare integer) and a `generated` ISO date. `refined` only on a refine pass, and a refine pass leaves `generated` untouched.
- All seven H2 sections, exact heading text, exact order, none added.
- Traits ordered most load-bearing first; quote a verified sample wherever one exists.
- A `## Provenance` bullet per contributing source with all five fields, and a verification method drawn from the contract's closed list. Every quote anywhere in the file traces to one of those bullets. The cutoff date the user stated in step 2 appears in the verification method of git-mined entries.

On refine: merge into the existing sections — add new traits, correct wrong ones, extend provenance with the new sources and counts. Don't drop content the user didn't contradict.

Then verify the write:

```bash
head -5 ~/.claude/humanize/voice.md
grep -c '^## ' ~/.claude/humanize/voice.md   # expect 7
```

If either check fails, fix the file before reporting success.

### 8. Close with the verification line

End with a short block, not a summary essay:

- The exact path written: `~/.claude/humanize/voice.md`
- What went in: counts by source (e.g. "9 commit samples from 2 repos, 4 pasted, plus interview answers across all four registers")
- The backup path, if a rebuild made one
- The next action, verbatim: **try the humanize skill on a real draft — if it still doesn't sound like you, re-run `/humanize-init` and pick "Refine existing".**

## Failure modes to avoid

- Accepting "mine everything" as an answer to step 2. It isn't a source list.
- Filtering trailers case-sensitively, or on the trailer key alone (that drops human co-authors).
- Treating a post-cutoff sample as clean because it has no trailer. The cutoff and the trailer are independent filters; both apply.
- Showing candidates as a count instead of as text. The user must see the words.
- Writing a draft, a candidate list, or scratch notes into the repo you just mined.
- Letting a missing Slack connection turn into a setup errand.
- Padding thin evidence with invented traits. A short honest profile beats a long guessed one.
