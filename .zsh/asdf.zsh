# ASDF configuration
# Add ASDF bin and shims to PATH
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Set up completions
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit
