# ASDF configuration
# Handle both Homebrew and manual installations

if [[ "$OSTYPE" == "darwin"* ]] && command -v brew >/dev/null 2>&1; then
    # macOS with Homebrew
    BREW_PREFIX=$(brew --prefix)
    if [[ -f "$BREW_PREFIX/opt/asdf/libexec/asdf.sh" ]]; then
        . "$BREW_PREFIX/opt/asdf/libexec/asdf.sh"
        # Homebrew manages completions automatically
    fi
elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    # Manual installation
    export ASDF_DATA_DIR="$HOME/.asdf"
    . "$HOME/.asdf/asdf.sh"
    
    # append completions to fpath
    fpath=(${ASDF_DATA_DIR}/completions $fpath)
    
    # initialise completions with ZSH's compinit
    autoload -Uz compinit && compinit
fi
