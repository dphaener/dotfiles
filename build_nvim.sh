#!/bin/bash

sudo apt remove -y vim vim-runtime gvim

cd /tmp
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable

sudo make CMAKE_BUILD_TYPE=Release
sudo make CMAKE_INSTALL_PREFIX=/usr/local/bin/nvim install

sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim/bin/nvim 1
sudo update-alternatives --set editor /usr/local/bin/nvim/bin/nvim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim/bin/nvim 1
sudo update-alternatives --set vi /usr/local/bin/nvim/bin/nvim
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim/bin/nvim 1
sudo update-alternatives --set vim /usr/local/bin/nvim/bin/nvim

cd ~
sudo rm -rf /tmp/neovim
