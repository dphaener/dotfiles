#!/bin/bash

# Create symlinks for all dotfiles

set -e
source "$(dirname "$0")/helpers.sh"

create_config_symlinks() {
    info "Creating configuration symlinks..."
    
    # Zsh configurations
    safe_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    safe_link "$DOTFILES_DIR/.zshrc_user_default" "$HOME/.zshrc_user_default"
    if is_linux; then
        safe_link "$DOTFILES_DIR/.zshrc_linux_root" "$HOME/.zshrc_linux_root"
    fi
    
    # Git configurations
    safe_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    safe_link "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
    
    # Zellij configuration
    ensure_dir "$HOME/.config/zellij"
    safe_link "$DOTFILES_DIR/.config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
    ensure_dir "$HOME/.config/zellij/layouts"
    safe_link "$DOTFILES_DIR/.config/zellij/layouts" "$HOME/.config/zellij/layouts"
    
    # ASDF configuration
    safe_link "$DOTFILES_DIR/.asdfrc" "$HOME/.asdfrc"
    safe_link "$DOTFILES_DIR/.tool-versions" "$HOME/.tool-versions"
    
    # Ruby configuration
    safe_link "$DOTFILES_DIR/.gemrc" "$HOME/.gemrc"
    
    # Linting configurations
    safe_link "$DOTFILES_DIR/.markdownlint-cli2.yaml" "$HOME/.markdownlint-cli2.yaml"
    safe_link "$DOTFILES_DIR/.shellcheckrc" "$HOME/.shellcheckrc"
    
    # SSH configuration
    ensure_dir "$HOME/.ssh"
    safe_link "$DOTFILES_DIR/.ssh/rc" "$HOME/.ssh/rc"
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/rc" 2>/dev/null || true
    
    success "Configuration symlinks created"
}

create_config_directory_symlinks() {
    info "Creating config directory symlinks..."
    
    ensure_dir "$HOME/.config"
    
    # Neovim configuration
    safe_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    
    # Starship configuration
    safe_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
    
    # Ghostty configuration
    ensure_dir "$HOME/.config/ghostty"
    safe_link "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
    
    # Claude configuration
    safe_link "$DOTFILES_DIR/CLAUDE.md" "$HOME/.config/CLAUDE.md"
    safe_link "$DOTFILES_DIR/.claude" "$HOME/.claude"
    
    success "Config directory symlinks created"
}

create_bin_symlinks() {
    info "Creating bin directory symlinks..."
    
    ensure_dir "$HOME/bin"
    
    # Link all executable scripts from bin directory
    for script in "$DOTFILES_DIR/bin"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            local script_name
            script_name=$(basename "$script")
            safe_link "$script" "$HOME/bin/$script_name"
        fi
    done
    
    success "Bin directory symlinks created"
}

create_platform_specific_symlinks() {
    if is_macos; then
        info "Creating macOS-specific symlinks..."
        
        # HammerSpoon configuration
        ensure_dir "$HOME/.hammerspoon"
        safe_link "$DOTFILES_DIR/hammerspoon_init.lua" "$HOME/.hammerspoon/init.lua"
        
        # Utils for HammerSpoon
        ensure_dir "$HOME/.local/share"
        safe_link "$DOTFILES_DIR/utils" "$HOME/.local/share/utils"
        
        success "macOS-specific symlinks created"
    fi
}

main() {
    info "Creating dotfile symlinks..."
    
    run_step "config_symlinks" "Creating configuration symlinks" create_config_symlinks
    run_step "config_dir_symlinks" "Creating config directory symlinks" create_config_directory_symlinks
    run_step "bin_symlinks" "Creating bin symlinks" create_bin_symlinks
    run_step "platform_symlinks" "Creating platform-specific symlinks" create_platform_specific_symlinks
    
    success "Symlinks setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi