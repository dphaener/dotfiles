#!/bin/bash

set -e

# Setup all command output to go to a log file
# Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
#
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/setup.log 2>&1

source ./utils/logging.sh

if [[ "$OSTYPE" == "darwin"* ]]; then
	log "Allowing $(whoami) sudo privileges with no password"
	sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

	log 'Installing Homebrew'
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/darinhaener/.zprofile
	eval "$(/opt/homebrew/bin/brew shellenv)"

	log 'Homebrew packages'
	brew bundle

	xattr -d com.apple.quarantine "$(which chromedriver)"

	log 'Updating finder to always show hidden files'
	defaults write com.apple.finder AppleShowAllFiles -boolean true
	killall Finder

else
	log 'Installing software packages'
	sudo apt update -y
	sudo apt install -y libcurl4-openssl-dev libexpat1-dev \
		gettext libz-dev libssl-dev build-essential autoconf \
		automake pkg-config libevent-dev libncurses5-dev \
		ninja-build gettext libtool libtool-bin automake cmake g++ \
		pkg-config unzip snapd ripgrep curl bison libreadline-dev pdftk \
		fd-find fzf xclip

	log 'Building latest git from source'
	~/dotfiles/build_git.sh

	log 'Building latest nvim from source'
	~/dotfiles/build_nvim.sh

	log 'Building latest tmux from source'
	~/dotfiles/build_tmux.sh
fi

log 'Installing Ruby and nodejs'
./asdf.sh

log 'Linking nvim configuration files'
mkdir -p ~/.config
ln -sf ~/dotfiles/nvim ~/.config

log 'Installing oh-my-zsh'
rm -rf ~/.oh-my-zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

log 'Installing zsh-completions'
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

log 'Installing zsh-syntax-highlighting'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

log 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

log 'Linking remaining configuration files'
./link_configs.sh

log 'Setting up HammerSpoon'
mkdir -p ~/.local/share && ln -sf ~/dotfiles/utils ~/.local/share
mkdir -p ~/.hammerspoon
cp ~/dotfiles/hammerspoon_init.lua ~/.hammerspoon/init.lua

# Link the starship config file
mkdir -p ~/.config && ln -sf ~/dotfiles/starship.toml ~/.config

log 'Running the asdf script so it works properly'
. "$HOME/.asdf/asdf.sh"

log 'Installing default gems'
asdf shell ruby 3.2.4
gem install bundler
gem install rails
gem install neovim

log 'Building and installing fastmod'
./fastmod.sh

log 'Installing crontab and custom scripts'
mkdir -p ~/bin
cp ~/dotfiles/bin/* ~/bin/
cat ~/dotfiles/crontab.txt | crontab -

log 'Installing the Tmux plugin manager and plugins'
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

log 'Updating the iTerm configuration file preferences'
# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "/Users/darinhaener/dotfiles"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

log 'Setup complete! Quit this shell and open a new one to ensure all changes take effect'
log 'Todo'
log ' - Authenticate with graphite "gt auth --token <your_cli_auth_token>"'
