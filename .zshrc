source $HOME/.zsh/oh-my-zsh.zsh
source $HOME/.zsh/paths.zsh
source $HOME/.zsh/env.zsh
source $HOME/.zsh/aliases/all_aliases.zsh

bindkey '^l' autosuggest-accept

# For autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
[ -f /usr/share/autojump/autojump.sh ] && . /usr/share/autojump/autojump.sh

# SSH agent setup
eval $(ssh-agent) > /dev/null 2>&1
if [[ "$OSTYPE" == "darwin"* ]]; then
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519 > /dev/null 2>&1
else
  ssh-add ~/.ssh/id_ed25519 > /dev/null 2>&1
fi

# Setup FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setup all the AWS things (macOS only — skip on headless servers)
if command -v aws &>/dev/null && [[ "$OSTYPE" == "darwin"* ]]; then
  function setawsprofile {
    export AWS_PROFILE="$1"
    aws iam list-account-aliases > /dev/null 2>&1 || aws sso login
    echo "AWS set to $1"
  }
  AWS_PROFILES=$(aws configure list-profiles | tr '\012' ' ');
  compctl -k "( $AWS_PROFILES )" setawsprofile

  function setawsregion {
    export AWS_REGION="$1"
  }
fi

unsetopt nomatch

# libpq needs to be first in the path (macOS Homebrew)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
  export PATH="/usr/local/opt/libpq/bin:$PATH"
fi

export PGPASSWORD=password

# Disable Spring
export DISABLE_SPRING=true

# Setup the starship prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Gum settings
export GUM_CONFIRM_PROMPT_FOREGROUND=""
export GUM_CONFIRM_SELECTED_FOREGROUND="15"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="254"
export GUM_CONFIRM_SELECTED_BACKGROUND="69"
export GUM_CHOOSE_CURSOR_FOREGROUND="69"
export GUM_CHOOSE_HEADER_FOREGROUND="69"
export GUM_CHOOSE_ITEM_FOREGROUND=""
export GUM_CHOOSE_SELECTED_FOREGROUND="69"

# Git Spice completion
# `_git-spice` ships with the Homebrew formula and is auto-loaded by compinit.
# Map the `gs` alias (see .zsh/aliases/git.zsh) to use git-spice's completion.
(( $+functions[_git-spice] )) && compdef _git-spice gs

# opencode
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"

# Antigravity
[ -d "$HOME/.antigravity/antigravity/bin" ] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

export RUBY_TCP_NO_FAST_FALLBACK=1

# pnpm
if [ -d "$HOME/Library/pnpm" ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi
# pnpm end

[ -d "/opt/homebrew/opt/postgresql@15/bin" ] && export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# Cortex CLI completion (disable via /settings in cortex)
[[ -s ~/.zsh/completions/cortex.zsh ]] && source ~/.zsh/completions/cortex.zsh

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

command -v mise &>/dev/null && eval "$(mise activate zsh)"
