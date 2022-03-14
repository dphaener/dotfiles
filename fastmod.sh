#!/bin/bash

cd /tmp
git clone https://github.com/facebookincubator/fastmod.git
cd fastmod
cargo build --release
sudo cp ./target/release/fastmod /usr/local/bin
cd -
rm -rf fastmod
