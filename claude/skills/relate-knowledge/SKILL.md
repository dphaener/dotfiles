---
name: relate-knowledge
description: "Manage relationships between knowledge entries in ~/knowledge/. Link entries, explore connection graphs, or get suggestions for related entries. Use when the user wants to connect, link, or explore relationships in the knowledge graph."
---

# relate-knowledge Skill

This skill manages bidirectional relationships between knowledge entries in the personal knowledge graph at `~/knowledge/`. It supports three modes: **link**, **explore**, and **suggest**.

---

## Canonical Prefix-to-Directory Mapping

Use this table to resolve entry IDs to file paths. Do not read SCHEMA.md at runtime.

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

### ID Resolution Procedure

Given an entry ID (e.g., `arch-webapp-module-boundaries`):

1. Identify the prefix by matching the beginning of the ID against the mapping table.
   - `arch-` → `architecture/`
   - `debug-` → `debugging/`
   - `process-` → `process/`
   - `people-` → `people/`
   - `domain-` → `domain/`
   - `ref-` → `reference/`
   - `insight-` → `insight/`
2. Strip the prefix from the ID to get the slug (e.g., `webapp-module-boundaries`).
3. Construct the absolute file path: `~/knowledge/<directory>/<slug>.md`

---

## Mode Detection

Parse the invocation argument to determine mode:

- `/relate-knowledge link <id1> <id2>` → **Link mode**
- `/relate-knowledge explore <id>` → **Explore mode**
- `/relate-knowledge suggest <id>` → **Suggest mode**

If the invocation does not match any of these forms, output:

```
Usage:
  /relate-knowledge link <id1> <id2>    — create a bidirectional link between two entries
  /relate-knowledge explore <id>         — display the connection graph for an entry
  /relate-knowledge suggest <id>         — get suggestions for related entries based on tags
```

---

## Link Mode

### Invocation

`/relate-knowledge link <id1> <id2>`

### Procedure

1. **Resolve both IDs to file paths** using the ID Resolution Procedure above.

2. **Validate both files exist.** Use the Read tool to attempt reading each file.
   - If either file does not exist, report an error:
     ```
     Error: Entry "<id>" not found at <resolved-path>.
     Tip: Use /search-knowledge <query> to find the correct entry ID.
     ```
   - Do not proceed if either entry is missing.

3. **Read both files** in full.

4. **Check for existing link on id1 side:**
   - Parse the `related:` array from id1's frontmatter.
   - If `<id2>` is already in id1's `related` list, note "Link already exists: <id1> → <id2> (skipped)".
   - Otherwise, add `<id2>` to id1's `related` array.

5. **Check for existing link on id2 side:**
   - Parse the `related:` array from id2's frontmatter.
   - If `<id1>` is already in id2's `related` list, note "Link already exists: <id2> → <id1> (skipped)".
   - Otherwise, add `<id1>` to id2's `related` array.

6. **Update id1's file** (if the link is new on that side):
   - **Case A — `related:` field exists**: Append `<id2>` to the existing array in the frontmatter. Change `related: [a, b]` to `related: [a, b, <id2>]`.
   - **Case B — no `related:` field**: Add `related: [<id2>]` on a new line immediately after the `tags:` line in the frontmatter.
   - Write the updated file back to disk.

7. **Update id2's file** (if the link is new on that side) using the same Case A / Case B logic.

8. **Update the `updated` date** in frontmatter for any file that was modified. Set it to today's date (YYYY-MM-DD).

9. **Report completion:**
   ```
   Linked: <id1> ↔ <id2>
   Updated: ~/knowledge/<directory1>/<slug1>.md
   Updated: ~/knowledge/<directory2>/<slug2>.md
   ```
   If either side was already linked, include the skip note instead of "Updated" for that side.

### Constraints

- NEVER create unidirectional links. Always update both files.
- NEVER modify entry body content — only the `related` frontmatter field and the `updated` date field.
- NEVER duplicate a link. If `<id2>` already appears in `<id1>`'s `related` array, skip that side.
- NEVER add an entry's own ID to its `related` field (do not link an entry to itself).

---

## Explore Mode

### Invocation

`/relate-knowledge explore <id>`

### Procedure

1. **Resolve the ID to a file path** using the ID Resolution Procedure.

2. **Validate the file exists.** If not, report:
   ```
   Error: Entry "<id>" not found at <resolved-path>.
   Tip: Use /search-knowledge <query> to find the correct entry ID.
   ```

3. **Read the root entry file.** Extract `title`, `type`, and `related` from frontmatter.

4. **Build the connection tree** (breadth-first, up to 3 levels deep, up to 20 nodes total including the root):

   - **Level 0 (root)**: The entry itself.
   - **Level 1**: All entries in the root's `related` array. For each, read the file and extract `title`, `type`, and `related`.
   - **Level 2**: All entries in each Level 1 entry's `related` array (excluding any already visited). For each, read the file and extract `title` and `type` only (no need to recurse further).
   - Stop at Level 2. Do not recurse into Level 3+ connections.

   **Node limit**: If adding the next batch would exceed 20 total nodes, stop and record the count of remaining connections as `[N more connections...]`.

   Track visited IDs to avoid cycles and duplicate nodes in the tree.

