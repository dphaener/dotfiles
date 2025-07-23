#!/bin/bash

# Install and configure shell (Zsh, Oh My Zsh, plugins)

set -e
source "$(dirname "$0")/helpers.sh"

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        info "Oh My Zsh already installed"
        # Update Oh My Zsh
        (
            cd "$HOME/.oh-my-zsh"
            git pull --ff-only 2>/dev/null || warn "Could not update Oh My Zsh"
        )
        return 0
    fi
    
    info "Installing Oh My Zsh..."
    
    # Download and run installer in unattended mode
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    success "Oh My Zsh installed"
}

install_zsh_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local target_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    
    safe_git_clone "$repo_url" "$target_dir"
}

install_zsh_plugins() {
    info "Installing Zsh plugins..."
    
    # Ensure Oh My Zsh is installed first
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        error "Oh My Zsh not installed"
        return 1
    fi
    
    # Install plugins
    install_zsh_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions"
    install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    
    success "Zsh plugins installed"
}

configure_shell() {
    info "Configuring shell..."
    
    # Set Zsh as default shell if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        if command_exists zsh; then
            local zsh_path
            zsh_path=$(which zsh)
            
            # Add zsh to /etc/shells if not already there
            if ! grep -q "^$zsh_path$" /etc/shells; then
                echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
            fi
            
            # Change default shell
            if is_macos; then
                chsh -s "$zsh_path"
            else
                sudo chsh -s "$zsh_path" "$USER"
            fi
            
            success "Changed default shell to Zsh"
        else
            error "Zsh not installed"
            return 1
        fi
    else
        info "Zsh is already the default shell"
    fi
}

main() {
    info "Setting up shell environment..."
    
    run_step "oh_my_zsh_install" "Installing Oh My Zsh" install_oh_my_zsh
    run_step "zsh_plugins_install" "Installing Zsh plugins" install_zsh_plugins
    run_step "shell_configure" "Configuring shell" configure_shell
    
    success "Shell setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi