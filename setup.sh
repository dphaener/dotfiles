#!/bin/bash

set -e

# Setup all command output to go to a log file
# Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
#
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/setup.log 2>&1

# Create a function to log current steps
#
MYTAB='  '
function log() {
  echo "${MYTAB}DEBUG: $1"
  echo "${MYTAB}"$'\e[1;33m'STEP: $'\e[0m'$'\e[1;32m'$1$'\e[0m' >&3
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  log "Allowing $(whoami) sudo privileges with no password"
  sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

  log 'Installing Homebrew'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/darinhaener/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"

  log 'Installing CLI software packages'
  brew install bash gawk wget coreutils curl asdf ripgrep \
    git nvim tmux gh gpg libpq postgresql@13 libsodium redis \
    pdftk-java

  log 'Installing GUI software packages'
  brew install --cask iterm2
  brew install --cask keybase
  brew install --cask joplin
  brew install --cask skitch

  log 'Installing the Fira Code Nerd font'
  brew tap homebrew/cask-fonts
  brew install --cask font-fira-code-nerd-font

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
    pkg-config unzip snapd ripgrep curl bison libreadline-dev pdftk

  log 'Building latest git from source'
  ~/dotfiles/build_git.sh

  log 'Building latest nvim from source'
  ~/dotfiles/build_nvim.sh

  log 'Building latest tmux from source'
  ~/dotfiles/build_tmux.sh
fi

log 'Installing Ruby, nodejs, Go, and Rust'
./asdf.sh

log 'Copying nvim configuration files'
mkdir -p ~/.config
cp -r ~/dotfiles/nvim ~/.config

log 'Install nvim plugins'
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Ensure the asdf shims are available while we're in this if block
if [[ "$OSTYPE" == "darwin"* ]]; then
  . $(brew --prefix asdf)/asdf.sh
  nvim +PlugInstall +qa
else
  . $HOME/.asdf/asdf.sh
  /usr/local/bin/nvim/bin/nvim +PlugInstall +qa
fi

log 'Installing oh-my-zsh'
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

log 'Installing zsh-completions'
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

log 'Installing zsh-syntax-highlighting'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

log 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

log 'Copying remaining configuration files'
cp ~/dotfiles/.tmux.conf ~/
cp -r ~/dotfiles/.tmuxinator ~/
cp -r ~/dotfiles/.zsh ~/
cp ~/dotfiles/.zshrc ~/
cp ~/dotfiles/.gitconfig ~/
cp ~/dotfiles/.gitignore_global ~/
cp ~/dotfiles/.ssh/rc ~/.ssh
cp ~/dotfiles/.gemrc ~/
cp ~/dotfiles/.asdfrc ~/
cp ~/dotfiles/.tool-versions ~/

log 'Sourcing the zshrc file so asdf works properly'
source ~/.zshrc

log 'Building and installing fastmod'
cd /tmp
git clone https://github.com/facebookincubator/fastmod.git
cd fastmod
cargo build --release
sudo cp ./target/release/fastmod /usr/local/bin
cd -
rm -rf fastmod

log 'Installing crontab and custom scripts'
mkdir -p ~/bin
cp ~/dotfiles/update_git_repos.sh ~/bin/
cat ~/dotfiles/crontab.txt | crontab -

log 'Installing Pure prompt'
mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

log 'Installing the Tmux plugin manager and plugins'
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

log 'Setup complete! Quit this shell and open a new one to ensure all changes take effect'
