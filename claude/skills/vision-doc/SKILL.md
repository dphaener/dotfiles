---
name: vision-doc
description: Draft an engineering or product vision doc — interview-driven, Notion-first, evidence-backed, Smart Brevity throughout. Triggers on /vision-doc or natural-language equivalents ("help me write a vision doc", "engineering vision"). Iterates section-by-section with the author; self-calibrating.
---

# Vision Doc Skill

The author wants to write a vision doc. Help them produce one that's **opinionated, evidence-backed, short enough to read, and grounded in actual pain.**

A vision doc is **WHAT and WHY**, not HOW. Implementation details belong in a TRD or RFC. If a sentence reads like it could appear in either, it goes in the TRD.

Per Will Larson: a vision is the 2-year forecast of five strategies pulled together. Be **opinionated**, show rationale, be **ambitious but not audacious**. The real success measure is: pull up a design doc from before and one from after — is there marked improvement?

The skill is **calibrated** — see `## Calibration` at the bottom for the author's defaults (audience, voice, what good looks like). Re-read every run and apply.

> **Configure:** fill in the author's default audience mix in step 4 and in `## Calibration`, and the Jira project keys to search in step 2 (`<PROJ-A>`, `<PROJ-B>`, …). Everything else adapts through the Calibration log.

---

## Usage

```
/vision-doc                        — start a new vision doc; ask for topic + Notion page
/vision-doc <notion-url>           — work on an existing (possibly blank) Notion page
/vision-doc <topic>                — search Notion for a matching page; create if none
```

---

## Steps

### 1. Topic + page resolution

- Ask: *"What's the vision doc about? Paste the Notion URL if there's an existing page, or give me the topic and I'll search."*
- If URL given → fetch it via `notion-fetch`. May be blank, partial, or substantial; all are valid starting states.
- If topic given → `notion-search` for matching pages; show candidates; if none, ask if the author wants a new page created.
- Identify the page's location in the workspace (parent path) — this hints at audience and surrounding context.

### 2. Pre-interview research (broad)

Run these searches in parallel via tool calls. Goal: bring back enough context to ground the interview and the drafting.

- **Notion semantic search** on the topic + adjacent terms. Pull related pillars docs, TRDs, journey maps, RFCs.
- **Slack search** for the topic; identify the most-relevant channel(s); read the latest 10–20 messages there if it's an active thread.
- **Jira search** across likely projects (`<PROJ-A>`, `<PROJ-B>`, `<PROJ-C>`, …, depending on topic) for tickets that anchor the pain.
- If the page has ancestors / parent docs → fetch them; the parent doc often defines the surrounding vocabulary.

**Heavy research → use a subagent** (`general-purpose`) to keep raw findings out of main context. The subagent returns a tight summary (under 400 words) with links.

### 3. Findings summary to user

Post a tight pre-interview summary:

> Found N related Notion docs (top 3 linked), M Jira tickets in [projects], the relevant Slack channel is `#X`. Key context: [3 bullets].
>
> Anything else I should read before we start?

Lets the author correct/redirect the framing before we draft. Take any pushback seriously — research framing wrong = doc framing wrong.

### 4. Interview — first round

Ask **one batched `AskUserQuestion` call** with these four, in this order:

1. **Audience** (multi-select). **Default pre-filled: the author's standard mix from `## Calibration`** (e.g. own team, Leadership, Peer teams). Offer this as the first option labeled `Use my default (<default audience mix>)`; second option labeled `Different mix for this doc — I'll specify`. If the author picks "different mix," follow up with the specific audiences.

2. **Goal** — what's the single decision or shift this doc unlocks?
   - Options: get a commitment landed / align peers on the seam / establish the worldview / build the foundation for execution / something else.

3. **Scope** — what's IN, what's OUT? Tight phrasing matters; scope blur is the #1 vision-doc failure mode.
   - Open-ended OR multi-select depending on context.

4. **Tension** — what's the controversial position the doc takes, or is it clarity-driven (no controversy, just unclear direction)?
   - Options: not urgent enough / scope blur with peer team / cost or ML complexity / abstract not grounded / not controversial — clarity-driven.

After Round 1, **let the rest emerge.** Don't force a fixed second round. Based on the author's answers, ask follow-ups like:
- Picture of good (multi-select frames — impl team / customers / engineers / coverage)
- Use cases (multi-select pain points)
- Phase 1 intuition (what earns the right to build the rest?)
- Structure preference (template / propose / I'll describe)

Stay tight: each round ≤ 4 questions. Multi-select where the user is likely to want multiple. Always offer `Something else — I'll describe` as the last option for open-ended answers.

### 5. Propose structure

Based on interview answers, **propose** a section list. Don't impose a template.

The **common pattern that often fits** (and is a strong default unless interview suggests otherwise):

```
1. Executive summary       — axiom up top, 3-bullet "what changes"
2. Where it hurts today    — evidence-backed pain points (each cites Jira/Notion/Slack)
3. What good looks like    — aspirational pictures (eng, customer, coverage)
4. The conceptual model    — vocabulary + invariants
5. Phasing                 — foundation first; applications value-ranked
6. What we're NOT doing    — negative space (load-bearing!)
7. Open questions          — honest uncertainty
```

But: if the doc's goal is "establish the worldview," lead with the conceptual model. If it's "get commitment landed," lead with the ask. Structure should serve the goal.

Show the proposed structure to the author. Wait for confirmation or tweaks. Don't over-iterate here — the author tunes structure as they read sections.

### 6. Evidence pass BEFORE drafting

For every pain point / current-state / dependency claim that will land in the doc: **research first, write second.** Don't write a claim and hope it's true.

Concretely:
- For each pain bullet → identify the specific Jira ticket(s), Notion doc(s), or Slack thread(s) that anchor it.
- If you can't find evidence → either drop the claim, soften it ("anecdotally"), or surface to the author as an open question.
- Aspirational claims ("what good looks like") don't need cites — they're vision, not current-state assertions.

This step is what makes the doc credible. The author's typical pushback when this fails: *"robot, go confirm that before claiming."* The skill should not put them in that position again.

### 7. Draft v0.1 to Notion

Push the full doc to the target Notion page. Smart Brevity throughout (see `## Smart Brevity rules` below).

- Use `notion-update-page` with `command: "insert_content"` if the page is blank.
- Use `notion-update-page` with `command: "replace_content"` if the page has content to overwrite.
- Set `Last updated: <today>` in the header (use a `<mention-date>` mention).
- Status header: `**Status**: WIP`.
- Author: the user running the skill.

### 8. Section-by-section iteration (default)

The author reviews the doc and leaves Notion comments + manual edits, **one section at a time.**

Each turn:
1. **Re-fetch the doc** with `include_discussions: true` to see new comments.
2. **Identify the author's manual edits** — diff against your last push. Note them; **never silently revert**.
3. **Address open comments** in the section they just reviewed:
   - For evidence-check comments ("robot, go confirm that before claiming") → research first, then update the claim with citations.
   - For clarity comments ("robot, I don't understand this") → rewrite for clarity.
   - For TRD-alignment comments ("does this align with X's TRD?") → fetch the TRD, cite verbatim, add inline reference.
4. **Decide if other sections need ripple updates** — but **don't pre-emptively touch sections the author hasn't reviewed yet.** Flag the ripple in chat; let them drive when to address it.
5. **Push v0.x** via `replace_content` (big rewrites) or `update_content` (small targeted edits).
6. **Verify the push landed** by re-fetching. `update_content` silently fails when the `old_str` includes discussion-url spans that have changed since the last fetch — see `## Notion mechanics`.

If the author says *"address all comments at once"* or *"red-pen the whole thing"* — switch to whole-doc mode for that round.

### 9. Done signal

The author flips `**Status**: WIP` → `**Status**: Final`. That's the only done signal.

When you see the flip:
- Bump `Last updated`.
- Stop iterating unless they reopen.
- Run Step 10.

### 10. Update calibration (the learning loop)

Before ending the run, scan the conversation for new guidance from the author that wasn't already captured in `## Calibration`:
- New framing they pushed back on (e.g. "vision-level not implementation detail")
- New section patterns they liked / didn't
- New audience defaults
- New evidence-rigor expectations
- Any Notion mechanics gotchas surfaced

If anything new came up, **append** a dated entry to the `## Calibration` section at the bottom of this SKILL.md using the Edit tool. Append-only — don't rewrite or reorganize prior entries. Show the author what you added in a one-line confirmation. If the section grows unwieldy, ask the author whether to consolidate; don't do it unilaterally.

If nothing new came up, say so and skip.

---

## Smart Brevity rules

Built-in, not a separate skill call. Apply throughout drafting and iteration.

- **Claim-first.** Every paragraph leads with the punch. No throat-clearing ("It's worth noting that…", "In order to…").
- **Bullets > paragraphs.** When listing facts, use bullets. One claim per bullet.
- **Bold first words** for skimmable headers within paragraphs ("**Manual review.** The team relies on humans…").
- **Citations as inline parentheticals**, not footnotes. `([<PROJ>-123](url), [<PROJ>-456](url))` next to the claim, not at the bottom.
- **Cut hedges** in vision claims (be opinionated). **Keep hedges** in user-edited prose (preserve voice).
- **One axiom per doc.** The executive summary opens with a single sentence that names the worldview shift. ("Documents are a graph, not a list.") Earn the rest from there.
- **No length enforcement.** Length is flexible; the doc ends when the author flips status to Final.
- **Preserve user voice.** The author's manual edits, hedges ("(mostly)"), parentheticals, intentional shorthand ("thou" for "though") — never silently revert. If it looks like a typo, ask before fixing.

---

## What goes in a vision doc — and what doesn't

| In | Out |
|---|---|
| What changes (the future state) | How we'll build it (architecture details, schemas, APIs) |
| Why it matters (the pain, the cost) | Implementation mechanics (config vs code, schema migrations) |
| Conceptual model + invariants | Sequence diagrams, ER diagrams, code structure |
| Phasing (foundation → applications, value-ranked) | Sprint plans, ticket lists, dependency graphs |
| Use cases that ground the value | Test plans, eval suites |
| Open questions | Open Jira tickets |
| What we explicitly won't do | What's blocked on whom |

If a sentence reads like it could appear in a TRD, it doesn't belong in the vision. Example of an author cutting this pattern: *"link-type names are free-form data, not an enum — this is implementation detail, I don't think it's important for the vision doc."*

---

## Notion mechanics

### Tool selection

- **`notion-update-page` with `command: "replace_content"`** — for big section overhauls, full-doc rewrites, anything spanning multiple paragraphs. **Reliable.** Use this when in doubt.
- **`notion-update-page` with `command: "update_content"`** — for small targeted edits (adding one bullet, fixing one sentence, filling a placeholder). Faster, smaller payload.
- **`notion-update-page` with `command: "insert_content"`** — for appending to a blank page on v0.1.

### The discussion-url gotcha

When the author leaves an inline comment on a phrase, Notion wraps that phrase in `<span discussion-urls="discussion://...">...</span>` markup in the page content. This **silently breaks `update_content`** if the `old_str` you're matching includes the wrapped phrase but you don't include the markup.

Symptom: `update_content` returns success (`{"page_id": "..."}`) but the change didn't actually land.

Defense:
1. After every `update_content` call, **re-fetch the page** and verify the change is present.
2. If a change involves text that has an open comment on it, **use `replace_content` for that section** instead.
3. If you must use `update_content` on commented text, include the full `<span discussion-urls="...">...</span>` wrapper in `old_str`.

### Last updated

Bump `<mention-date start="YYYY-MM-DD"/>` on substantive change pushes. Skip for tiny tweaks.

### Orphaned comments

Big rewrites (`replace_content` of a whole section) will orphan the author's inline comments — the anchor text disappears, so the comments float in the page discussion list unattached. **This is fine.** Address the substance in the rewrite; the author resolves the orphaned comments when satisfied.

If you want to be courteous, leave a brief reply on each orphaned comment via `notion-create-comment` with a one-line evidence trail before pushing the rewrite. Optional — only do this when comments raised non-trivial questions.

---

## Calibration

Append-only log of what the author pays attention to. Each entry is dated and self-contained. Read all entries top-to-bottom each run and apply. Don't rewrite or reorganize prior entries. If more than one person runs the skill, label author-specific entries and keep each author's defaults separate.

### 2026-05-21 — initial seed (first vision doc)

**Author's default audience for vision docs:**
- Own team (internal)
- Leadership
- Peer teams

Engineering-first voice. Leadership / peer-team adaptation deferred to derivative artifacts (one-pager, deck) unless the author asks otherwise.

**Evidence discipline the author explicitly requires:**
- Every current-state claim must be backed by a Jira ticket, Notion doc, or Slack thread before it lands in the doc.
- The author's phrasing when this fails: *"robot, go confirm that before claiming."* — treat as a hard rule, not a suggestion.
- Aspirational / vision claims don't need cites.

**Vision vs. implementation discipline:**
- The author cut "link-type names are free-form data, not an enum" because it's HOW not WHAT.
- If a sentence reads like it belongs in a TRD, it doesn't belong in the vision.

**Structure patterns the author has used:**
- 7-section default (Exec / Pain / What good / Model / Phasing / Not doing / Open questions) — landed well on the first doc.
- Drops a "Five shapes, one root cause" style intro lead-in on second pass — section punches harder without it.
- Per-pain-point format: bold header line + 2–4 short bullets, one fact per bullet, citations inline.
- Phasing as "Foundation (mandatory) → Applications (value-ranked, parallelizable)" — not strict sequential P1/P2/P3.

**Voice / style preferences:**
- Preserve the author's hedges: "(mostly)", "(they can contribute to it thou)", parentheticals, ":D".
- Don't fix typos in the author's edits silently. Flag if you're unsure whether it's intentional.
- Never silently revert manual edits (e.g. a team nickname the author replaced with a plain description stays replaced).
- Tables OK for simple data grids; not for narrative content.

**Notion gotchas surfaced:**
- `update_content` silently fails when `old_str` overlaps discussion-url spans without including them. Always re-fetch and verify after `update_content`.
- Use `replace_content` for big section rewrites — reliable; comments orphan, which is fine.

**Iteration model:**
- Default: section-by-section. The author reviews + comments + manually edits one section at a time. Skill addresses, pushes v0.x, waits for next.
- The author can switch to whole-doc red-pen if they say so.
- Don't pre-emptively touch sections downstream of where the author is reviewing, even if comments ripple. Flag the ripple in chat.

**What the author cares about beyond the doc itself:**
- The doc is the foundation for a year of execution. Epics, milestones, evals all trace back. Get the worldview right; execution flows.
- The doc serves three audiences but speaks engineering-first. Don't try to please all three in one pass — write for engineering; adapt for leadership/peers in derivative artifacts.

### 2026-07-02 — second author's run (product-area vision) — author-specific unless noted

**User context:** this run's author was a different person from the seed entry. Keep the seed author's defaults for them; apply these when this author runs the skill.