5. **Render the tree** using indented box-drawing characters:

   ```
   <root-id> (<root-type>)
   ├── <child-id> (<child-type>)
   │   ├── <grandchild-id> (<grandchild-type>)
   │   └── <grandchild-id> (<grandchild-type>)
   └── <child-id> (<child-type>)
       └── <grandchild-id> (<grandchild-type>)
   ```

   Rules for tree rendering:
   - Use `├──` for all items except the last sibling at each level.
   - Use `└──` for the last sibling at each level.
   - Use `│   ` (pipe + 3 spaces) for continuation lines from non-last parents.
   - Use `    ` (4 spaces) for continuation lines from last parents.
   - If a node's connections were truncated due to the 20-node cap, append `[N more connections...]` as a pseudo-child using `└── [N more connections...]`.

6. **After the tree**, display a summary:

   ```
   Total connections shown: N nodes
   Direct connections: M
   ```

   If the root entry has no `related` entries, output:
   ```
   <id> has no connections yet.
   Tip: Use /relate-knowledge link <id> <other-id> to add connections.
   ```

### Example Output

```
arch-webapp-module-boundaries (architecture)
├── arch-webapp-module-ownership (architecture)
│   ├── people-platform-team-structure (people)
│   └── process-webapp-deploy-flow (process)
└── debug-circular-module-dep (debugging)
    └── insight-dependency-cycles (insight)

Total connections shown: 5 nodes
Direct connections: 2
```

---

## Suggest Mode

### Invocation

`/relate-knowledge suggest <id>`

### Procedure

1. **Resolve the ID to a file path** using the ID Resolution Procedure.

2. **Validate the file exists.** If not, report:
   ```
   Error: Entry "<id>" not found at <resolved-path>.
   Tip: Use /search-knowledge <query> to find the correct entry ID.
   ```

3. **Read the target entry file.** Extract `title`, `type`, `tags`, and existing `related` IDs from frontmatter.

4. **Collect already-related IDs** (to exclude from suggestions): parse the `related` array plus the entry's own ID.

5. **Search for candidates** using two passes:

   **Pass A — Tag search**: For each tag in the entry's `tags` array, use Grep on `~/knowledge/` (glob `**/*.md`) for `tags:.*<tag>` (case-insensitive). Collect all matching file paths. Exclude:
   - `INDEX.md`, `SCHEMA.md`, `README.md` files
   - The target entry's own file path
   - Files already in the `related` array (resolve those IDs to paths first)

   **Pass B — Type search**: Use Grep on `~/knowledge/` (glob `**/*.md`) for `type: <entry_type>` (case-insensitive). Collect matching file paths, applying the same exclusions.

   Merge Pass A and Pass B results (deduplicate by file path). Entries found in both Pass A and Pass B are the strongest candidates.

6. **Enrich candidates**: For each unique candidate file path (up to 10), read the file and extract `id`, `title`, `type`, and `tags`.

7. **Score and rank candidates**:
   - +2 points for each shared tag with the target entry
   - +1 point if the candidate has the same `type` as the target entry
   - Sort by score descending, then by `id` alphabetically for ties.
   - Take the top 5 candidates.

8. **Determine reason strings** for each candidate:
   - If shared tags exist: "Shares tags: <tag1>, <tag2>"
   - If same type only: "Same type: <type>"
   - If both: "Shares tags: <tag1>, <tag2>; same type: <type>"

9. **If no candidates are found** (after exclusions), output:
   ```
   No suggestions found for <id>.
   All entries with matching tags or type are already linked, or no matching entries exist yet.
   ```
   Stop here.

10. **Present suggestions using `AskUserQuestion`**:

    ```
    Suggested connections for <id> — <title>:

    1. <candidate-id> — <title> (<type>)
       Reason: <reason>
    2. <candidate-id> — <title> (<type>)
       Reason: <reason>
    ...
    N+1. None of the above — don't add any connections
    N+2. All of the above

    Which would you like to link? (select one or more numbers, or "none")
    ```

11. **Process the user's response**:
    - If the user selects specific numbers, link each selected candidate to the target entry using the same bidirectional link procedure as Link mode (Steps 4–8 of Link mode).
    - If the user selects "None of the above" or N+1, exit with: "No connections added."
    - If the user selects "All of the above" or N+2, link all candidates.

12. **Report completion** for each link created:
    ```
    Linked: <target-id> ↔ <candidate-id>
    Updated: <target-file-path>
    Updated: <candidate-file-path>
    ```

### Constraints

- NEVER suggest an entry that is already in the target's `related` list.
- NEVER suggest the target entry to itself.
- Always use `AskUserQuestion` — never auto-link without user confirmation.

---

## General Constraints

- **Never create new knowledge entries.** This skill only creates relationships between existing entries.
- **Only modify the `related` frontmatter field and `updated` date.** Never alter body content, title, tags, confidence, or any other field.
- **Always create bidirectional links.** Updating one side without the other is never acceptable.
- **Use absolute paths** for all file operations: `~/knowledge/`.
- **Do not read SCHEMA.md at runtime.** The prefix-to-directory mapping is embedded above.
- **If an ID cannot be resolved** (unknown prefix), report:
  ```
  Error: Cannot resolve ID "<id>" — unknown prefix.
  Known prefixes: arch-, debug-, process-, people-, domain-, ref-, insight-
  ```
