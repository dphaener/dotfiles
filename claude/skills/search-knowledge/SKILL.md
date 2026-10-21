---
name: search-knowledge
description: "Search the personal knowledge graph at ~/knowledge/ by keyword, tag, or type. Use when the user wants to find existing knowledge entries, look up past learnings, or browse the knowledge base."
---

# search-knowledge Skill

Search the personal knowledge graph for entries matching a query. This skill is **read-only** — it never modifies any files.

## Invocation Forms

- `/search-knowledge <query>` — search by keyword, term, or tag
- `/search-knowledge tags` — list all unique tags with entry counts

---

## Subcommand: `/search-knowledge tags`

When the user invokes `/search-knowledge tags`:

1. Read the file `~/knowledge/INDEX.md` using the Read tool.
2. Parse the Tags column from every data row (rows after the header and separator).
3. Split each Tags cell on commas (tags are stored as `[tag1, tag2, ...]` — strip brackets, spaces, and quotes).
4. Collect all individual tags, count how many entries each tag appears in, and sort by count descending (then alphabetically for ties).
5. Present as a formatted list:

```
Available tags (N unique tags across M entries):

  authentication (3)
  billing (2)
  oauth (2)
  sidekiq (1)
  ...
```

6. If the INDEX.md has no data rows (empty KB), output:
   > No entries yet — use /save-learning to add your first entry.

---

## Main Search: `/search-knowledge <query>`

The query may be a single word, multiple words, a tag name, or a type name. Execute the three strategies below in order, then merge and rank results.

### Pre-flight: Check for Empty KB

Before searching, read `~/knowledge/INDEX.md`. If the table contains no data rows, immediately output:

> No entries yet — use /save-learning to add your first entry.

Stop here; do not proceed with the search strategies.

---

### Strategy 1 — Tag Search

Use the Grep tool to search for the query term in `tags:` frontmatter lines across all knowledge files.

**Grep call:**
- pattern: `tags:.*<query>` (case-insensitive, `-i`)
- path: `~/knowledge/`
- glob: `**/*.md`
- output_mode: `files_with_matches`

For multi-word queries, run one Grep per word and collect the union of matching file paths.

Exclude these files from results:
- Any file named `INDEX.md`
- Any file named `SCHEMA.md`
- Any file named `README.md`

Record every matched file path for the result set, noting it was matched by **tag**.

---

### Strategy 2 — Title/Content Search

Use the Grep tool to search all `.md` files for the query term anywhere in the file content.

**Grep call:**
- pattern: `<query>` (case-insensitive, `-i`)
- path: `~/knowledge/`
- glob: `**/*.md`
- output_mode: `files_with_matches`

Exclude these files from results:
- Any file named `INDEX.md`
- Any file named `SCHEMA.md`
- Any file named `README.md`

For multi-word queries (e.g., "billing job"):
- Run a separate Grep for each word.
- Rank files that appear in results for ALL words highest (most relevant), then files matching most words, then fewer.

Merge with Strategy 1 results. Deduplicate by file path.

---

### Strategy 3 — Index Scan (fallback)

Run this strategy only if the combined result set from Strategies 1 and 2 has **fewer than 3 results**.

Read `~/knowledge/INDEX.md` using the Read tool. Scan the Title and Tags columns for case-insensitive matches against the query term(s). For any matching row, resolve the file path using this logic:

1. Take the ID from the ID column (e.g., `arch-webapp-auth-flow`).
2. Look up the prefix in the canonical type taxonomy:
   - `arch-` → `architecture/`
   - `debug-` → `debugging/`
   - `process-` → `process/`
   - `people-` → `people/`
   - `domain-` → `domain/`
   - `ref-` → `reference/`
   - `insight-` → `insight/`
3. Strip the prefix from the ID to get the slug (e.g., `webapp-auth-flow`).
4. Construct path: `~/knowledge/<directory>/<slug>.md`

Add any newly found file paths to the result set (deduplicate).

---

### Result Enrichment

For each unique file path in the final result set (up to 10 files):

1. Read the file using the Read tool.
2. Extract from frontmatter:
   - `title`
   - `type`
   - `date`
   - `confidence`
   - `tags`
3. Extract the **Key insight summary**: Look for the first section heading (e.g., `## Key insight`, `## Summary`, `## Symptom`, or `## Root Cause`) after the frontmatter. Read the first 1-2 sentences of that section's body text. If no such section exists, use the first non-blank body paragraph.

---

### Result Presentation

Display a numbered list, capped at 10 results:

```
Found N results for "<query>":

1. **<title>**
   Type: <type> | Date: <date> | Confidence: <confidence>
   Tags: <tag1>, <tag2>, ...
   <1-2 sentence summary from Key insight / first body section>
   Path: ~/knowledge/<directory>/<slug>.md

2. ...
```

After the list, add:
> To read a full entry, say "Read entry N" or provide the path.

If the result set is empty after all three strategies, output:
> No matches found. Try broader terms or check /search-knowledge tags to see all available tags.

---

## Ranking Order

When sorting results for display, use this priority (highest first):

1. Files matched by both tag search **and** content/title search
2. Files matched by tag search only
3. Files matched by all query words in content/title search
4. Files matched by most query words in content/title search
5. Files found via index scan only

Within a tier, sort by `date` descending (most recent first).

---

## Constraints

- **Read-only**: Never write, create, or modify any file.
- **No semantic search**: Use only Grep and Read — no vector or embedding-based matching.
- **Targeted search**: Use Grep for the initial pass; read individual files only during result enrichment, not as a bulk scan.
- **10-result cap**: Never present more than 10 results. If more match, silently truncate (show the highest-ranked 10).
- **Excluded files**: INDEX.md, SCHEMA.md, and README.md must never appear as search results.

---

## Type Taxonomy Reference

| Type | ID Prefix | Directory |
|------|-----------|-----------|
| architecture | `arch-` | `architecture/` |
| debugging | `debug-` | `debugging/` |
| process | `process-` | `process/` |
| people | `people-` | `people/` |
| domain | `domain-` | `domain/` |
| reference | `ref-` | `reference/` |
| insight | `insight-` | `insight/` |

All paths are under `~/knowledge/`.
