---
name: capture-agent-steering
description: Distill reusable user corrections and redirections from the current coding session into a concise per-PR steering log under ~/.claude/agent-sessions/. Use when a pull request becomes ready for review, a hook requests steering capture, or the user asks to update the log after later review changes.
---

# Capture agent steering

Record the reusable guidance the user had to give during this session — not a task
summary, not a transcript. The log is evidence for a later decision about which
frictions deserve a permanent guardrail.

Logs are private and cross-repo: they live in `~/.claude/agent-sessions/` and are
never committed to the project repo.

## Workflow

1. Identify the pull request:

   ```bash
   gh pr view --json number,url,title,isDraft,headRepository
   ```

   - No PR for the current branch → stop and say so. Do not invent one.
   - `isDraft: true` → stop silently. A draft is not review-ready; `gs submit`
     prompts for draft status, so the hook cannot know this in advance.
   - Stacked branches: log against the **current** branch's PR. A
     `gs stack submit` touches several PRs; one log per session is enough.

2. Choose the file. Look for an existing
   `~/.claude/agent-sessions/<repo>-pr-<number>-*.md` and update it in place.
   Otherwise create:

   ```
   ~/.claude/agent-sessions/<repo>-pr-<number>-<short-kebab-case-slug>.md
   ```

   `<repo>` is `headRepository.name` (e.g. `webapp`). Get today's date with
   `date +%F` — never guess it.

3. Review the session for reusable user steering only:
   - Corrections after you chose the wrong behavior or approach.
   - Constraints or preferences the user clarified after an incorrect assumption.
   - Rejected approaches, and the reusable reason for rejection.
   - Verification or handoff steps the user had to repeat.
   - Documented repository rules you missed or violated.

4. Exclude the initial request, acceptance criteria, an implementation recap,
   ordinary discoveries, tool output, praise, and trivial typos — plus any rule
   you followed without being prompted. Paraphrase and sanitize: no secrets,
   customer data, private links, personal information, or transcript excerpts.

5. Merge new, non-duplicate steering into the format below. Cap it: **5 rows, 3
   lowercase kebab-case tags, one sentence per cell, 400 words total.** If there
   was no material steering, write `No material user steering in this session.`
   rather than inventing a lesson.

6. Write the file. That is the whole job — no `git add`, no commit, no push. Tell
   the user the path in one line.

## Format

```markdown
---
date: YYYY-MM-DD
repo: webapp
pr: https://github.com/ORG/REPO/pull/123
agent: claude
tags: [testing, workflow]
---

# <PR title>

| Reusable rule | What triggered the correction | Scope | Candidate guardrail |
| --- | --- | --- | --- |
| Use an atomic, imperative rule. | Briefly paraphrase the mistake and redirection. | Name the relevant task, subsystem, or repo-wide context. | `instruction`, `hook`, `test`, `lint`, `tooling`, `docs`, or `none` |
```

## Boundaries

One correction is not a rule. Logs stay raw observations until a pattern repeats
across sessions — only then promote it, using the guardrail column to pick the
surface:

- `instruction` → the relevant `CLAUDE.md`
- `hook`, `lint`, `test`, `tooling` → executable enforcement in the repo
- durable cross-project insight → `/save-learning` (`~/knowledge/`)

This skill does not promote anything on its own, and it is not the memory system.
Use `/save-learning` for knowledge worth structuring and cross-referencing; this
log is only for *what the user had to correct*.
