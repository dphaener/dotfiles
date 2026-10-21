---
name: stack-status
description: Read the shape of a git-spice stack before touching a branch. Use BEFORE creating a commit, opening a PR, choosing a base branch, or running any rebase/reset in a repo that tracks stacked branches — it tells you the current branch's real base and commit count, which is not `main`. Also use when the user asks "where am I in the stack", "show me the stack", "what's my base", or wants to move up/down/top/bottom between stacked branches.
---

# Stack Status

Orientation for stacked branches. Read the stack before you change it.

## Why this exists

In a stacked repo the current branch's base is usually **another feature branch**, not
trunk. Every tool that assumes `main` produces wrong output:

- `gh pr create` without `--base` opens a PR containing every parent commit
- `git reset --soft main` swallows parent branches' work
- `git log main..HEAD` shows the whole downstack, not this layer

So: check first.

## Is this repo stacked?

```sh
git rev-parse --verify refs/spice/data >/dev/null 2>&1 && echo "git-spice: yes"
```

`refs/spice/data` is the reliable signal. Do **not** test `git config spice.trunk` — it is
empty in normal git-spice repos even when tracking is active.

If the ref is absent, this is not a stacked repo. Stop using this skill and treat the
branch normally.

## Read the stack

```sh
gs ls          # current stack as a tree, trunk at the bottom
gs ls -a       # every tracked branch, not just this stack
gs ll          # same, plus the commits on each branch
```

Read markers in the output:

| Marker | Meaning |
|---|---|
| `(#164)` | has an open PR, number shown |
| `(needs restack)` | base moved; this branch has not been rebased onto it → see `stack-recover` |
| `(needs push)` | local commits not on the remote |
| `┃` indent | branch is stacked above the one below it |

## Get the base and commit count

```sh
gs ls --json | jq -r 'select(.name == "'"$(git branch --show-current)"'") | .down.name'
git log --oneline "$(base)..HEAD"    # commits on THIS layer only
```

## Bottom-to-top branch order

Needed by the GitHub Stacks API and by anything reasoning about merge order:

```sh
TRUNK=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
: "${TRUNK:=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)}"
CUR=$(git branch --show-current)

gs ls -a --json | jq -rs --arg cur "$CUR" --arg trunk "$TRUNK" '
  (map({key: .name, value: (.down.name // $trunk)}) | from_entries) as $d
  | [$cur]
  | until((.[-1] | $d[.] // $trunk) == $trunk; . + [$d[.[-1]]])
  | reverse | join(" ")'
```

Output is space-separated, bottom first, trunk excluded.

## Navigate

```sh
gs up          # away from trunk        gs top      # topmost branch
gs down        # toward trunk           gs bottom   # branch nearest trunk
gs trunk       # trunk itself           gs branch checkout <name>
```

Prefer these over `git checkout` — they keep git-spice's idea of the current stack in sync.

## Single-commit rule

Each branch in this workflow holds **exactly one commit**. That is a hard rule here, not a
preference. If `gs ll` shows more than one commit on the current branch, it needs squashing
before submit — `stack-submit` handles that.

## Report back

State three things, then stop:

1. current branch and its base
2. commit count on this layer
3. any `needs restack` / `needs push` markers, and which branches carry them

Do not fix anything from this skill. Restacking belongs to `stack-recover`; submitting
belongs to `stack-submit`.