**This author's defaults:**
- Audience: Leadership + peer eng teams + own team. Goal: foundation for execution. Tension: clarity-driven.
- Research can come from a prior conversation — when a research session precedes /vision-doc, treat it as the pre-interview pass and skip re-research; jump to page resolution + interview.
- Keep a repo-side decision doc (docs/*.md in the project repo) in sync with the Notion vision doc when both exist. Implementation candidates (specific frameworks or libraries) may be named in the repo doc but NOT in the vision doc.

**Language/content rules from this author's comments (likely generalize):**
- Expand acronyms on first use, even common ones (SME) — leadership readers won't know them.
- Never name competitors as first-class citizens. Frame around your company's own products; a competitor may be mentioned only as prospect-context, and prefer not at all.
- Don't let internal taxonomy jargon leak into the doc ("Archetype B") — define or drop.
- Soften prescriptive/absolutist language ("that's a platform bug" → "a missing platform capability to build").
- Plain-English over eng/security jargon ("fail-closed account scoping" → "strict per-customer access controls (…)").

**Style: the [Vision] house format (from the seed author's docs; this author explicitly asked to match it):**
- Title `[Vision] <Topic>`, 🔭 icon.
- Header block: `**Author**: @mention <br>**Status**: …<br>**Last updated**: date-mention`.
- Unnumbered H2 sections separated by `---` dividers (no numbered H1s; cross-reference by section name, not number).
- "Where it hurts today": bold pain-point mini-headers, 1–4 one-fact bullets each with inline citations, closing `**Common pattern:**` line naming the root cause.
- "What good looks like" opens with a cadence line ("Three things are true once this lands.").
- "What we are explicitly not doing" as bold-term paragraphs, not bullets.
- Politically sensitive seam/relationship paragraphs go in a callout (e.g. 🤝 blue_bg).
- End with `## References` then a collapsed `## Revision History {toggle="true"}` with dated toggle entries per version.

**Placement:** a vision doc may live in its product's discovery/incubation hub rather than under a central technical-vision-docs page when that context fits — confirmed correct for this run (child of the product's hub page).

### 2026-07-21 — second author's run (org-wide agentic workflows vision) — author-specific unless noted

**Placement:** org-wide engineering vision docs go under the org's AI/platform hub page in the engineering wiki tree, alongside related playbooks. Record the hub page link here once known.

**People/context lookups:** a colleague's name may be spelled differently in chat than in Notion, and may not be findable in Slack search. Verify name spellings against Notion before searching.

**Evidence rules (likely generalize):**
- Never cite Slack DMs in an org-wide doc — readers can't open them. Find the equivalent claim in a public channel or drop the cite.
- Open questions may go uncited when the source is an unlinkable event (e.g. "unresolved at the offsite") — phrase as a question, not a claim.

**Contested-seam workflow (likely generalizes):** when the author pushes back on a peer's design during the interview ("let's talk about this in depth before deciding"), pause the interview, deep-dive the competing docs' MECHANICS (where it runs, auth model, stated rationale, what each doc is silent on), and present them side-by-side — including where the author's objection does NOT land ("your objection misses X, but a stronger version holds"). The author values being corrected with evidence. The synthesis that landed: name the layer each competing design got right (library = seam, session-scoped tokens = credential model, CLI/in-process/programmatic = adapters) so no author's work is overruled, then put it in the 🤝 callout.

**Content positions this author holds (this doc's worldview — reuse in related docs):**
- Tools taxonomy: harness primitives / shared capability tools / domain-service tools; a shared versioned Python library is the seam for the latter two.
- "Tools" includes programmatic primitives (Read/Write-style), not just service access.
- Few general agents; new capability = skill or tool, not a new agent. Skills are SME-authored content with an eval-gated loop.
- Framework choice (OpenAI Agents SDK vs Claude Agent SDK) deliberately left as an Open Question, not a stance.
- Precision on convergence claims: the drafting STEP converges across products; retrieval and preparation stay bespoke deterministic code per product. Don't overstate to whole-architecture convergence.

**Tone:** don't overstate current dysfunction — "we ship agents today the way we shipped ML services before the platform" was flagged heavy-handed with only two agents shipping. Frame as "reasonable at two, won't scale to ten."

**Comment shorthand:** a bare "What does this mean?" on a term = jargon violation; replace with plain English rather than defining the acronym inline.

**Process notes:** interview answers can arrive partially (user rejects the AskUserQuestion call to clarify one item, answers others) — bank the answered ones, discuss the contested one, then re-ask the remainder. Ripple edits to un-commented sections: propose in chat, apply only on explicit yes (worked well twice this run).
