---
name: commit-style
description: Git commit message guidelines — Conventional Commits format plus the seven rules of great commit messages. Invoke BEFORE writing any git commit message, amending a commit, or drafting a PR title. Also covers the required stage-all-files-before-commit workflow.
---

# Git Commit Message Guidelines

All commits must follow the Conventional Commits specification along with the seven rules of great commit messages.

## Voice: do this first

Invoke the `humanize` skill before you write a message, and again before you amend one. It reads
the voice profile at `~/.claude/humanize/voice.md`, which owns the PR / commit register. This
skill owns format only.

Length, because format and length get confused:

- **2 to 4 sentences of prose.** That is the whole body.
- **No headers.** No bullet list unless the items are genuinely parallel, such as a list of
  version bumps.
- **Open by describing the diff plainly.** "This adds X so that Y." "This updates X to Y."
  "Because we now do X, this removes Y."
- **Close with one plain sentence of why**, not a benefits paragraph.

**Never write the root-cause essay.** That shape is a problem paragraph, then a mechanism
explanation, then a colon-introduced bullet list of changes, then an impact statement. It is the
strongest AI tell in this register. State what changed and why in a few workmanlike sentences
instead. Reserve multi-paragraph detail for changes that genuinely trap people.

Precise and polished is the failure mode here, not the target.

## PR descriptions come from the commit body

`gs branch submit --fill` and `gh pr create --fill` copy the commit message into the PR title and
body. One verbose commit message therefore produces a verbose PR description. Fix it here and
both are fixed.

## Conventional Commits Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types (Required)

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

### Scope (Optional)

A scope provides additional contextual information and is contained within parentheses.
Examples: `feat(parser):`, `fix(api):`, `docs(readme):`

### Breaking Changes

- Add `!` after type/scope to indicate breaking changes: `feat!:` or `feat(api)!:`
- Include `BREAKING CHANGE:` in the footer with description

## Seven Rules of Great Commit Messages

### 1. Separate Subject from Body with a Blank Line

- Not every commit requires a body
- Use body for complex changes that need explanation

### 2. Limit the Subject Line to 50 Characters

- Hard limit keeps messages readable
- Forces you to think about the most concise way to explain changes
- GitHub's UI will truncate longer subject lines

### 3. Capitalize the Subject Line

- ✅ `fix: Update getting started documentation`
- ❌ `fix: update getting started documentation`

### 4. Do Not End the Subject Line with a Period

- ✅ `refactor: Remove deprecated methods`
- ❌ `refactor: Remove deprecated methods.`

### 5. Use the Imperative Mood in the Subject Line

- Should complete: "If applied, this commit will _[your subject line]_"
- ✅ `feat: Add user authentication` / `fix: Resolve memory leak in data processor`
- ❌ `feat: Added user authentication` / `fix: Fixed memory leak`

### 6. Wrap the Body at 72 Characters

- Git doesn't wrap text automatically
- Keeps messages readable in terminal

### 7. Use the Body to Explain What and Why vs. How

- Focus on: what problem does this solve? Why is this change necessary? What effect does the patch have? What are the consequences?
- Avoid explaining the code itself — the diff shows that

## Complete Examples

### Simple Change

```
fix(auth): Prevent race condition in token refresh

Closes #42
```

### Change with a Body

```
feat(payments): Add recurring subscription billing

This adds automatic recurring billing on top of Stripe's subscription
API, so people stop having to renew by hand every month. Monthly and
annual intervals, a retry when a payment fails, and a grace period when
a card expires. Manual renewal was costing us signups.

BREAKING CHANGE: /api/subscribe now requires a billing_interval
parameter. Existing integrations need updating.

Refs: #123, #456
```

Note the shape: three sentences, no bullet wall, no headers. The bullet-style detail lives in one
sentence instead of a list.

### Breaking Change

```
feat(api)!: Return camelCase from user endpoints

BREAKING CHANGE: User endpoint responses use camelCase instead of
snake_case now. This matches our JavaScript style guide, and the
migration guide is at docs/migrations/v2-api.md.
```

### Anti-example: do not write this

```
fix(probe): Correct SNI mismatch in public edge checks

The two public-edge checks introduced in #76 have never passed. They
request https://caddy with a Host: app.example.dev header, but Caddy
selects a site from the TLS SNI, so the handshake terminates before the
header is parsed. This change:

- points the checks at the real hostname
- adds the network alias
- restores a green functional scope

As a result, CI now provides reliable signal on the public edge.
```

Everything after the subject line is wrong: the forensic narrative, the colon-introduced list, the
impact statement. The whole body should read: "The two public-edge checks from #76 have never
actually passed. They hit `https://caddy` with a `Host:` header, but Caddy picks the site from TLS
SNI, so the handshake dies before the header is read. This points them at the real hostname and
adds the network alias."

## Git Commit Workflow

### IMPORTANT: Stage All Files Before Committing

Before creating a commit, stage all modified files to avoid pre-commit hook failures:

1. **Stage all changes**: `git add -A`
2. **Verify staged files**: `git status`
3. **Create the commit** only after all files are staged

**Why this matters**: Many projects use pre-commit hooks that automatically format or lint code. If you don't stage all files before committing, these hooks may modify files, causing the commit to fail with "unstaged changes" errors.

## Quick Reference

### Do's

- Invoke `humanize` before writing or amending the message
- Always stage ALL modified files before committing (`git add -A`)
- Write clear, concise subject lines in Conventional Commits format
- Keep the body to 2 to 4 sentences of prose
- Explain the context and reasoning in the body
- Reference issues and pull requests
- Use imperative mood

### Don'ts

- Don't skip `humanize` — the message reads as machine-written without it
- Don't write the root-cause essay (problem, mechanism, bullet list, impact)
- Don't add headers or a bullet list to the body unless the items are genuinely parallel
- Don't commit without staging all files first
- Don't end subject with period
- Don't use past tense ("added" vs "add")
- Don't explain how the code works
- Don't commit large, unfocused changes
- Don't forget the type prefix
