#!/usr/bin/env bash
# Claude Code status line script
# Layout: dir 🌿 branch[!+?] · 🤖 ModelName · 🧠 ctx: N% · 🔀 PR #N (state) · 🌲 wt: name

GRAY='\033[90m'
BLUE='\033[34m'
PINK='\033[38;5;218m'
RESET='\033[0m'

sep() { printf "${GRAY} · ${RESET}"; }

input=$(cat)

# --- Directory ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
cd "$cwd" 2>/dev/null || cd ~
dir_name=$(basename "$cwd")
[ "$cwd" = "$HOME" ] && dir_name="~"

printf "${BLUE}%s${RESET}" "$dir_name"

# --- Git branch + status flags ---
if git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    status_flags=""
    git diff --quiet 2>/dev/null || status_flags="${status_flags}!"
    git diff --cached --quiet 2>/dev/null || status_flags="${status_flags}+"
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] && status_flags="${status_flags}?"
    printf " ${GRAY}🌿 %s${RESET}" "$branch"
    [ -n "$status_flags" ] && printf "${PINK}%s${RESET}" "$status_flags"
  fi
fi

# --- Model ---
model_raw=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model_raw" ]; then
  # Strip leading "Claude " prefix
  model_short="${model_raw#Claude }"
  sep
  printf "${GRAY}🤖 %s${RESET}" "$model_short"
fi

# --- Context window ---
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct")
  sep
  printf "${GRAY}🧠 ctx: %s%%${RESET}" "$ctx_int"
fi

# --- PR (with cache to avoid slow gh calls) ---
pr_number=$(echo "$input" | jq -r '.pr.number // empty')
if [ -n "$pr_number" ]; then
  pr_state=$(echo "$input" | jq -r '.pr.review_state // "open"')
  sep
  printf "${GRAY}🔀 PR #%s (%s)${RESET}" "$pr_number" "$pr_state"
fi

# --- Worktree ---
wt_name=$(echo "$input" | jq -r '.worktree.name // empty')
if [ -n "$wt_name" ]; then
  sep
  printf "${GRAY}🌲 wt: %s${RESET}" "$wt_name"
fi

printf '\n'
