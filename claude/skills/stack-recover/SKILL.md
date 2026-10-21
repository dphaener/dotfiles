---
name: stack-recover
description: Repair a broken or out-of-sync git-spice stack. Use when branches show "needs restack", a restack or rebase hits a conflict, an operation was interrupted mid-rebase, a branch sits on the wrong parent, a branch needs moving elsewhere in the stack, or the stack is a mess after a parent PR was squash-merged. Triggers on "my stack is broken", "needs restack", "restack conflict", "rebase conflict", "wrong base branch", "reorder my stack".
---

# Stack Recover

Fix stack state. Nothing here submits PRs — that is `stack-submit`.

## Diagnose first

```sh
gs ls -a          # which branches say (needs restack)
gs ll             # what commits are actually on each branch
git status         # is a rebase already in progress?
```

If `git status` shows a rebase in progress, you are mid-operation. Finish or abandon it before
anything else:

```sh
gs rebase continue     # after resolving conflicts and staging them
gs rebase abort        # give up, return to the pre-operation state
```

Use these, not `git rebase --continue`. git-spice wraps the rebase to resume its own multi-branch
operation afterward; the raw git command drops that continuation and leaves the rest of the stack
unrestacked.

## "needs restack"

Means the branch's base moved and this branch has not been rebased onto the new tip. Pick the
narrowest scope that covers the problem:

```sh
gs branch restack        # just this branch
gs upstack restack       # this branch and everything above it   ← usual choice
gs downstack restack     # this branch and everything below it
gs stack restack         # the current stack, end to end
gs repo restack          # every tracked branch in the repo
```

`gs upstack restack` is the normal fix after amending or squashing a commit: your change is in,
now push it up through the descendants.

## Conflicts during a restack

1. `git status` — see which files conflict.
2. Resolve them. Keep the intent of **both** layers; a stacked conflict is usually your layer's
   edit against a parent layer's edit of the same lines, and both are wanted.
3. `git add <files>`
4. `gs rebase continue`

Repeat per conflicted branch. git-spice restacks branches one at a time and will stop again on
the next conflict.

If it turns into a spiral, `gs rebase abort` and reconsider the stack's shape — often two
branches are touching the same code and should be one branch (`gs branch fold`) or reordered.

Consider enabling rerere so a resolution is remembered across repeated restacks:

```sh
git config rerere.enabled true
```

## After a parent PR is squash-merged

Squash-merge rewrites the parent's commits into one new commit on trunk, so your branch's base
no longer exists in trunk's history. Do not rebase by hand:

```sh
gs repo sync
```

It detects the merged branch, offers to delete it, and re-parents the branches above it onto
trunk. Then `gs upstack restack` if anything still reports needing it.

## Wrong parent, or moving a branch

```sh
gs upstack onto <new-base>     # move this branch AND its upstack onto a new base
gs branch onto <new-base>      # move only this branch; its children re-parent to its old base
gs stack edit                  # interactive reorder of the current stack
gs downstack edit              # interactive reorder of everything below this branch
```

`gs branch fold` merges a branch into its base when the split was a mistake. `gs branch split`
does the reverse.

## Tracking problems

A branch git-spice does not know about behaves like it has no stack:

```sh
gs branch track <name>       # start tracking, prompts for the base
gs downstack track           # track every untracked branch below this one
gs branch untrack <name>     # forget it
```

## Things not to do

- **`git reset --soft main`** on a stacked branch — absorbs every parent commit into yours. This
  is the single most common way to wreck a stack.
- **`git rebase --continue`** mid-`gs` operation — see above.
- **`git push --force`** — use `gs branch submit`, which force-pushes with lease checks. Only
  reach for `--force` on a `gs` command if the user asks by name.
- **Deleting branches with `git branch -D`** while tracked — use `gs branch delete` so tracking
  and the stack shape stay consistent.

## Background auto-fetch

git-spice may auto-fetch in the background, so `gs ls` output can shift between two runs for no
local reason. If state looks like it changed under you, re-run `gs ls` before concluding
something is broken.

## When you are unsure

`gs <command> -h` prints real flags for the installed version. `gs --help` opens a man page that
may not exist — use `-h`.

Report what you changed and the resulting `gs ls`, then stop. Do not submit PRs from this skill.
