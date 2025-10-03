#!/bin/bash

# Install development tools (ASDF, Ruby, Node.js, etc.)

set -e
source "$(dirname "$0")/helpers.sh"

# Helper function to set up ASDF PATH
setup_asdf_path() {
    export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
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
        
        # Set up PATH for current session
        setup_asdf_path
        
    elif is_linux; then
        # For Linux, we'll use the official download method
        # First ensure dependencies are installed
        package_install "curl"
        package_install "git"
        package_install "bash"
        
        # Download pre-compiled binary
        local asdf_version="0.18.0"
        local arch=""
        case "$(uname -m)" in
            x86_64)
                arch="amd64"
                ;;
            arm64|aarch64)
                arch="arm64"
                ;;
            *)
                error "Unsupported architecture: $(uname -m)"
                return 1
                ;;
        esac

        local temp_dir
        temp_dir=$(mktemp -d)

        info "Downloading ASDF v$asdf_version..."
        curl -L "https://github.com/asdf-vm/asdf/releases/download/v${asdf_version}/asdf_${asdf_version}_linux_${arch}.tar.gz" -o "$temp_dir/asdf.tar.gz"

        # Extract to temporary directory first
        tar -xzf "$temp_dir/asdf.tar.gz" -C "$temp_dir"

        # Create directory structure and move binary
        mkdir -p "$HOME/.asdf/bin"
        mv "$temp_dir/asdf" "$HOME/.asdf/bin/asdf"
        chmod +x "$HOME/.asdf/bin/asdf"

        rm -rf "$temp_dir"

        # Set up completions
        mkdir -p "$HOME/.asdf/completions"
        "$HOME/.asdf/bin/asdf" completion zsh > "$HOME/.asdf/completions/_asdf"

        # Set up PATH for current session
        export PATH="$HOME/.asdf/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
    else
        error "Unsupported operating system for ASDF installation"
        return 1
    fi
    
    success "ASDF installed"
}

configure_asdf_plugins() {
    info "Configuring ASDF plugins..."

    # Set up ASDF PATH
    setup_asdf_path
    
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

    # Set up ASDF PATH
    setup_asdf_path
    
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

    # Set up ASDF PATH
    setup_asdf_path
    
    # Install gems
    gem_install "bundler"
    gem_install "rails"
    gem_install "neovim"
    
    success "Ruby gems installed"
}

install_zellijinator() {
    info "Installing zellijinator..."
    
    if command_exists zellijinator; then
        info "zellijinator already installed"
        return 0
    fi
    
    # Determine the architecture
    local arch=""
    case "$(uname -m)" in
        x86_64)
            arch="amd64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac
    
    # Determine the OS
    local os=""
    if is_macos; then
        os="darwin"
    elif is_linux; then
        os="linux"
    else
        error "Unsupported operating system"
        return 1
    fi
    
    # Get latest release URL
    local download_url
    download_url=$(curl -s https://api.github.com/repos/dphaener/zellijinator/releases/latest | \
        grep "browser_download_url.*${os}.*${arch}" | \
        cut -d '"' -f 4)
    
    if [[ -z "$download_url" ]]; then
        error "Could not find download URL for zellijinator"
        return 1
    fi
    
    # Download and install
    local temp_file
    temp_file=$(mktemp)
    
    info "Downloading zellijinator from $download_url..."
    if curl -L "$download_url" -o "$temp_file"; then
        chmod +x "$temp_file"
        sudo mv "$temp_file" /usr/local/bin/zellijinator
        success "zellijinator installed to /usr/local/bin/zellijinator"
    else
        error "Failed to download zellijinator"
        rm -f "$temp_file"
        return 1
    fi
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
    
    # Install zellijinator
    run_step "zellijinator" "Installing zellijinator" install_zellijinator
    
    success "Development tools setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi