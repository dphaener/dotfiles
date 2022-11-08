export EDITOR="vim"
export REACT_EDITOR=vim
export GPG_TTY=$(tty)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#c0c0c0,bg=#444444,underline"

# FermentAble
export FERMENTABLE_HOST=http://dev.getfermentable.com:3000
export REACT_NATIVE_FERMENTABLE_BASE_URL=http://dev.getfermentable.com:3000
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$HOME/Library/Android/sdk/platform-tools:$PATH

if test -f "$HOME/env.zsh"; then
  source "$HOME/env.zsh"
fi
