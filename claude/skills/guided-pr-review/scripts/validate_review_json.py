#!/usr/bin/env python3
"""Validate a GitHub batched-review payload against a PR's actual diff.

Catches the failure that costs a reviewer their whole session: a comment
anchored to a line GitHub won't accept, discovered only at submit time as a 422.

Usage:
    python validate_review_json.py review.json --repo acme/webapp --pr 3732
    python validate_review_json.py review.json --diff saved.patch

Exit 0 = every comment is postable. Exit 1 = at least one would 422.
"""

import argparse
import json
import re
import subprocess
import sys
from collections import defaultdict

HUNK = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@")


def parse_diff(text):
    """Map path -> {"RIGHT": set(lines), "LEFT": set(lines)} of commentable lines.

    A line is commentable if it appears inside a hunk. Context lines count on
    both sides; added lines only on RIGHT; removed lines only on LEFT.
    """
    files = defaultdict(lambda: {"RIGHT": set(), "LEFT": set()})
    path = None
    old_ln = new_ln = 0

    for line in text.splitlines():
        if line.startswith("+++ "):
            target = line[4:].strip()
            if target.startswith("b/"):
                target = target[2:]
            path = None if target == "/dev/null" else target
            continue

        if line.startswith("@@"):
            m = HUNK.match(line)
            if m:
                old_ln, new_ln = int(m.group(1)), int(m.group(3))
            continue

        if path is None or not line:
            continue

        tag = line[0]
        if tag == " ":
            files[path]["LEFT"].add(old_ln)
            files[path]["RIGHT"].add(new_ln)
            old_ln += 1
            new_ln += 1
        elif tag == "+":
            files[path]["RIGHT"].add(new_ln)
            new_ln += 1
        elif tag == "-":
            files[path]["LEFT"].add(old_ln)
            old_ln += 1
        # "\ No newline at end of file", "diff --git", "index", "--- " all skipped

    return files


def validate(payload, commentable):
    problems = []

    if not payload.get("body", "").strip():
        problems.append("review body is empty — the PR-level summary is missing")

    event = payload.get("event")
    if event not in {"COMMENT", "APPROVE", "REQUEST_CHANGES", None}:
        problems.append(f"event {event!r} is not a valid review event")

    comments = payload.get("comments", [])
    if not isinstance(comments, list):
        return problems + ["comments is not a list"], 0

    for i, c in enumerate(comments):
        tag = f"comments[{i}]"
        path = c.get("path")

        if not path:
            problems.append(f"{tag}: no path")
            continue
        if not c.get("body", "").strip():
            problems.append(f"{tag} ({path}): empty body")
        if path not in commentable:
            problems.append(
                f"{tag}: path {path!r} is not in the PR diff "
                f"— GitHub will reject this comment"
            )
            continue

        side = c.get("side", "RIGHT")
        if side not in {"LEFT", "RIGHT"}:
            problems.append(f"{tag} ({path}): side {side!r} must be LEFT or RIGHT")
            continue

        line = c.get("line")
        if line is None:
            if "position" in c:
                problems.append(
                    f"{tag} ({path}): uses legacy `position`; use `line` + `side`"
                )
            else:
                problems.append(f"{tag} ({path}): no line")
            continue

        valid = commentable[path][side]
        if line not in valid:
            near = sorted(valid)[:6]
            problems.append(
                f"{tag} ({path}): line {line} on {side} is not inside any diff hunk "
                f"— would 422. Commentable {side} lines start: {near}"
            )

        start = c.get("start_line")
        if start is not None:
            if start >= line:
                problems.append(
                    f"{tag} ({path}): start_line {start} must be < line {line} "
                    f"(`line` is the LAST line of a multi-line range)"
                )
            start_side = c.get("start_side", side)
            if start not in commentable[path].get(start_side, set()):
                problems.append(
                    f"{tag} ({path}): start_line {start} on {start_side} "
                    f"is not inside any diff hunk"
                )

    return problems, len(comments)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("payload", help="path to review.json")
    ap.add_argument("--repo", help="owner/repo")
    ap.add_argument("--pr", help="PR number")
    ap.add_argument("--diff", help="path to a saved patch instead of fetching")
    args = ap.parse_args()

    with open(args.payload) as fh:
        payload = json.load(fh)

    if args.diff:
        with open(args.diff) as fh:
            diff_text = fh.read()
    else:
        if not (args.repo and args.pr):
            sys.exit("need --diff, or both --repo and --pr")
        diff_text = subprocess.run(
            ["gh", "pr", "diff", args.pr, "--repo", args.repo],
            capture_output=True, text=True, check=True,
        ).stdout

    commentable = parse_diff(diff_text)
    problems, n = validate(payload, commentable)

    print(f"{args.payload}: {n} comment(s), {len(commentable)} file(s) in diff")
    if problems:
        print(f"\nFAIL — {len(problems)} problem(s):")
        for p in problems:
            print(f"  - {p}")
        return 1
    print("\nPASS — every comment is postable.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
