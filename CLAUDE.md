# Git Commit Message Guidelines

This guide provides comprehensive instructions for writing excellent git commit messages. All commits must follow the Conventional Commits specification along with the seven rules of great commit messages.

## Conventional Commits Format

All commits must follow this format:
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
- Example:
  ```
  feat: derezz the master control program

  MCP turned out to be evil and had become intent on world domination.
  This commit throws Tron's disc into MCP (causing its deresolution)
  and turns it back into a chess game.
  ```

### 2. Limit the Subject Line to 50 Characters
- Hard limit keeps messages readable
- Forces you to think about the most concise way to explain changes
- GitHub's UI will truncate longer subject lines

### 3. Capitalize the Subject Line
- Start with a capital letter
- ✅ `fix: Update getting started documentation`
- ❌ `fix: update getting started documentation`

### 4. Do Not End the Subject Line with a Period
- Trailing punctuation is unnecessary
- Every character matters in the 50-char limit
- ✅ `refactor: Remove deprecated methods`
- ❌ `refactor: Remove deprecated methods.`

### 5. Use the Imperative Mood in the Subject Line
- Write as if giving a command or instruction
- Should complete: "If applied, this commit will _[your subject line]_"
- ✅ Good examples:
  - `feat: Add user authentication`
  - `fix: Resolve memory leak in data processor`
  - `docs: Update API endpoints`
- ❌ Bad examples:
  - `feat: Added user authentication`
  - `fix: Fixed memory leak`
  - `docs: Updated API endpoints`

### 6. Wrap the Body at 72 Characters
- Git doesn't wrap text automatically
- Keeps messages readable in terminal
- Allows room for Git to indent text while still staying under 80 characters

### 7. Use the Body to Explain What and Why vs. How
- Focus on:
  - What problem does this solve?
  - Why is this change necessary?
  - What effect does the patch have?
  - What are the consequences of this change?
- Avoid explaining the code itself - the diff shows that

## Complete Examples

### Simple Change
```
fix(auth): prevent race condition in token refresh

Closes #42
```

### Complex Change with Body
```
feat(payments): implement recurring subscription billing

Previously, users had to manually renew their subscriptions each month,
leading to service interruptions and lost revenue. This change adds
automatic recurring billing with configurable intervals.

The implementation uses Stripe's subscription API to handle:
- Monthly and annual billing cycles
- Automatic retry on failed payments
- Grace periods for expired cards
- Prorated upgrades/downgrades

BREAKING CHANGE: The /api/subscribe endpoint now requires a 
billing_interval parameter. Existing integrations must be updated.

Refs: #123, #456
```

### Breaking Change
```
feat(api)!: change response format for user endpoints

BREAKING CHANGE: API responses now use camelCase instead of snake_case
for all user-related endpoints. This aligns with our JavaScript style
guide and improves consistency across the codebase.

Migration guide available at: docs/migrations/v2-api.md
```

## Git Commit Workflow

### IMPORTANT: Stage All Files Before Committing

Before creating a commit, you MUST stage all modified files to avoid pre-commit hook failures:

1. **Stage all changes**: Use `git add -A` to stage all modified, new, and deleted files
   ```bash
   git add -A
   ```
   
2. **Or stage individually**: If you need more control, stage files one by one
   ```bash
   git add file1.js file2.ts
   git add src/components/MyComponent.tsx
   ```

3. **Verify staged files**: Check what will be committed
   ```bash
   git status
   ```

4. **Create the commit**: Only after all files are staged
   ```bash
   git commit -m "feat: add new feature"
   ```

**Why this matters**: Many projects use pre-commit hooks that automatically format or lint code. If you don't stage all files before committing, these hooks may modify files, causing the commit to fail with "unstaged changes" errors.

## Quick Reference

### Do's
- Always stage ALL modified files before committing (`git add -A`)
- Write clear, concise subject lines
- Use Conventional Commits format
- Explain the context and reasoning in the body
- Reference issues and pull requests
- Use imperative mood
- Keep line lengths within limits

### Don'ts
- Don't commit without staging all files first
- Don't end subject with period
- Don't use past tense ("added" vs "add")
- Don't explain how the code works
- Don't commit large, unfocused changes
- Don't forget to add type prefix

## Commit Message Template

Save this as `.gitmessage` and configure git to use it:
```
# <type>[optional scope]: <description> (50 chars)

# Why is this change necessary? (wrap at 72 chars)

# How does it address the issue?

# What side effects does this change have?

# References: #issue-number
```

Configure with: `git config --global commit.template ~/.gitmessage`