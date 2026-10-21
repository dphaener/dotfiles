---
description: Submit a PR for the current git-spice branch and share it
allowed-tools: Bash(git:*), Bash(gs:*), Bash(gh:*), Bash(jq:*), Bash(open:*), Skill, mcp__plugin_slack_slack__slack_search_channels, mcp__plugin_slack_slack__slack_send_message
---

# Submit PR

Orchestrate the skills below. Do not reimplement what they cover.

## Arguments

- `draft` — submit as a draft
- `update` — update the existing PR instead of opening a new one

## Sequence

1. **Orient** — invoke `stack-status`. Get the current branch, its real base, its commit count,
   and any `needs restack` markers.
   - Not a git-spice repo (`refs/spice/data` absent)? Say so and stop. Use plain `gh pr create`
     instead — this command is for stacked branches.
   - Anything needs restack? Invoke `stack-recover` and finish that before continuing.

2. **Commit message** — invoke `commit-style` for the format and `humanize` for the voice, if a
   commit needs writing or amending. Both, every time. Show me the message before you commit it.
   - Step 3 submits with `--fill`, so this commit body becomes the PR description. A verbose
     commit message here produces a verbose PR. Keep the body to 2 to 4 sentences of prose.

3. **Submit** — invoke `stack-submit`. It stages, enforces one commit per branch, runs
   `gs repo sync`, submits with `--fill`, and links the stack via the GitHub Stacks API.
   Pass through the `draft` / `update` argument.

4. **Open** — `open` the PR URL in the browser.

5. **Share** — invoke `pr-share`. It resolves the channel from `CODEOWNERS`, pulls ticket context
   from the branch name, and posts to Slack. Pass it the PR URL, number, and draft status from
   step 3 so it does not re-query. It never posts a draft: if the PR is still a draft it stops
   and asks whether to promote it first.
   - The Slack post is one line by default. Do not hand `pr-share` the commit body or a summary
     of the diff to paste in. `pr-share` owns the wording and the length cap.
