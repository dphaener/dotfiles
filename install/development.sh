#!/bin/bash

# Install development tools (ASDF, Ruby, Node.js, etc.)

set -e
source "$(dirname "$0")/helpers.sh"

# Helper function to source ASDF based on installation method
source_asdf() {
    if is_macos && command_exists brew; then
        local brew_prefix
        brew_prefix=$(brew --prefix)
        . "$brew_prefix/opt/asdf/libexec/asdf.sh"
    else
        . "$HOME/.asdf/asdf.sh"
    fi
}

install_asdf() {
    if command_exists asdf; then
        info "ASDF already installed"
        return 0
    fi
    
    info "Installing ASDF..."
    
    if is_macos; then
        # Install via Homebrew on macOS
        if ! command_exists brew; then
            error "Homebrew is required to install ASDF on macOS"
            return 1
        fi
        
        # Install dependencies
        brew_install "coreutils"
        brew_install "git"
        brew_install "bash"
        
        # Install ASDF
        brew_install "asdf"
        
        # Add to shell config if not already there
        local brew_prefix
        brew_prefix=$(brew --prefix)
        append_if_missing ". $brew_prefix/opt/asdf/libexec/asdf.sh" "$HOME/.zshrc"
        
        # Source for current session
        . "$brew_prefix/opt/asdf/libexec/asdf.sh"
        
    elif is_linux; then
        # For Linux, we'll use the official download method
        # First ensure dependencies are installed
        package_install "curl"
        package_install "git"
        package_install "bash"
        
        # Download and install ASDF
        local asdf_version="0.18.0"
        local temp_dir
        temp_dir=$(mktemp -d)
        
        info "Downloading ASDF v$asdf_version..."
        curl -L "https://github.com/asdf-vm/asdf/archive/v${asdf_version}.tar.gz" -o "$temp_dir/asdf.tar.gz"
        
        # Extract to home directory
        mkdir -p "$HOME/.asdf"
        tar -xzf "$temp_dir/asdf.tar.gz" -C "$HOME/.asdf" --strip-components=1
        
        rm -rf "$temp_dir"
        
        # Add to shell config if not already there
        append_if_missing ". $HOME/.asdf/asdf.sh" "$HOME/.zshrc"
        append_if_missing ". $HOME/.asdf/completions/asdf.bash" "$HOME/.zshrc"
        
        # Source for current session
        . "$HOME/.asdf/asdf.sh"
    else
        error "Unsupported operating system for ASDF installation"
        return 1
    fi
    
    success "ASDF installed"
}

configure_asdf_plugins() {
    info "Configuring ASDF plugins..."
    
    # Source ASDF
    source_asdf
    
    # Add Ruby plugin
    asdf_plugin_add "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
    
    # Add Node.js plugin
    asdf_plugin_add "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
    
    # Import Node.js release team keyring
    if [[ -x "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring" ]]; then
        info "Importing Node.js release team keyring..."
        bash -c "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring" 2>/dev/null || \
            warn "Could not import Node.js keyring"
    fi
    
    success "ASDF plugins configured"
}

install_tool_versions() {
    info "Installing tool versions from .tool-versions..."
    
    # Source ASDF
    source_asdf
    
    # Change to dotfiles directory to use .tool-versions
    (
        cd "$DOTFILES_DIR"
        
        # Install all tools specified in .tool-versions
        if [[ -f ".tool-versions" ]]; then
            asdf install
        else
            warn ".tool-versions file not found"
        fi
    )
    
    success "Tool versions installed"
}

install_ruby_gems() {
    info "Installing essential Ruby gems..."
    
    # Source ASDF
    source_asdf
    
    # Install gems
    gem_install "bundler"
    gem_install "rails"
    gem_install "neovim"
    
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
    
    # Build Tmux from source
    if [[ -x "$DOTFILES_DIR/build_tmux.sh" ]]; then
        run_step "build_tmux" "Building Tmux from source" "$DOTFILES_DIR/build_tmux.sh"
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
    
    # Install ASDF and languages
    run_step "asdf_install" "Installing ASDF" install_asdf
    run_step "asdf_plugins" "Configuring ASDF plugins" configure_asdf_plugins
    run_step "tool_versions" "Installing tool versions" install_tool_versions
    run_step "ruby_gems" "Installing Ruby gems" install_ruby_gems
    
    success "Development tools setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi