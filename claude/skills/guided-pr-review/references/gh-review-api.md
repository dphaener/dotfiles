# GitHub review API recipes

Everything needed to fetch a PR, read it from a worktree, and post one batched review. Read the sections you need; the failure-mode list at the end is the one worth reading before you submit.

## Contents

- [Identifying the repo and PR](#identifying-the-repo-and-pr)
- [Fetching the PR](#fetching-the-pr)
- [Checking out a worktree (forks included)](#checking-out-a-worktree-forks-included)
- [Reading the diff and computing line numbers](#reading-the-diff-and-computing-line-numbers)
- [Building the review payload](#building-the-review-payload)
- [Submitting](#submitting)
- [Failure modes](#failure-modes)
- [Cleanup](#cleanup)

## Identifying the repo and PR

```bash
# current repo
gh repo view --json owner,name -q '.owner.login + "/" + .name'

# from an explicit target
# 4412                  -> current repo, PR 4412
# owner/repo#4412       -> that repo
# https://github.com/owner/repo/pull/4412 -> parse it
```

Set `OWNER`, `REPO`, `PR` before anything else. Every command below assumes them.

## Fetching the PR

```bash
gh pr view "$PR" --repo "$OWNER/$REPO" --json \
  number,title,body,author,url,state,isDraft,\
  baseRefName,headRefName,isCrossRepository,headRepositoryOwner,\
  additions,deletions,changedFiles,files,commits,reviews,labels
```

Fields that change how you run the review:

| Field | Why it matters |
|---|---|
| `isCrossRepository` | True for forks. The `pull/N/head` fetch below handles both, so this is informational. |
| `isDraft` | A draft PR is usually mid-thought. Worth mentioning before spending an hour on it. |
| `reviews` | Prior review comments. Read them — restating a point someone already made is the clearest bot signal. |
| `commits` | Commit messages are the author's own account of the narrative. Best single input for route ordering. |
| `body` | Often references a ticket (`ABC-1234`, a tracker URL). Useful for `[why]`. |

Existing inline comments live on a separate endpoint:

```bash
gh api "/repos/$OWNER/$REPO/pulls/$PR/comments" --paginate \
  -q '.[] | "\(.path):\(.line // .original_line) \(.user.login): \(.body)"'
```

## Checking out a worktree (forks included)

`pull/N/head` exists on the base repo for every PR, fork or not, so one recipe covers both. No need to add the fork as a remote.

```bash
WT="${TMPDIR:-/tmp}/guided-review-pr$PR"
BR="pr-$PR-review"

git worktree remove "$WT" --force 2>/dev/null || true
git branch -D "$BR" 2>/dev/null || true
git fetch origin "pull/$PR/head:$BR" --force
git worktree add "$WT" "$BR"
```

If the repo's GitHub remote isn't named `origin`, find it:

```bash
git remote -v | grep -m1 "$OWNER/$REPO" | cut -f1
```

The base branch is needed to diff against and may not be fetched locally:

```bash
git fetch origin "$BASE_REF"
git -C "$WT" diff "origin/$BASE_REF...HEAD" --stat
```

Reading files: always from `$WT`, never from the user's working tree. Their checkout is on some other branch and reading it silently mixes two versions of the code into one review.

## Reading the diff and computing line numbers

```bash
gh pr diff "$PR" --repo "$OWNER/$REPO"              # full patch
gh pr diff "$PR" --repo "$OWNER/$REPO" --name-only  # file list
```

A hunk header carries the line arithmetic you need:

```
@@ -40,8 +40,12 @@ def call
```

`-40,8` = old file, 8 lines starting at 40. `+40,12` = new file, 12 lines starting at 40.

Walk the hunk body counting:

- ` ` (context) — advances both counters
- `+` (added) — advances the **new** counter only
- `-` (removed) — advances the **old** counter only

For `side: RIGHT` (the normal case — commenting on code as it now stands) use the new counter. For `side: LEFT` (commenting on a line the PR deleted) use the old counter.

The constraint that bites: **`line` must fall inside a diff hunk.** Context lines inside a hunk are fair game; a line 200 rows away in the same file is not, even though the file is in the PR.

## Building the review payload

Write `review.json` with the Write tool rather than assembling it in the shell. Comment bodies contain newlines, backticks, and quotes, and shell interpolation mangles all three.

```json
{
  "body": "Read through this one. Overall it looks right to me...",
  "event": "COMMENT",
  "comments": [
    {
      "path": "app/services/billing/charge.rb",
      "line": 58,
      "side": "RIGHT",
      "body": "This reorder is the whole point of the change but the timeout branch isn't covered..."
    },
    {
      "path": "app/models/invoice.rb",
      "start_line": 12,
      "start_side": "RIGHT",
      "line": 18,
      "side": "RIGHT",
      "body": "Could these three predicates collapse into one scope?"
    }
  ]
}
```

Field rules:

- `path` and `body` are required on every comment.
- `line` alone = single-line comment.
- `start_line` + `line` = multi-line range; `line` is the **last** line of the range, not the first. Getting these backwards is a 422.
- `side` defaults to `RIGHT`. Set it explicitly anyway — it documents intent and costs nothing.
- Don't use `position`. It's the legacy diff-offset field, it's brittle, and `line` supersedes it.
- Omitting `event` creates a **pending** review, visible only to the author of the review. Useful if the reviewer wants to eyeball it in the GitHub UI before submitting; otherwise set the event and submit in one call.

Paths are repo-relative with no leading slash, and must match the diff exactly — including case, and including the pre-rename path if you're commenting on a `LEFT` side of a renamed file.

## Submitting

Pre-flight first. One bad anchor fails the entire call, so discovering it after the reviewer has approved nine comments is the worst possible time:

```bash
python3 scripts/validate_review_json.py review.json --repo "$OWNER/$REPO" --pr "$PR"
# or, if you already saved the patch:
python3 scripts/validate_review_json.py review.json --diff pr.patch
```

It parses the hunks, checks every path against the diff and every line against the commentable set for its side, and flags inverted multi-line ranges and legacy `position` fields. Exit 0 means postable.

```bash
gh api --method POST "/repos/$OWNER/$REPO/pulls/$PR/reviews" --input review.json
```

Success returns the review object with an `id` and `html_url`. Give the reviewer the `html_url`.

To submit a pending review later:

```bash
gh api --method POST \
  "/repos/$OWNER/$REPO/pulls/$PR/reviews/$REVIEW_ID/events" \
  -f event=COMMENT -f body="..."
```

Events: `COMMENT` (default and safe), `APPROVE`, `REQUEST_CHANGES`. Two constraints worth knowing: you can't `APPROVE` or `REQUEST_CHANGES` your own PR, and `REQUEST_CHANGES` blocks merge on many branch protection configs. Neither should ever be chosen without the reviewer saying so.

## Failure modes

| Response | Cause | Fix |
|---|---|---|
| `422 pull_request_review_thread.line must be part of the diff` | Line isn't inside a hunk | Recompute from the hunk header, or move the note into the review `body` with a `path:line` reference |
| `422 pull_request_review_thread.path diff too large` | GitHub truncated that file's diff | Can't comment inline. Put it in the `body`. |
| `422 start_line must precede line` | Multi-line range inverted | `line` is the last line of the range |
| `422 for 'properties/comments/0/path'` | Path doesn't match the diff | Compare against `gh pr diff --name-only`; check case and renames |
| `404` on the reviews endpoint | Wrong owner/repo, or no PR read access | Re-resolve from the PR URL |
| `403` with a valid token | Fine-grained token without `pull_requests: write` | `gh auth status`, then `gh auth refresh -s repo` |
| `422 Can not approve your own pull request` | Event was `APPROVE` on the reviewer's own PR | Use `COMMENT` |

When one comment fails, the whole call fails and nothing posts. Report which comment and offer to relocate it — don't retry with it silently dropped, since the reviewer approved that comment and would reasonably assume it landed.

## Cleanup

```bash
git worktree remove "$WT" --force
git branch -D "$BR"
```

`git worktree prune` cleans up stale entries if a previous session died without removing its worktree.
