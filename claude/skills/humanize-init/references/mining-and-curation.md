# Mining and Curation Rules

**Contract for how the `humanize-init` skill collects voice samples.** The point of mining is to find writing that is provably the user's own — not AI-drafted, not co-written, not someone else's. A profile built from contaminated samples teaches the humanize skill to imitate an AI imitating the user. These rules are therefore non-negotiable.

All examples below are invented placeholders (fictional user "Jordan", fictional repos).

## 1. Scope: explicit consent, always

- Mining runs ONLY against repos and sources the user **explicitly names when asked**. The humanize-init skill asks: "Which repos or sources should I mine for your writing?" and touches nothing until the user answers.
- NEVER default to the current working directory. NEVER scan the filesystem, home directory, or org repos unprompted. An empty or declined answer means: skip mining, go straight to the interview flow (section 7).
- Naming a source authorizes reading it for this init run only. Re-runs re-ask.

## 2. The AI-adoption cutoff: ask, never assume

Before mining any source, ask the user:

> "Roughly when did you start using AI assistants for writing (commits, messages, docs)? I'll only trust writing from before that date as ground truth."

- The answer is the user's **personal recency cutoff**. Samples dated on or after it are presumed contaminated and excluded from automatic acceptance (they may still enter via user-pasted attestation, section 6).
- NEVER hardcode a year or default to any date. Adoption dates vary per person by years; one user's boundary is meaningless for another.
- If the user says "never" or "I don't use AI for writing", there is no cutoff — but the trailer filter (section 3) still applies.
- Record the stated date; provenance entries cite it as part of their verification method.

## 3. Git mining: the co-author trailer filter

When mining git history from a named repo:

- EXCLUDE any commit whose message contains a `co-authored-by:` trailer naming an AI assistant, matched **case-insensitively** — `Co-Authored-By: Claude`, `co-authored-by: claude`, `CO-AUTHORED-BY: Claude Fable <...>` are all excluded. Match on the trailer key plus an AI-assistant name in the value; do not exclude human co-authors.
- EXCLUDE commits authored on or after the user's stated cutoff (section 2), even without a trailer — trailers are sufficient but not necessary evidence of AI drafting.
- Filter by the user's own authorship (git author email) so you don't mine teammates' voices.
- Example of a surviving candidate (invented): a 2020 commit body reading "Bumps the parser to handle windows line endings. Took forever to track down." — pre-cutoff, no trailer, user-authored.

## 4. Slack mining: optional, gracefully absent

- If a Slack MCP connection is available, OFFER Slack message mining as one more source — subject to the same explicit-consent rule (the user names channels/DMs to search; nothing is scanned unprompted) and the same cutoff.
- If no Slack MCP is connected, say so in one line and move on. Slack is never required, never blocks init, and its absence never produces an error, a setup detour, or a degraded-sounding warning. The flow is identical minus one source.
- Do not instruct the user to install or configure Slack integrations.

## 5. Curation: every candidate is confirmed by the user

- Every mined candidate sample is **shown to the user verbatim** with its source and date, and the user confirms or rejects it before it can appear in the profile. Batch display is fine; blanket acceptance ("just take them all" without seeing them) is not — the user must have seen what they're approving.
- Rejected candidates are discarded and never written anywhere.
- The user may also edit a candidate (e.g., redact a name); the edited form is what gets stored, and provenance notes it was redacted.
- Confirmation is also the privacy gate: mined text often contains other people's names and internal details. Nothing enters the profile without the user having eyeballed it.

## 6. Zero-candidate fallback

If mining produces zero candidates that survive curation (nothing mined, everything rejected, or all sources declined):

- Degrade to **interview + user-pasted samples**: ask register-by-register questions ("How do you open a DM asking for a favor?") and invite the user to paste writing they attest is their own, pre-AI or not.
- User-pasted samples are verified by attestation; provenance records `verified human: user pasted and attested authorship`.
- A profile built purely from interview answers is valid. Register sections without samples carry the fallback line defined in `voice-profile-spec.md`. Init never fails for lack of mined data.

## 7. Where mined content may be written

- Mined and curated content is written ONLY to `~/.claude/humanize/voice.md` (plus the `.bak-*` rebuild copies defined in `voice-profile-spec.md`, also inside `~/.claude/humanize/`).
- NEVER write samples, candidate lists, scratch notes, or profile drafts to any repo-tracked path, the current working directory, plugin directories, or anywhere else. If a temp file is unavoidable during mining, it lives in the session scratchpad and is not the deliverable.
- Rationale: voice profiles contain private messages and colleagues' names. A repo-tracked copy leaks them on the next push.

## 8. Verification methods (the closed list provenance may cite)

| Method | When it applies |
|---|---|
| predates stated AI-adoption cutoff + no AI co-author trailer | git-mined commits |
| user pasted and attested authorship | pasted samples, any date |
| authored live during init | interview answers |
| user confirmed authorship of mined message | Slack/chat candidates the user approved |

Any sample whose verification doesn't fit one of these rows doesn't go in the profile.
