#!/bin/bash
# Minimal status line: model | context bar | cwd | git status | worktree
input=$(cat)

model=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input")

dim=$'\e[2m'; reset=$'\e[0m'; green=$'\e[32m'; yellow=$'\e[33m'; red=$'\e[31m'; cyan=$'\e[36m'

# Context bar
ctx=""
if [ -n "$pct" ]; then
  p=${pct%.*}
  width=10
  filled=$(( (p * width + 50) / 100 ))
  (( filled > width )) && filled=$width
  if   (( p >= 80 )); then color=$red
  elif (( p >= 50 )); then color=$yellow
  else color=$green; fi
  bar=$(printf '%*s' "$filled" '' | tr ' ' '█')$(printf '%*s' "$((width - filled))" '' | tr ' ' '░')
  ctx="${color}${bar}${reset} ${p}%"
fi

# Git status + worktree
git_part=""; wt_part=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(grep -c '^[MADRC]' <<<"$status")
  modified=$(grep -c '^.[MD]' <<<"$status")
  untracked=$(grep -c '^??' <<<"$status")
  flags=""
  (( staged ))    && flags+=" ${green}+${staged}${reset}"
  (( modified ))  && flags+=" ${yellow}~${modified}${reset}"
  (( untracked )) && flags+=" ${red}?${untracked}${reset}"
  if ab=$(git -C "$cwd" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
    behind=${ab%%[[:space:]]*}; ahead=${ab##*[[:space:]]}
    (( ahead ))  && flags+=" ↑${ahead}"
    (( behind )) && flags+=" ↓${behind}"
  fi
  [ -z "$flags" ] && flags=" ${green}✓${reset}"
  git_part="${cyan}${branch}${reset}${flags}"

  # Linked worktree: git-dir differs from common dir
  gd=$(cd "$cwd" && realpath "$(git rev-parse --git-dir)" 2>/dev/null)
  cd_=$(cd "$cwd" && realpath "$(git rev-parse --git-common-dir)" 2>/dev/null)
  if [ -n "$gd" ] && [ "$gd" != "$cd_" ]; then
    wt_part="⎇ $(basename "$(git -C "$cwd" rev-parse --show-toplevel)")"
  fi
fi

# Working directory, with $HOME shown as ~
dir_part=""
tilde='~'
[ -n "$cwd" ] && dir_part="${cwd/#$HOME/$tilde}"

sep=" ${dim}│${reset} "
out="$model"
[ -n "$ctx" ]      && out+="${sep}${ctx}"
[ -n "$dir_part" ] && out+="${sep}${dir_part}"
[ -n "$git_part" ] && out+="${sep}${git_part}"
[ -n "$wt_part" ]  && out+="${sep}${wt_part}"
printf '%s' "$out"
