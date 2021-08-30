#!/usr/bin/env bash

sudo apt update -y

git clone https://github.com/tmux/tmux.git /tmp/tmux
cd /tmp/tmux

sh autogen.sh
./configure && make
sudo make install

cd -
rm -rf /tmp/tmux
