source $HOME/.zsh/aliases/git.zsh
source $HOME/.zsh/aliases/zellij.zsh

# Vim
alias vi='nvim'
alias vim='nvim'

# Ruby/Rails
alias be='bundle exec'

# lsd (if installed, otherwise default ls)
command -v lsd &>/dev/null && alias ls='lsd'

# Session managers (if installed)
command -v zellijinator &>/dev/null && alias zel='zellijinator'
command -v tmuxinator &>/dev/null && alias mux='tmuxinator'
