#!/bin/bash

# Install system packages

set -e
source "$(dirname "$0")/helpers.sh"

configure_macos_settings() {
    if ! is_macos; then
        return 0
    fi
    
    info "Configuring macOS settings..."
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -boolean true
    killall Finder 2>/dev/null || true
    
    success "macOS settings configured"
}

setup_sudo_privileges() {
    info "Configuring sudo privileges..."
    
    # Only add NOPASSWD rule if not already present
    local user
    user=$(whoami)
    
    # Use the safe sudoers function from helpers
    safe_sudoers_add "$user" "ALL=(ALL) NOPASSWD:ALL"
    
    success "Sudo privileges configured"
}

main() {
    info "Setting up system packages and configurations..."
    
    # Platform-specific setup
    if is_macos; then
        run_step "macos_settings" "Configuring macOS settings" configure_macos_settings
        # Homebrew packages are handled in homebrew.sh
    else
        # Linux packages are handled in development.sh
        run_step "sudo_privileges" "Setting up sudo privileges" setup_sudo_privileges
    fi
    
    success "System package setup complete"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi