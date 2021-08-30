if [ -d "$HOME/bin" ]; then
  PATH="$PATH:$HOME/bin"
fi

if [ -d "/usr/local/bin/nvim/bin" ]; then
  PATH="$PATH:/usr/local/bin/nvim/bin"
fi

if [ -d "$HOME/.local/bin" ]; then
  PATH="$PATH:$HOME/.local/bin"
fi

if [ -d "/usr/local/bin" ]; then
  PATH="$PATH:/usr/local/bin"
fi

if [ -d "/usr/local/sbin" ]; then
  PATH="$PATH:/usr/local/sbin"
fi

if [ -d "$HOME/Library/Python/2.7/bin" ]; then
  PATH="$PATH:$HOME/Library/Python/2.7/bin"
fi

if [ -d "/usr/bin" ]; then
  PATH="$PATH:/usr/bin"
fi
