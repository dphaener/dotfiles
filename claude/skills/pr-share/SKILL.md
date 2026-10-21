---
name: pr-share
description: Share a pull request to Slack for review, inferring the channel from CODEOWNERS and the ticket from the branch name. Use when the user asks to share a PR, post a PR for review, announce a PR in Slack, or says "share this PR", "let the team know it's up", "post it for review". Never announces a draft — if the PR is still a draft it stops and asks whether to promote it first. Do NOT use when the user names an explicit channel and wants the PR marked ready-for-review; that is `post-pr-to-slack`.
allowed-tools: Skill, AskUserQuestion, Bash(git:*), Bash(gh:*), Bash(jq:*), mcp__plugin_slack_slack__slack_search_channels, mcp__plugin_slack_slack__slack_send_message
---

# PR Share

Post a PR to Slack for review. Get the channel **and the exact message text** approved by the
user, then send for real. Sending is irreversible: there is no edit or delete tool here, so a
message that goes out wrong stays wrong.

> **Configure:** set `<jira-site>` (your Jira Cloud hostname) in steps 3 and 5.
> The `:github-pr:` emoji in step 4 is a custom Slack emoji; swap in one your workspace has.

Uses the `slack` plugin's MCP tools directly — `slack_search_channels` to resolve the channel,
then `slack_send_message` to post. Do not use the draft-message tool.

**No link previews.** Call `slack_send_message` without `unfurl_app_links` (or with it set to
`false`). GitHub and Jira links are app unfurls, so passing `true` adds preview cards the user
does not want. Only enable it when the user asks for previews in that request.

## 1. PR context

If the caller already has the PR URL, number, and draft status, use those. Otherwise:

```bash
gh pr view --json url,number,title,headRefName,isDraft
```

**If `isDraft` is true, stop here.** Do not resolve a channel, do not compose a message.
Ask whether to mark it ready or hold the post, and wait for an answer.

## 2. Channel

Look for a Slack channel reference in `CODEOWNERS` for the owning team (e.g. `#<team-channel>`).
If none is inferable, ask. Do not confirm the channel on its own here — it gets
confirmed together with the message text at step 5, so the user approves one thing once.

## 3. Ticket context

Extract a Jira key from the branch name (e.g. `<PROJ>-123-edit-subscription-terms` → `<PROJ>-123`).
Try the Atlassian MCP for the ticket summary; if unavailable, derive the description from the
branch slug ("edit subscription terms"). Jira URL is
`https://<jira-site>/browse/<KEY>`.

## 4. Message

**Invoke the `humanize` skill with the Skill tool.** Actually call it. Having read the voice
profile earlier in the session does not count, and neither does writing "in the author's voice"
from recall — that is the failure this instruction exists to prevent. The **Slack / DM register**
applies, not the doc register. An announcement is a chat message, not a write-up.

Slack mrkdwn link format `<url|text>`, not markdown `[text](url)`:

```
:github-pr: <PR_URL|PR #123> for <JIRA_URL|ticket summary> is ready for review
```

Drop the `<JIRA_URL|...>` wrapper and use plain description text when there is no ticket.

**That one line is the whole message by default.** Then take it to step 5 for approval — even a
one-line message goes through the gate.

### Adding context: when, and how much

Add at most **two sentences**, in one short paragraph after a blank line, and only for one of
these three reasons:

1. The PR asks for a decision, not just an approval.
2. The reviewer has to run something locally before it works.
3. The PR lives in a repo the channel does not own, so say why you posted here.

Nothing else qualifies. In particular, do not add context because the change is interesting, or
because you already have a good explanation written. A reviewer who wants the detail clicks the
link.

### Never

- **Never restate the PR description.** The PR page already says it. A post that summarizes the
  diff makes people read the same thing twice, and it is the main reason these posts get long.
- **Never narrate the mechanism.** File names, function names, and root-cause chains belong in
  the PR body. "`PDFViewer.tsx` early-returns while the key is empty" is PR-body text.
- **Never exceed one short paragraph.** Three paragraphs reads as machine-written however
  accurate it is.
- **No em dashes.** Split the sentence.
- **Never stuff a qualifier into the link line.** It stays the link line. "this one's a proposal
  and I'd like a second opinion" goes in the paragraph below.
- **No invented closers.** "Happy to hear if I've mischaracterized this" is not the author's voice.
  Use the author's real closer (e.g. "Please let me know if you have any questions"), or use none
  at all.

### Example

Too long. Mechanism narration, three paragraphs:

> :github-pr: <url|PR #98> for pulling the app's `PDF_VIEWER_LICENSE_KEY` from 1Password is ready for review
>
> The app's document preview runs a third-party PDF viewer, and `PDFViewer.tsx` early-returns
> while the license key is empty — it never constructs the viewer at all, so the preview just
> renders blank. No watermarked demo mode, which is what I'd assumed going in. […two more
> paragraphs…]

Right. The local action survives, and the mechanism goes to the PR body:

> :github-pr: <url|PR #98> for wiring up the PDF viewer license key is ready for review
>
> If you already have an `.env` you'll need to re-render it: `./scripts/setup-env.sh`, then
> `docker compose up -d --force-recreate <service>`.

## 5. Approve, then send

**Never call `slack_send_message` before the user has approved the literal text.** This is a hard
gate, not a formality. Both halves have to be true, every time:

1. **Show the message verbatim inside the `AskUserQuestion` call itself**, exactly as it will be
   sent — raw Slack mrkdwn, real URLs, real emoji code, nothing elided. Put it in the `question`
   text and in the "Post it" option's `preview`. Never show it only in your message before the
   call: the user cannot see that text while the question dialog is open. Not a rendered preview,
   not a paraphrase, not `<PR #123>` standing in for the actual link. If what you display and what
   you send differ by one character, the approval was for a message that never existed.
2. **Ask, and wait for an answer.** Name the channel in the same question so the user approves
   both at once: "Post this to #<team-channel>?" Silence is not approval, and neither is the
   user having approved an earlier draft of the same message.

Any edit after approval — a reworded sentence, a fixed link, a dropped paragraph — voids it. Show
the new text and ask again.

If the user asks for changes, revise and re-show. Do not send an in-between version.

```
AskUserQuestion(questions: [{
  header: "Slack",
  question: "Post this exact message to #<team-channel>?\n\n:github-pr: <https://github.com/<org>/<repo>/pull/321|PR #321> for <https://<jira-site>/browse/<PROJ>-123|ticket summary> is ready for review",
  options: [
    { label: "Post it", description: "Send exactly this text to #<team-channel>.",
      preview: ":github-pr: <https://github.com/<org>/<repo>/pull/321|PR #321> for <https://<jira-site>/browse/<PROJ>-123|ticket summary> is ready for review" },
    { label: "Change it", description: "Revise and re-show before sending." }
  ]
}])
```

## Never post a draft

A draft is not review-ready, so announcing one asks the team to look at something that isn't
being presented yet. There is no "draft announcement" variant of this skill.

When the PR is a draft, offer the two real options and take neither on your own:

- promote it — `gh pr ready <number>` — then post the normal ready-for-review wording
- leave it a draft and skip the post

Never run `gh pr ready` without being told to. Promoting is the user's call; posting a draft is
not an option at all.
