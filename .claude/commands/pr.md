---
description: Create and submit a pull request using git-spice
allowed-tools: Bash(git:*), Bash(gs:*), Bash(open:*), Bash(echo:*), Bash(pbcopy:*), mcp__atlassian__get_issue
---

# Submit PR with git-spice

Please help me create and submit a pull request for my current branch using git-spice.

## Arguments
- `draft` - Create/update PR as draft
- `update` - Update existing PR instead of creating new one

## Workflow

### For NEW PRs (default behavior):
1. **Extract JIRA ticket from branch name**:
   - Get the current branch name using `git branch --show-current`
   - Extract JIRA ticket pattern (e.g., TURT-123, ARCH-456) from the branch name using regex
   - If a JIRA ticket is found, try to fetch ticket details:
     - FIRST: Try `mcp__atlassian__get_issue` with cloudId: "ontra-team.atlassian.net" and issueIdOrKey: the extracted ticket number
     - If MCP succeeds: Store the ticket summary/title for use in the Slack message
     - If MCP fails or is unavailable: Use the branch description (text after ticket number) as the description
       - Example: Branch `TURT-200-edit-subscription-terms` → description is "edit subscription terms"
       - Clean up the description: replace hyphens with spaces and capitalize appropriately
   - Always construct JIRA URL as: `https://ontra-team.atlassian.net/browse/{TICKET-NUMBER}`
2. **Check git-spice stack status**: Use `gs log short` to understand the current branch's position in the stack
3. **Verify single commit architecture**:
   - Use `gs log long` to show commits for this branch and understand the stack structure
   - Check that the current branch has exactly one commit or needs a commit created
   - If multiple commits exist on current branch, use `gs branch squash` to squash them into one
4. **Stage and commit changes**:
   - Check git status to see current state
   - Stage ALL modified files using `git add -A`
   - If no commit exists yet, create a commit with a well-formed conventional commit message following ~/CLAUDE.md guidelines
   - If commit exists and needs updating, use `git commit --amend`
5. **Synchronize with remote**: Run `gs repo sync` to synchronize the entire stack with remote
6. **Submit the PR**: Use `gs branch submit` with `--fill` flag and draft flag based on user input:
   - If user provides "draft" argument: use `--fill --draft`
   - Otherwise: use `--fill --no-draft` (default behavior)
7. **Open and share**:
   - Open the created PR URL in the browser
   - Generate a Slack message with rich text hyperlinks using AppleScript
   - Use the AppleScript below to create clickable hyperlinks in Slack
   - For draft PRs: PR link text should be "DRAFT PR #XXX", message should be ":github-pr: DRAFT PR #XXX for <description> is ready for initial feedback"
   - For regular PRs: PR link text should be "PR #XXX", message should be ":github-pr: PR #XXX for <description> is ready for review"
   - If JIRA ticket was found: Replace "<description>" with a hyperlink where the ticket summary is the link text and the JIRA URL is the link target
     - JIRA URL format: `https://ontra-team.atlassian.net/browse/TURT-123`
     - Use ticket summary from Atlassian MCP as the link text
   - AppleScript template to set both RTF and plain text clipboard formats with multiple hyperlinks:
```applescript
osascript << 'EOF'
use framework "Foundation"
use framework "AppKit"

set prURL to "ACTUAL_PR_URL"
set prText to "PR #XXX"  -- or "DRAFT PR #XXX"
set jiraURL to "https://ontra-team.atlassian.net/browse/TURT-123"  -- if JIRA ticket found
set jiraText to "TICKET_SUMMARY"  -- from Atlassian MCP
set plainText to ":github-pr: " & prText & " for " & jiraText & " is ready for review"

-- Create the message with multiple hyperlinks
set tempString to current application's NSMutableAttributedString's alloc()'s initWithString:""

-- Add prefix
set prefixString to current application's NSAttributedString's alloc()'s initWithString:":github-pr: "
tempString's appendAttributedString:prefixString

-- Add PR hyperlink
set prString to current application's NSMutableAttributedString's alloc()'s initWithString:prText
set prRange to current application's NSRange's NSMakeRange(0, prString's |length|())
set prNSURL to current application's NSURL's URLWithString:prURL
prString's addAttribute:(current application's NSLinkAttributeName) value:prNSURL range:prRange
tempString's appendAttributedString:prString

-- Add middle text
set middleString to current application's NSAttributedString's alloc()'s initWithString:" for "
tempString's appendAttributedString:middleString

-- Add JIRA hyperlink (if JIRA ticket exists)
set jiraString to current application's NSMutableAttributedString's alloc()'s initWithString:jiraText
set jiraRange to current application's NSRange's NSMakeRange(0, jiraString's |length|())
set jiraNSURL to current application's NSURL's URLWithString:jiraURL
jiraString's addAttribute:(current application's NSLinkAttributeName) value:jiraNSURL range:jiraRange
tempString's appendAttributedString:jiraString

-- Add suffix text
set suffixString to current application's NSAttributedString's alloc()'s initWithString:" is ready for review"
tempString's appendAttributedString:suffixString

-- Convert to RTF
set theRange to current application's NSRange's NSMakeRange(0, tempString's |length|())
set rtfData to tempString's RTFFromRange:theRange documentAttributes:(missing value)

-- Set clipboard with both formats
set pb to current application's NSPasteboard's generalPasteboard()
pb's clearContents()
pb's setData:rtfData forType:(current application's NSPasteboardTypeRTF)
pb's setString:plainText forType:(current application's NSPasteboardTypeString)
EOF
```
   - If NO JIRA ticket found: Use the original description text without hyperlink (fallback to old behavior)

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