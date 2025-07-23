#!/bin/bash

# Install and configure Homebrew (macOS only)

set -e
source "$(dirname "$0")/helpers.sh"

install_homebrew() {
    if ! is_macos; then
        info "Skipping Homebrew installation (not on macOS)"
        return 0
    fi
    
    if command_exists brew; then
        info "Homebrew already installed"
        return 0
    fi
    
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        append_if_missing 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    success "Homebrew installed successfully"
}

install_brewfile_packages() {
    if ! is_macos; then
        return 0
    fi
    
    if ! command_exists brew; then
        error "Homebrew not installed"
        return 1
    fi
    
    local brewfile="$DOTFILES_DIR/Brewfile"
    if [[ ! -f "$brewfile" ]]; then
        warn "Brewfile not found at $brewfile"
        return 0
    fi
    
    info "Installing packages from Brewfile..."
    (
        cd "$DOTFILES_DIR"
        brew bundle
    )
    
    # Fix chromedriver quarantine if it exists
    if command_exists chromedriver; then
        xattr -d com.apple.quarantine "$(which chromedriver)" 2>/dev/null || true
    fi
    
    success "Brewfile packages installed"
}

main() {
    info "Setting up Homebrew..."
    
    run_step "homebrew_install" "Installing Homebrew" install_homebrew
    run_step "brewfile_install" "Installing Brewfile packages" install_brewfile_packages
    
    success "Homebrew setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi