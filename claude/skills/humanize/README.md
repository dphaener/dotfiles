# humanize

Rewrites prose so it doesn't read as AI-drafted, in your own voice once you've taught it one. Two skills: `humanize` (the rewrite/draft engine) and `humanize-init` (builds the voice profile it reads from).

---

## ⚠️ Coexistence warning — read before installing

If you already have a personal `humanize` skill installed elsewhere (for example under `~/.claude/skills/`), **remove or rename it before adopting these skills.** Two skills with overlapping trigger descriptions both match on every draft/de-AI request, and Claude has no reliable way to pick one — you'll get inconsistent behavior, or both firing back to back. These skills and a pre-existing personal skill are not designed to run side by side. Pick one.

---

## Install

Copy the `humanize` and `humanize-init` skill directories into `~/.claude/skills/`. No hooks, no commands, no MCP servers, no extra setup — it's two skills plus their reference docs and evals.

## Skills

| Skill | Triggers on |
|-------|-------------|
| `humanize` | Drafting on your behalf (Slack messages, DMs, emails, PR descriptions, commit messages, release notes, doc prose) or fixing text that reads as AI-written ("humanize this", "de-AI this", "make it sound like me"). |
| `humanize-init` | Setting up, rebuilding, or refining your voice profile — "set up humanize", "teach you how I write", or whenever `humanize` reports no profile exists. Also invocable as `/humanize-init`. |

### Run `/humanize-init` first

`humanize` works out of the box, but without a voice profile it only strips AI tells — it has no personal voice to apply yet. Run `/humanize-init` (or ask in conversation, e.g. "set up humanize") before your first real draft so rewrites actually sound like you and not just "AI tells removed."

`humanize-init` asks consent-first: which repos/sources to mine (or "none, skip mining"), and when you started using AI assistants for writing, so it can exclude anything written after that date and anything with an AI co-author trailer. Every mined candidate is shown to you verbatim before it can enter the profile — nothing is added without your confirmation. If you skip mining, it falls back to a short interview plus any writing you paste in.

### Where the voice profile lives

`~/.claude/humanize/voice.md` — outside the skill directories and outside any repo. This is the only path `humanize-init` writes to (plus `.bak-<date>` backups on rebuild). It **survives skill updates and uninstalls**, because it lives outside the skill directories. Removing the skills does not delete your voice profile; reinstalling them later picks the same file back up.

## Post-merge manual QA

Once the skills are installed, confirm both paths work end to end:

1. **Fallback path.** With no `~/.claude/humanize/voice.md` on the machine, invoke the `humanize` skill on any text. Confirm it applies the generic AI-tells fallback (strips tells, no personal voice traits) and appends a one-line nudge recommending you run `/humanize-init`.
2. **Init path.** Run `/humanize-init` interactively, answer the source and cutoff questions, and complete the flow. Confirm `voice.md` lands at the literal path `~/.claude/humanize/voice.md` with frontmatter (`schema_version: 1`, `generated` date) and all seven fixed `## ` sections (`head -5 ~/.claude/humanize/voice.md` and `grep -c '^## ' ~/.claude/humanize/voice.md` should report `7`).
3. Re-run `humanize` on a draft and confirm it now reads the profile instead of falling back.

## Not for

Copying a different named writer's style, plain summarization, grammar/typo-only edits, cutting text to a length limit, or rewording machine-facing strings (API errors, logs).
