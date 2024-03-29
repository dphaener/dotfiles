source $HOME/.zsh/oh-my-zsh.zsh
source $HOME/.zsh/paths.zsh
source $HOME/.zsh/env.zsh
source $HOME/.zsh/asdf.zsh
source $HOME/.zsh/aliases/all_aliases.zsh
source $HOME/.zsh/graphite.zsh

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

# Setup all the AWS things
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

# libpq needs to be first in the path
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

export PGPASSWORD=password

# Setup the starship prompt
eval "$(starship init zsh)"
