if [[ "$OSTYPE" == "darwin"* ]]; then
  . $(brew --prefix asdf)/asdf.sh
else
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
  cd ~/.asdf
  git checkout "$(git describe --abbrev=0 --tags)"

  . $HOME/.asdf/asdf.sh
fi

# Add the Ruby plugin and install the latest
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.1.0
asdf install ruby 2.7.1

# Add the nodejs plugin and install the latest
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
asdf install nodejs 16.13.1

# Add the go plugin and install the latest
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
asdf install golang 1.17.5

# Add Rust and install the latest
asdf plugin-add rust https://github.com/code-lever/asdf-rust.git
asdf install rust 1.57.0
