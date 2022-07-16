source $HOME/.zsh/oh-my-zsh.zsh
source $HOME/.zsh/paths.zsh
source $HOME/.zsh/env.zsh
source $HOME/.zsh/asdf.zsh
source $HOME/.zsh/aliases/all_aliases.zsh

bindkey '^l' autosuggest-accept

# For autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# For some reason I need to do this for every shell. ¯\_(ツ)_/¯
eval $(ssh-agent) > /dev/null 2>&1
ssh-add -K ~/.ssh/fermentable_ed25519 > /dev/null 2>&1
ssh-add -K ~/.ssh/id_ed25519 > /dev/null 2>&1

# Increase the JavaScript heap size
export NODE_OPTIONS=--max_old_space_size=4096

# Setup FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setup the starship prompt
eval "$(starship init zsh)"
