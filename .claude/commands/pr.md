---
description: Create and submit a pull request using git-spice
allowed-tools: Bash(git:*), Bash(gs:*), Bash(open:*), Bash(echo:*), Bash(pbcopy:*)
---

# Submit PR with git-spice

Please help me create and submit a pull request for my current branch using git-spice. 

## Arguments
- `draft` - Create/update PR as draft
- `update` - Update existing PR instead of creating new one

## Workflow

### For NEW PRs (default behavior):
1. **Check git-spice stack status**: Use `gs log short` to understand the current branch's position in the stack
2. **Verify single commit architecture**:
   - Use `gs log long` to show commits for this branch and understand the stack structure
   - Check that the current branch has exactly one commit or needs a commit created
   - If multiple commits exist on current branch, use `gs branch squash` to squash them into one
3. **Stage and commit changes**:
   - Check git status to see current state
   - Stage ALL modified files using `git add -A`
   - If no commit exists yet, create a commit with a well-formed conventional commit message following ~/CLAUDE.md guidelines
   - If commit exists and needs updating, use `git commit --amend`
4. **Synchronize with remote**: Run `gs repo sync` to synchronize the entire stack with remote
5. **Submit the PR**: Use `gs branch submit` with `--fill` flag and draft flag based on user input:
   - If user provides "draft" argument: use `--fill --draft`
   - Otherwise: use `--fill --no-draft` (default behavior)
6. **Open and share**:
   - Open the created PR URL in the browser
   - Generate a Slack message with markdown hyperlink
   - For draft PRs: ":github-pr: [DRAFT PR #XXX](URL) for <description> is ready for initial feedback"
   - For regular PRs: ":github-pr: [PR #XXX](URL) for <description> is ready for review"
   - Copy to clipboard with pbcopy

### For UPDATING PRs (when "update" argument provided):
1. **Check git-spice stack status**: Use `gs log short` to understand current state
2. **Stage changes and amend**:
   - Check git status to see current state
   - Stage ALL modified files using `git add -A`
   - Amend the existing commit: `git commit --amend` (preserve single commit architecture)
3. **Synchronize and resubmit**:
   - Run `gs repo sync` to synchronize the stack
   - Resubmit the PR using `gs branch submit --fill` (shorthand: `gs bs --fill`)
4. Inform the user that the PR has been updated

## Key Principles:

### Git-Spice Stack Awareness
- **Always use `gs log short` first** to understand branch relationships and avoid confusion about stacked branches
- **Use `gs log long`** to see commits and understand the stack structure
- **Leverage git-spice commands** for stack operations rather than raw git commands when possible

### Single Commit Architecture
- **Each branch should have exactly one commit** - this is the git-spice way
- **Use `gs log long` to verify** the current branch commit status
- **If multiple commits exist**, use `gs branch squash` to squash them into one
- **For updates, use `git commit --amend`** to maintain single commit per branch

### Error Prevention
- **Never use `git reset --soft main`** when working with stacked branches - this will include parent branch commits
- **Always check `gs log short`** before making assumptions about branch content
- **Use git-spice sync operations** (`gs repo sync`) to handle stack synchronization properly

Make sure to:
- Review the commit message with me before committing (for new PRs)
- Ensure all files are staged to avoid pre-commit hook failures
- Use the commit message as both PR title and body (for new PRs)
- Check if user provided "draft" argument to determine PR type
- Check if user provided "update" argument to determine workflow
- Inform the user that the Slack message has been copied to their clipboard (for new PRs)