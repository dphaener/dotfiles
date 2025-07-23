# Submit PR with git-spice

Please help me create and submit a pull request for my current branch using git-spice. Follow these steps:

1. First, check git status to see current state
2. Stage ALL modified files using `git add -A`
3. Create a commit with a well-formed conventional commit message following the guidelines in CLAUDE.md
4. Run `gs repo sync` to synchronize with remote
5. Submit the PR using `gs branch submit --fill --no-draft`
6. Open the created PR URL in the browser
7. Generate a Slack message with a proper hyperlink:
   - Format: ":github-pr: PR #XXX for <description> is ready for review" 
   - Use the PR number and URL from the created PR
   - Extract the description from the commit message (first line after the type prefix)
8. Copy the Slack message to clipboard as rich text HTML:
   - Create HTML with `<a href="URL">PR #XXX</a>` for the link
   - Use hexdump and osascript to copy as rich text that preserves formatting in Slack
   - Example: `html=':github-pr: <a href="URL">PR #XXX</a> for description is ready for review'`

Make sure to:
- Review the commit message with me before committing
- Ensure all files are staged to avoid pre-commit hook failures
- Use the commit message as both PR title and body
- Create the PR as non-draft
- Inform the user that the Slack message has been copied to their clipboard