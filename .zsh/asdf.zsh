if [[ "$OSTYPE" == "darwin"* ]]; then
  . $(brew --prefix asdf)/libexec/asdf.sh
else
  . $HOME/.asdf/asdf.sh
fi
