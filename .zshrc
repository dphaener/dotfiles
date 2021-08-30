source $HOME/.zsh/oh-my-zsh.zsh
source $HOME/.zsh/pure.zsh
source $HOME/.zsh/paths.zsh
source $HOME/.zsh/env.zsh
source $HOME/.zsh/tmux.zsh
source $HOME/.zsh/asdf.zsh
source $HOME/.zsh/aliases/all_aliases.zsh

bindkey '^l' autosuggest-accept

# For autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
