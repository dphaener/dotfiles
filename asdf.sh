git clone https://github.com/asdf-vm/asdf.git "$HOME"/.asdf
cd ~/.asdf || exit 1
git checkout "$(git describe --abbrev=0 --tags)"

. "$HOME/.asdf/asdf.sh"

# Add the Ruby plugin and install the latest
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.3.4

# Add the nodejs plugin and install the latest
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
asdf install nodejs 20.11.0
