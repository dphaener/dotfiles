---
name: humanize
description: The user's voice engine — the go-to skill any time the output is words a human will read from the user. Use it for two kinds of requests — (1) writing on the user's behalf — drafting or replying to Slack messages, DMs, and channel announcements, emails to customers or teammates, commit messages, PR descriptions, release notes, status updates, and doc prose (a bare "draft...", "reply...", or "write..." counts; no mention of voice needed); (2) fixing text that reads as AI-written — the user says "humanize", "de-AI", "make it sound like me / a real person / not ChatGPT", or complains that a draft (theirs, Claude's, wherever it lives) would be "clocked" as AI. It rewrites or drafts in the user's actual voice, learned from their real messages, and strips LLM tells. Do not use it to copy a different named writer's style, summarize, make grammar/typo-only edits, cut text to a length limit, or reword machine-facing strings like API errors and logs.
user-invocable: true
---

# Humanize

Rewrite text so a reader would never guess an AI drafted it. Two halves to the job: remove the tells, then add the person. Most "humanizers" only do the first half and produce text that's merely bland instead of robotic. The output should sound like a specific person typed it in one pass.

## Workflow

1. **Write the two-sentence core first.** Before any rewrite, state what the user is trying to say in two plain
   sentences. Sentence one is the answer or the concession. Sentence two is the consequence or the ask. If it will not
   fit in two, the point is not clear yet; find it before going on. The core opens the draft and the rest follows it;
   in Slack / DM / chat and review comments, keep what follows short. A voice profile can make the core the whole
   message (step 4). `references/two-sentence-core.md` holds the reference pair: a 947-character
   Slack reply that passed every other check and was still rejected, next to the 290-character core that replaced it.
   When the calling skill lists required parts, the core is the opening and the required parts follow; keep fixed spans
   verbatim. Fixed spans are template headings, dictated phrases like `Feedback?`, keys and code.
2. **Identify the register.** Where is this text going? Four fixed buckets — Slack / DM / chat (including short channel announcements; an announcement running past a few paragraphs is doc / long-form territory), doc / long-form (design docs, wikis, READMEs, release notes), email, and PR description / commit body. Which stylistic rules apply to which register is per-user data, not something this file decides — that comes from the voice profile in step 4. A PR description in a repo with `.github/pull_request_template.md` follows that template: its headings and checklists stay verbatim, the prose goes under them, and its HTML guidance comments are followed and then removed. Without a template, keep the shape the input already has.
3. **Read `references/ai-tells.md`** and hunt the input for every tell listed there. These are the patterns that make readers think "an AI wrote this."
4. **Check for a voice profile at `~/.claude/humanize/voice.md`.**
   - **Present and `schema_version: 1`** (the only version this skill recognizes — full contract at `../humanize-init/references/voice-profile-spec.md`) → read it and apply the traits and register rules it contains, scaled to the register from step 2.
   - **If the profile's `## Voice traits` includes a trait named "Two sentences carry the point"**, the core from step
     1, plus any required parts, is the whole message in every register that is a reply to a person (chat, Slack, DM,
     review comment, and a short email). Do not append the fuller draft, do not offer it, and do not add a closer. The
     trait's own approved sample is the shape to match. Without that trait, the step 1 default holds: the core opens and
     the body follows it.
   - **Absent, or present with a missing/unrecognized `schema_version`** → apply `ai-tells.md` only. Never guess at or partially apply a profile you can't parse. After the rewrite, append a one-line nudge: run `/humanize-init` to build a personal voice profile.
5. **Output the rewrite.** Just the rewritten text — no preamble, no "Here's the humanized version:". If a change loses information the user might care about, flag it in one line *after* the rewrite (and after the init nudge, if both apply). When the output is the two-sentence core and the input carried facts the core dropped, that one line is where they are named, so the user can ask for them.

## Principles

**Preserve every fact.** Humanizing is a style transform, not a summary. Names, numbers, links, ticket IDs, version numbers survive intact. If the input says "shipped in v3.9.1 (PR #2214)", the output says that too.

**Vary the rhythm.** AI text has metronomic sentence length and paragraph shape. Humans write a long winding sentence and then a short one. Like that. Break parallel structures on purpose — if three bullets all start with a bolded gerund, rewrite one as a plain sentence.

**Imperfection is the point — but don't cosplay sloppiness.** A stray "honestly" or a sentence that just trails off is authentic. Deliberately inserted typos or forced slang read as fake in the other direction. When in doubt, aim for "competent person typing quickly," not "trying to seem relaxed."

**Cut before you decorate.** The fastest way to sound human is to say less. AI padding ("It's important to note that", "In today's fast-paced environment") gets deleted, not rephrased.

**Don't over-apply the voice.** The voice profile is a palette, not a checklist. A rewrite that uses every trait it can find (say, a stock catchphrase, a habitual stretched-out word, a pet interjection, and a habit of trailing off mid-sentence, all in one short message) reads as parody. One or two touches per message is usually right; zero is fine for formal registers.

**Kill the cadence, not just the vocabulary.** Text can pass every word-level check and still read as AI because every sentence lands a rhetorical beat — a neat antithesis, a punchy aphorism, a mic-drop closer ("This is foundational. If we're serious, we invest here first."). Humans let most sentences just carry information without shaping them for applause. After rewriting, reread and defuse a couple of the punchiest sentences into plain statements — a trailing "probably" or a workmanlike clause does more to humanize than any word swap.

**Don't swap one costume for another.** Replacing a corporate phrase with a faux-casual one ("Flag it if something seems off", "no worries at all") is still putting on a voice — just a different fake one. The person being imitated may genuinely use polite full sentences. When removing a tell, reach for what *they* would actually write — check the voice profile's real samples in `~/.claude/humanize/voice.md` — not for generic "casual".

## Examples

**Input (Slack):**
> Hi team, just wanted to circle back and let everyone know that the deploy has been completed successfully. All services are reporting healthy, and I have confirmed that the error rates are back to baseline. Please let me know if you have any questions or concerns!

**Output:**
> Deploy's out. Everything's reporting healthy and error rates are back to baseline. Ping me if anything looks off.

**Input (doc):**
> This design offers a number of significant benefits. Not only does it reduce the operational burden on the team, it also improves the overall reliability of the system. It's not just about saving time — it's about building something we can trust going forward.

**Output:**
> This design cuts the team's operational load and makes the system more reliable. Mainly it means we can stop babysitting it.
