---
name: stack-submit
description: Submit or update a pull request for a git-spice stacked branch, then register the stack on GitHub. Use when the user asks to submit a PR, open a PR, push work up for review, or update an existing PR while working on stacked branches — "submit my PR", "put this up for review", "update the PR", "ship this layer". Handles repo sync, the one-commit-per-branch squash, `gs branch submit`, and linking the stack via the GitHub Stacks API. Do NOT use in repos without git-spice tracking — open PRs normally there.
---

# Stack Submit

Submit the current stacked branch as a PR, then link the stack on GitHub.

## Preconditions

Run `stack-status` first if you have not already. You need the current branch, its base, and
its commit count. Abort if `refs/spice/data` is absent — this skill is for git-spice repos only.

If any branch shows `(needs restack)`, resolve that with `stack-recover` **before** submitting.
Submitting an un-restacked branch produces a PR diff containing the parent's changes.

## 1. One commit per branch — hard rule

Each branch carries exactly one commit. Enforce it:

```sh
git add -A                      # always stage everything; pre-commit hooks reformat files
```

- **No commit yet** → write one. Invoke `commit-style` for the format and `humanize` for the
  voice. Both, every time. Show it to the user before committing.
- **Commit exists, new changes** → `gs commit amend` (or `git commit --amend`).
- **More than one commit on the branch** → `gs branch squash`. Confirm the resulting message
  with the user; squash discards the individual messages.

Never `git reset --soft main` to collapse commits. On a stacked branch that absorbs every
parent commit into yours.

## 2. Sync the stack

```sh
gs repo sync
```

Pulls trunk, detects merged branches, and offers to delete them. If it reports conflicts or
leaves branches needing restack, hand off to `stack-recover` and stop.

## 3. Submit

```sh
gs branch submit --fill                 # this layer only
gs branch submit --fill --draft         # user asked for a draft
gs branch submit --fill --no-draft      # explicitly ready for review
```

`--fill` takes the PR title and body from the commit message — which is why the commit message
matters. A commit body that runs to headers and bullet walls becomes a PR description that does
the same, so fix the length in step 1, not here. Use `--update-only` when the user only wants
existing PRs refreshed and no new ones created.

Submit wider only when the user asks for it:

```sh
gs downstack submit --fill    # this branch and everything below it
gs stack submit --fill        # the whole stack
```

**Never** pass `--force` or `--no-verify` unless the user explicitly asks for it by name.

## 4. Register the stack on GitHub

GitHub's native stacked PRs (public preview since 2026-07-30) render a stack map on the PR
page, support one-click whole-stack merge, and show up on mobile. git-spice does not do this
itself, so link the stack explicitly.

Use the **Stacks REST API** via `gh api`. No extension needed — do not install or invoke
`gh stack`, which is a competing stacking tool that would duplicate git-spice's job.

Skip this step entirely when either holds:

- fewer than two PRs in the chain — nothing to link
- the PRs are not contiguous from trunk (a parent branch has no PR yet)

Collect PR numbers for the current stack, bottom to top:

```sh
TRUNK=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
: "${TRUNK:=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)}"
CUR=$(git branch --show-current)

PRS=$(gs ls -a --json | jq -rs --arg cur "$CUR" --arg trunk "$TRUNK" '
  (map({key: .name, value: (.down.name // $trunk)}) | from_entries) as $down
  | (map(select(.change != null)
      | {key: .name, value: (.change.id | ltrimstr("#") | tonumber)}) | from_entries) as $pr
  | [$cur]
  | until((.[-1] | $down[.] // $trunk) == $trunk; . + [$down[.[-1]]])
  | reverse | map($pr[.]) | map(select(. != null)) | join(",")')
```

Check whether the bottom PR is already in a stack, then create or extend:

```sh
BOTTOM=${PRS%%,*}
STACK=$(gh api "/repos/{owner}/{repo}/stacks?pull_request=$BOTTOM" -q '.[0].number' 2>/dev/null)

if [ -z "$STACK" ]; then
  # Create — ordered bottom to top
  gh api --method POST /repos/{owner}/{repo}/stacks \
    -f "pull_requests[]=$(echo "$PRS" | tr ',' '\n' | paste -sd, -)"
else
  # Extend — appends onto the TOP of the existing stack
  gh api --method POST "/repos/{owner}/{repo}/stacks/$STACK/add" \
    -F "pull_requests[]=<new-pr-number>"
fi
```

Prefer `--input` with a JSON body when passing several numbers, since the array shape matters:

```sh
printf '{"pull_requests":[%s]}' "$PRS" \
  | gh api --method POST /repos/{owner}/{repo}/stacks --input -
```

Endpoints, for reference:

| Action | Call |
|---|---|
| list / find by PR | `GET /repos/{owner}/{repo}/stacks?pull_request=N` |
| create | `POST /repos/{owner}/{repo}/stacks` — `{"pull_requests":[bottom,…,top]}` |
| extend | `POST /repos/{owner}/{repo}/stacks/{n}/add` — appends to the top |
| dissolve | `POST /repos/{owner}/{repo}/stacks/{n}/unstack` — no body |

Linking is metadata only: it does not push, retarget PR bases, change draft status, or merge
anything. git-spice already set each PR's base correctly, so nothing else is required.

If the API returns 404 on `/stacks`, stacked PRs are not enabled for that repo yet — say so once
and move on. Do not fall back to installing anything.

## 5. Hand off

Report the PR URL(s) and whether the stack was linked. Stop there. Announcing the PR is a
separate concern — the `/pr` command handles Slack when the user runs it that way. Do not post
anywhere from this skill.

## Updating an existing PR

Same path, shorter: `git add -A` → `gs commit amend` → `gs repo sync` → `gs branch submit --fill`.
Re-run the stack-link step only if the stack's shape changed — amending a commit does not change
stack membership, so linking is usually a no-op on updates.
