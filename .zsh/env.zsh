export EDITOR="nvim"
export REACT_EDITOR=nvim
export GPG_TTY=$(tty)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#c0c0c0,bg=#444444,underline"
export ZK_NOTEBOOK_DIR="$HOME/Nextcloud/zettelkasten/"

if test -f "$HOME/env.zsh"; then
  source "$HOME/env.zsh"
fi
