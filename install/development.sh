#!/bin/bash

# Install development tools (mise, Ruby, Node.js, etc.)

set -e
source "$(dirname "$0")/helpers.sh"

# Helper function to put mise and its shims on PATH for this script
setup_mise_path() {
    export PATH="$HOME/.local/bin:${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"
}

install_mise() {
    setup_mise_path

    if command_exists mise; then
        info "mise already installed"
        return 0
    fi
    
    info "Installing mise..."
    
    if is_macos; then
        # Install via Homebrew on macOS
        if ! command_exists brew; then
            error "Homebrew is required to install mise on macOS"
            return 1
        fi
        
        brew_install "mise"
        
    elif is_linux; then
        package_install "curl"

        # Official installer drops the binary in ~/.local/bin
        curl -fsSL https://mise.run | sh
    else
        error "Unsupported operating system for mise installation"
        return 1
    fi
    
    success "mise installed"
}

install_tool_versions() {
    info "Installing tool versions from ~/.config/mise/config.toml..."

    setup_mise_path
    
    # Run from $HOME so only the global config is resolved
    (
        cd "$HOME"
        mise install
    )
    
    success "Tool versions installed"
}

install_ruby_gems() {
    info "Installing essential Ruby gems..."

    setup_mise_path
    
    # Install gems
    gem_install "bundler"
    gem_install "rails"
    gem_install "neovim"
    gem_install "ruby-lsp"
    
    success "Ruby gems installed"
}

install_linux_packages() {
    if ! is_linux; then
        return 0
    fi
    
    info "Installing Linux development packages..."
    
    local packages=(
        libcurl4-openssl-dev
        libexpat1-dev
        gettext
        libz-dev
        libssl-dev
        build-essential
        autoconf
        automake
        pkg-config
        libevent-dev
        libncurses5-dev
        ninja-build
        libtool
        libtool-bin
        cmake
        g++
        unzip
        snapd
        ripgrep
        curl
        bison
        libreadline-dev
        libyaml-dev
        libffi-dev
        libgmp-dev
        libsqlite3-dev
        zlib1g-dev
        pdftk
        fd-find
        fzf
        xclip
    )
    
    # Update package list
    sudo apt update -y
    
    # Install packages
    for package in "${packages[@]}"; do
        package_install "$package"
    done
    
    success "Linux development packages installed"
}

build_from_source() {
    if ! is_linux; then
        return 0
    fi
    
    info "Building tools from source..."
    
    # Build Git from source
    if [[ -x "$DOTFILES_DIR/build_git.sh" ]]; then
        run_step "build_git" "Building Git from source" "$DOTFILES_DIR/build_git.sh"
    fi
    
    # Build Neovim from source
    if [[ -x "$DOTFILES_DIR/build_nvim.sh" ]]; then
        run_step "build_nvim" "Building Neovim from source" "$DOTFILES_DIR/build_nvim.sh"
    fi
    
    
    success "Source builds complete"
}

main() {
    info "Setting up development tools..."
    
    # Install platform-specific packages first
    if is_linux; then
        run_step "linux_packages" "Installing Linux packages" install_linux_packages
        run_step "build_from_source" "Building tools from source" build_from_source
    fi
    
    # Install mise and languages
    run_step "mise_install" "Installing mise" install_mise
    run_step "tool_versions" "Installing tool versions" install_tool_versions
    run_step "ruby_gems" "Installing Ruby gems" install_ruby_gems
    
    success "Development tools setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
