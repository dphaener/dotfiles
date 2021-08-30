if [[ "$OSTYPE" == "darwin"* ]]; then
  . $(brew --prefix asdf)/asdf.sh
else
  . $HOME/.asdf/asdf.sh
fi
