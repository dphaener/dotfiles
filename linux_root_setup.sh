#!/bin/bash

set -e

# Setup all command output to go to a log file
# Reference: https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
#
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/root_setup.log 2>&1


# Create a function to log current steps
#
MYTAB='  '
function log() {
  echo "${MYTAB}DEBUG: $1"
  echo "${MYTAB}"$'\e[1;33m'SETUP: $'\e[0m'$'\e[1;32m'$1$'\e[0m' >&3
}

log 'Installing software packages'
apt update -y
apt upgrade -y
apt install -y zsh

chsh -s /usr/bin/zsh

log 'Installing oh-my-zsh'
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

log 'Installing zsh-completions'
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

log 'Installing zsh-syntax-highlighting'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

log 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

log 'Copying default Oh My Zsh rc file'
cp ./.zshrc_linux_root ~/.zshrc

log 'Creating the dphaener user'
useradd -m -s /usr/bin/zsh -p $(openssl passwd -crypt 'changeme') dphaener
echo "dphaener ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
mkdir -p /home/dphaener/.ssh
cp /root/.ssh/authorized_keys /home/dphaener/.ssh
chown -R dphaener:dphaener /home/dphaener/.ssh
cp /root/dotfiles/.zshrc_user_default /home/dphaener/.zshrc
chown dphaener:dphaener /home/dphaener/.zshrc
mv /root/dotfiles /home/dphaener/dotfiles
chown -R dphaener:dphaener /home/dphaener/dotfiles

log 'Root setup complete! Quit this shell and open a new one to ensure all changes take effect.'
