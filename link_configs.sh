#!/bin/bash

ln -sf ~/dotfiles/.tmux.conf ~/
ln -sf ~/dotfiles/.zsh/ ~/
rm ~/.zshrc && ln -sf ~/dotfiles/.zshrc ~/
ln -sf ~/dotfiles/.gitconfig ~/
ln -sf ~/dotfiles/.gitignore_global ~/
ln -sf ~/dotfiles/.ssh/rc ~/.ssh
ln -sf ~/dotfiles/.gemrc ~/
ln -sf ~/dotfiles/.asdfrc ~/
ln -sf ~/dotfiles/.tool-versions ~/
ln -sf ~/dotfiles/.markdownlint-cli2.yaml ~/
ln -sf ~/dotfiles/.shellcheckrc ~/
