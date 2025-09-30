---
description: Create and submit a pull request using git-spice
allowed-tools: Bash(git:*), Bash(gs:*)
---

# Submit PR with git-spice

Please help me create and submit a pull request for my current branch using git-spice. 

## Arguments
- `draft` - Create/update PR as draft
- `update` - Update existing PR instead of creating new one

## Workflow

### For NEW PRs (default behavior):
1. First, check git status to see current state
2. Stage ALL modified files using `git add -A`
3. **Squash all commits into one**: 
   - Check commit history with `git log --oneline main..HEAD`
   - If there are multiple commits, use `git reset --soft main` to combine all commits
   - This ensures a single, clean commit for the PR
4. Create a commit with a well-formed conventional commit message following the guidelines in CLAUDE.md
5. Run `gs repo sync` to synchronize with remote
6. Submit the PR using `gs branch submit --fill` with draft flag based on user input:
   - If user provides "draft" argument: use `--draft`
   - Otherwise: use `--no-draft` (default behavior)
7. Open the created PR URL in the browser
8. Generate a Slack message with a markdown hyperlink:
   - For draft PRs: ":github-pr: [DRAFT PR #XXX](URL) for <description> is ready for initial feedback"
   - For regular PRs: ":github-pr: [PR #XXX](URL) for <description> is ready for review"
   - Use the PR number and URL from the created PR
   - Extract the description from the commit message (first line after the type prefix)
9. Copy the Slack message to clipboard as markdown:
   - Use markdown link format `[PR #XXX](URL)` or `[DRAFT PR #XXX](URL)` for the link
   - Copy to clipboard with pbcopy
   - Example: `:github-pr: [DRAFT PR #XXX](URL) for description is ready for initial feedback`

### For UPDATING PRs (when "update" argument provided):
1. First, check git status to see current state
2. Stage ALL modified files using `git add -A`
3. **Create fixup commits and squash**:
   - Check recent commit history with `git log --oneline -5`
   - Create fixup commit(s) for any changes: `git commit --fixup HEAD`
   - Squash fixup commits: `git rebase -i --autosquash HEAD~[number of commits]`
4. Resubmit the PR using `gs bs` (git spice branch submit)
5. Inform the user that the PR has been updated

Make sure to:
- Review the commit message with me before committing (for new PRs)
- Ensure all files are staged to avoid pre-commit hook failures
- Use the commit message as both PR title and body (for new PRs)
- Check if user provided "draft" argument to determine PR type
- Check if user provided "update" argument to determine workflow
- Inform the user that the Slack message has been copied to their clipboard (for new PRs)