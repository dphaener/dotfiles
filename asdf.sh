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
asdf install ruby 3.2.2
asdf install ruby 2.7.8

# Add the nodejs plugin and install the latest
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
asdf install nodejs 20.9.0
