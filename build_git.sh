#!/bin/bash

sudo apt remove -y git
cd /tmp
curl -L https://api.github.com/repos/git/git/tarball > git.tar.gz
tar -xf git.tar.gz
cd git-*
make configure
./configure
make prefix=/usr/local all
sudo make prefix=/usr/local install
which git
git --version

cd ~
rm -rf /tmp/git-*
rm /tmp/git.tar.gz
