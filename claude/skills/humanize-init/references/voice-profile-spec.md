# Voice Profile Specification

**Contract for `~/.claude/humanize/voice.md`.** The `humanize-init` skill writes this file; the `humanize` skill reads it. Both skills MUST conform to this spec exactly — it is the only interface between them.

All examples in this document are **invented placeholders** (a fictional user, "Jordan"). They illustrate shape, never content. The humanize-init skill must derive real content from the user's own verified writing.

## File location

- Path: `~/.claude/humanize/voice.md`. No other location is valid.
- The `humanize-init` skill MUST NOT write voice-profile state anywhere else — not to the current repo, not to plugin directories, not to any repo-tracked path. The only writable directory for this feature is `~/.claude/humanize/`.

## Header block (required)

The file MUST begin with a YAML frontmatter block, exactly this shape:

```yaml
---
schema_version: 1
generated: 2026-07-28        # ISO 8601 date the profile was generated or last regenerated
refined: 2026-08-02          # optional; ISO 8601 date of the most recent refine pass, omit if never refined
---
```

Rules:

- `schema_version` is a bare integer. Current version: `1`. It changes only when this spec changes incompatibly.
- `generated` is required. `refined` is optional and only present after a refine run.
- No other frontmatter keys are defined in version 1. Readers MUST ignore unknown keys; writers MUST NOT add them.

### Version check (humanize skill, required behavior)

Before using the profile, the `humanize` skill MUST parse `schema_version`:

- `schema_version: 1` → use the profile.
- Missing frontmatter, missing `schema_version`, or any value other than `1` → treat the user as **pre-init**: fall back to generic de-AI mode (strip AI tells only, apply no personal voice traits) and tell the user to run the init skill. Never guess at or partially apply an unrecognized profile.

## Section taxonomy (fixed)

After the header, the body MUST contain exactly these H1/H2 headings, in this order. The heading text is fixed; everything under each heading is per-user.

```markdown
# Voice profile

## Voice traits

## Register: Slack / DM

## Register: Docs / long-form

## Register: Email

## Register: PR / commit

## Vocabulary notes

## Provenance
```

A register section with no mined evidence still appears, containing the single line: `No verified samples for this register. Apply Voice traits plus generic de-AI rules.` No section may be omitted, renamed, or reordered. No additional H2 sections are permitted in version 1 (implementers wanting extra material must fold it into an existing section as H3 or lower).

### `## Voice traits`

Cross-register traits, ordered most load-bearing first. Each trait is one bullet: **bolded trait name**, then a one-line description, then at least one supporting quote from a verified-human sample where available. Shape:

```markdown
- **Trailing ellipses to signal thinking.** Ends exploratory sentences with "..." rather than a question mark. Sample: "maybe we just cache the whole response..."
- **Numbers under ten spelled out.** "three retries", not "3 retries".
```

Traits without a supporting quote are allowed but should be the minority; the humanize skill weights quoted traits higher.

### `## Register: <name>` (all four)

Each register section holds rules that apply only in that register, using the same bullet shape as Voice traits, and SHOULD end with an H3 `### Samples` subsection containing 1–5 verbatim verified-human quotes in blockquote form:

```markdown
## Register: Email

- **Greets by first name, no "Hi".** Opens "Priya —" rather than "Hi Priya,".
- **Sign-off is just the initial.** Closes with "— J", never "Best regards".

### Samples

> Priya — the export job finished overnight. Numbers attached. — J
```

Register semantics (fixed taxonomy — do not invent new registers):

| Section | Covers |
|---|---|
| `Register: Slack / DM` | chat messages, DMs, channel posts, threaded replies |
| `Register: Docs / long-form` | design docs, wikis, READMEs, announcements over ~3 paragraphs |
| `Register: Email` | any email body |
| `Register: PR / commit` | commit messages, PR titles/descriptions, review comments |

### `## Vocabulary notes`

Words and phrases the user characteristically uses or avoids. Two fixed H3 subsections:

```markdown
### Uses

- "ship it" for approving a change
- "gnarly" for hard bugs

### Avoids

- "leverage" as a verb
- corporate sign-offs ("Best," "Warm regards")
```

Either subsection may contain `- (none recorded)` if mining found nothing.

### `## Provenance`

One bullet per source that contributed samples. Required fields per entry, in this order: source identifier, source type, date range mined, verification method, sample count. Shape:

```markdown
- `github.com/jordan/dotfiles` — git commit messages — 2019-03 to 2022-11 — verified human: predates user's stated AI-adoption date (2023-01) and no AI co-author trailers — 14 samples
- Slack DMs (user-pasted) — chat — 2024-05 — verified human: user pasted and attested authorship — 6 samples
- Interview answers — direct elicitation — 2026-07-28 — verified human: authored live during init — n/a (rules, not samples)
```

Every quote appearing anywhere in the profile MUST be traceable to a provenance entry. The verification method MUST state *why* the source is believed human-authored (see `mining-and-curation.md` for the accepted methods).

## Re-run semantics (init skill, required behavior)

When the init skill starts and `~/.claude/humanize/voice.md` already exists:

1. It MUST NOT overwrite the file silently under any circumstances.
2. It MUST prompt the user with exactly two options (wording may vary, semantics may not):
   - **Refine existing** — keep the current profile; mine/interview for additions and corrections; merge into the existing sections; update `refined` in the header; leave `generated` unchanged.
   - **Rebuild from scratch** — discard the current content and run the full init flow; before writing the new profile, copy the old one to `~/.claude/humanize/voice.md.bak-<generated-date>` (still inside `~/.claude/humanize/`); set a fresh `generated` date and drop `refined`.
3. If the existing file has an unknown or missing `schema_version`, the "refine" option is unavailable — offer rebuild only, and say why.
4. Declining both options exits init with the file untouched.

## Conformance checklist (for implementers)

- [ ] Frontmatter present with integer `schema_version: 1` and `generated` date
- [ ] All seven fixed H2 sections present, in order, exact heading text
- [ ] Empty registers carry the fallback line, not an omitted section
- [ ] Every quote traceable to a `## Provenance` entry with all five fields
- [ ] File written only to `~/.claude/humanize/voice.md` (plus `.bak-*` siblings on rebuild)
- [ ] Humanize skill falls back to generic de-AI mode on any unrecognized `schema_version`
