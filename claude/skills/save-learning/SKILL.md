---
name: save-learning
description: "Capture new knowledge using the CEQRC workflow (Capture, Explain, Question, Refine, Connect). Use when the user wants to save a learning, insight, or discovery to the personal knowledge graph at ~/knowledge/."
---

# save-learning Skill — CEQRC Workflow

This skill captures and persists a knowledge entry to the personal knowledge graph at
`~/knowledge/`. It supports two modes: **Full CEQRC** (default) and **Quick mode**
(when rich metadata is provided inline).

---

## Canonical Prefix-to-Directory Mapping

Use this table to resolve entry types to file paths. Do not read SCHEMA.md at runtime.

| Type | ID Prefix | Directory |
|------|-----------|-----------|
| `architecture` | `arch-` | `architecture/` |
| `debugging` | `debug-` | `debugging/` |
| `process` | `process-` | `process/` |
| `people` | `people-` | `people/` |
| `domain` | `domain-` | `domain/` |
| `reference` | `ref-` | `reference/` |
| `insight` | `insight-` | `insight/` |

## File Naming Convention

- Entries live at: `~/knowledge/<directory>/<slug>.md`
- The filename is the **slug only** — the portion of the ID after the prefix.
- Example: ID `arch-webapp-module-boundaries` → file `~/knowledge/architecture/webapp-module-boundaries.md`
- The full ID appears only in the frontmatter `id` field.

---

## Mode Detection

**Quick mode** is triggered when the user's invocation includes BOTH `type:` and `tags:`
inline metadata. Example:

```
/save-learning type:architecture tags:modularity,webapp "The webapp enforces module boundaries"
```

Parse the following from the argument string:
- `type:<value>` — the entry type (must match one of the 7 types above)
- `tags:<comma-separated-values>` — tags list
- The remaining text (after stripping `type:` and `tags:` tokens) is the raw learning

If `type:` or `tags:` is absent, default to **Full CEQRC mode**.

---

## Full CEQRC Mode

### Phase 1 — Capture

If the skill was invoked with an argument (e.g., `/save-learning "The webapp enforces module boundaries..."`),
use that text as the raw capture. Strip any parsed `type:` or `tags:` tokens before using.

If no argument was provided, use `AskUserQuestion`:

```
What did you learn? (describe the insight, observation, or discovery in your own words)
```

Store the response as `raw_capture`.

---

### Phase 2 — Explain (classify type)

Auto-suggest a type based on keywords in `raw_capture`:

| Keywords in raw_capture | Suggested type |
|-------------------------|----------------|
| "design", "service", "boundary", "ADR", "trade-off", "module", "architecture", "packwerk", "api contract" | `architecture` |
| "error", "bug", "nil", "exception", "crash", "root cause", "fix", "gotcha", "stacktrace" | `debugging` |
| "deploy", "workflow", "convention", "runbook", "release", "process", "step", "checklist" | `process` |
| "owns", "team", "contact", "responsibility", "who", "people", "oncall" | `people` |
| "business", "concept", "product", "term", "definition", "lifecycle", "domain" | `domain` |
| "config", "credentials", "api key", "external", "tool", "location", "reference" | `reference` |
| "pattern", "lesson", "observation", "cross-cutting", "insight", "tends to", "always" | `insight` |

If multiple types match, pick the strongest signal. If none match, suggest `insight` as
a safe default.

Use `AskUserQuestion` to present the suggestion:

```
What type of knowledge is this?

Suggested: <suggested_type> (based on keywords in your input)

Options:
1. architecture — System design, ADRs, trade-offs, service boundaries
2. debugging — Root causes, fixes, gotchas, error patterns
3. process — Deploys, workflows, team conventions, runbooks
4. people — Ownership, responsibilities, contacts, team structure
5. domain — Business concepts, product logic, terminology
6. reference — External tool configs, API details, credentials locations
7. insight — Cross-cutting observations, patterns, lessons learned
```

Store the selected type as `entry_type`.

---

### Phase 3 — Question

Ask 1-2 clarifying questions to deepen the entry. Tailor the questions based on `entry_type`.

**Per-type clarifying questions:**

- `architecture`: "What was the design decision or trade-off here?" / "What system or service boundary does this describe?"
- `debugging`: "What was the root cause?" / "What symptom led you to discover this?"
- `process`: "What trigger or condition does this process apply to?" / "Are there known gotchas in this workflow?"
- `people`: "Who owns this and for which service or domain?" / "What context prompted you to note this?"
- `domain`: "Where in the product does this concept apply?" / "What was confusing or non-obvious about this term?"
- `reference`: "Where is this config or credential located?" / "What project or tool does this apply to?"
- `insight`: "What patterns or situations triggered this observation?" / "How confident are you — is this well-confirmed or still a hypothesis?"

Select the 1-2 most relevant questions for the capture. Provide 2-3 suggested answers for each
using `AskUserQuestion`, plus a free-text option ("Other — I'll type my own").

Store the responses as `clarifications`.

---

### Phase 4 — Refine

Draft the full entry. Present it to the user for review. **This step is mandatory — never
auto-approve.**

**Construct the draft:**

1. **Generate a title**: A concise, descriptive title (≤ 10 words) summarizing the learning.
2. **Generate a slug**: lowercase, hyphen-separated words from the title that are unique and descriptive. Strip common filler words (a, the, in, of, for). Example: "The webapp enforces module boundaries" → `webapp-enforces-module-boundaries`.
3. **Generate the entry ID**: `<prefix><slug>` using the prefix from the mapping table. Example: `arch-webapp-enforces-module-boundaries`.
4. **Determine project**: Infer from tags and raw capture text. Default to `general` if unclear.
5. **Determine confidence**: Default to `medium` unless the user's words suggest certainty ("confirmed", "verified", "documented") → `high`, or uncertainty ("think", "maybe", "not sure") → `low`.
6. **Build the tags array**: Include any tags from Quick mode input, plus 2-4 inferred from the content (lowercase, hyphenated).
7. **Compose the body** using this structure:

```markdown
## Context

<When and where this applies — what system, service, or situation>

## Key Insight

<The core learning in 1-3 sentences>

## Evidence

<What confirmed this: observation, error message, code review, doc, experiment>

## Caveats

<Limitations, edge cases, or conditions where this may not apply>
```

**Present the full draft as a fenced markdown block**, then use `AskUserQuestion`:

```
Does this look right?

1. Approve — save it as-is
2. Edit — I'll describe changes and you'll regenerate
3. Redo — start the Refine phase over from scratch
```

If the user selects **Edit**, ask them what to change via `AskUserQuestion`, incorporate
their feedback, and re-present the updated draft. Repeat until they approve.

If the user selects **Redo**, restart Phase 4 from scratch (re-draft without carrying over
previous draft).

---

### Phase 5 — Connect

Search for related existing entries in the knowledge graph by scanning INDEX.md files for
overlapping tags, title keywords, or type similarity.

**Search procedure:**
1. Use Grep on `~/knowledge/INDEX.md` for each tag in the entry's tags list.
2. Also grep for significant words from the title (skip stop words).
3. Collect up to 5 candidate matches from the search results.
4. Filter down to the 3 most relevant based on tag overlap or keyword proximity.

If no matches are found in the master INDEX.md (e.g., the index is empty), skip Phase 5
with this note: "No existing entries found to connect — skipping connections."

If matches are found, use `AskUserQuestion` to present them:

```
I found these potentially related entries. Which should be linked?

1. <ID> — <Title> (<Type>)
2. <ID> — <Title> (<Type>)
3. <ID> — <Title> (<Type>)
4. None of the above — skip connections
5. All of the above
```

For each confirmed connection:
- Add the related entry's ID to the new entry's `related` field.
- Read the related entry's file (at `~/knowledge/<directory>/<slug>.md`).
- Add the NEW entry's ID to the related entry's `related` frontmatter field (bidirectional).
  - If the related entry already has a `related:` array, append to it.
  - If the related entry has no `related:` field, add `related: [<new-entry-id>]` after the `tags:` line.
- Write the updated related entry back to disk.

---

## Quick Mode

Quick mode is used when the invocation includes both `type:` and `tags:` inline metadata.
It skips Phases 2 (Explain) and 3 (Question).

**Execution:**

1. **Parse** `type:`, `tags:`, and remaining text from the argument.
2. **Validate** that `type:` matches one of the 7 known types. If not, fall back to Full CEQRC Phase 2.
3. **Skip directly to Phase 4 (Refine)**: Draft the entry using the parsed type, tags, and raw text.
   - Use the same body structure (Context, Key Insight, Evidence, Caveats).
   - Infer any missing fields (confidence, project, title, slug) the same way as Full CEQRC.
4. **Phase 4 is still required** — present the draft and get user approval.
5. **Phase 5 (Connect)** — run the same as Full CEQRC mode.

---

## Writing the Entry File

After user approval in Phase 4 (and after Phase 5 connections are resolved):

1. **Resolve the file path**: `~/knowledge/<directory>/<slug>.md`
   - Use today's date for `date` and `updated` fields (format: `YYYY-MM-DD`).
2. **Write the file** with valid frontmatter:

```markdown
---
id: <prefix><slug>
title: <title>
type: <entry_type>
date: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
tags: [<tag1>, <tag2>, ...]
related: [<id1>, <id2>]
project: <project>
confidence: <high|medium|low>
---

# <title>

## Context

<context paragraph>

## Key Insight

<key insight paragraph>

## Evidence

<evidence paragraph>

## Caveats

<caveats paragraph>
```

If `related` is empty, omit the field entirely (do not write `related: []`).

---

## Updating the Indexes

After writing the entry file, update both indexes.

### Type-level INDEX.md

Path: `~/knowledge/<directory>/INDEX.md`

Append a new row to the markdown table:

```
| <id> | <title> | <YYYY-MM-DD> | [<tags joined by ", ">] | <confidence> |
```

The type-level INDEX.md has columns: `ID | Title | Date | Tags | Confidence` (NO Type column).

### Master INDEX.md

Path: `~/knowledge/INDEX.md`

Append a new row to the markdown table:

```
| <id> | <title> | <type> | <YYYY-MM-DD> | [<tags joined by ", ">] | <confidence> |
```

The master INDEX.md has columns: `ID | Title | Type | Date | Tags | Confidence`.

---

## Completion Message

After all writes are complete, report:

```
Saved: <id>
File: ~/knowledge/<directory>/<slug>.md
Connections: <number> bidirectional links added (or "none")
Indexes updated: ~/knowledge/<directory>/INDEX.md and ~/knowledge/INDEX.md
```

---

## Constraints

- NEVER auto-approve in Phase 4. Always show the draft and wait for user confirmation.
- NEVER create entries outside the 7 type directories.
- NEVER write to any file outside `~/knowledge/`.
- NEVER skip Phase 4 (Refine) even in Quick mode.
- Filenames use slug-only, not the full ID. The full ID belongs in frontmatter only.
- Use absolute paths (`~/knowledge/`) for all file operations.
- The `related` field is optional — omit it entirely if there are no connections.
- `project` is free-form. Infer from context; default to `general`.
- Confidence defaults to `medium` unless clear signals indicate otherwise.
