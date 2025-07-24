---
description: Create and submit a pull request using git-spice
allowed-tools: Bash(git:*), Bash(gs:*)
---

# Submit PR with git-spice

Please help me create and submit a pull request for my current branch using git-spice. Follow these steps:

1. First, check git status to see current state
2. Stage ALL modified files using `git add -A`
3. Create a commit with a well-formed conventional commit message following the guidelines in CLAUDE.md
4. Run `gs repo sync` to synchronize with remote
5. Submit the PR using `gs branch submit --fill --no-draft`
6. Open the created PR URL in the browser
7. Generate a Slack message with a markdown hyperlink:
   - Format: ":github-pr: [PR #XXX](URL) for <description> is ready for review" 
   - Use the PR number and URL from the created PR
   - Extract the description from the commit message (first line after the type prefix)
8. Copy the Slack message to clipboard as markdown:
   - Use markdown link format `[PR #XXX](URL)` for the link
   - Copy to clipboard with pbcopy
   - Example: `:github-pr: [PR #XXX](URL) for description is ready for review`

Make sure to:
- Review the commit message with me before committing
- Ensure all files are staged to avoid pre-commit hook failures
- Use the commit message as both PR title and body
- Create the PR as non-draft
- Inform the user that the Slack message has been copied to their clipboard