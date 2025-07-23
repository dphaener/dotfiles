#!/bin/bash

# Main setup script for dotfiles
# This script orchestrates the installation of all dotfiles and tools
# It is designed to be idempotent - safe to run multiple times

set -e

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper functions
source "$SCRIPT_DIR/install/helpers.sh"

# Parse command line arguments
SKIP_PACKAGES=false
SKIP_SHELL=false
SKIP_SYMLINKS=false
SKIP_DEV=false
SYNC_ONLY=false

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Idempotent dotfiles setup script. Safe to run multiple times.

OPTIONS:
    -h, --help          Show this help message
    -s, --sync          Only update symlinks (useful for syncing after pulling changes)
    --skip-packages     Skip system package installation
    --skip-shell        Skip shell setup (Oh My Zsh, plugins)
    --skip-symlinks     Skip creating symlinks
    --skip-dev          Skip development tools setup
    --reset-state       Reset completion state (start fresh)

EXAMPLES:
    # Full installation
    ./setup.sh

    # Only update symlinks after pulling latest changes
    ./setup.sh --sync

    # Skip package installation (useful in containers)
    ./setup.sh --skip-packages

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -s|--sync)
                SYNC_ONLY=true
                shift
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            --skip-shell)
                SKIP_SHELL=true
                shift
                ;;
            --skip-symlinks)
                SKIP_SYMLINKS=true
                shift
                ;;
            --skip-dev)
                SKIP_DEV=true
                shift
                ;;
            --reset-state)
                rm -rf "$STATE_DIR"
                success "Reset completion state"
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

setup_logging() {
    # Create log directory
    local log_dir="$HOME/.dotfiles-logs"
    mkdir -p "$log_dir"
    
    # Set up logging
    local log_file="$log_dir/setup-$(date +%Y%m%d-%H%M%S).log"
    
    # Redirect all output to log file while still showing on screen
    exec > >(tee -a "$log_file")
    exec 2>&1
    
    info "Logging to: $log_file"
}

verify_prerequisites() {
    info "Verifying prerequisites..."
    
    # Check for required commands
    local required_commands=(git curl)
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            error "Required command not found: $cmd"
            exit 1
        fi
    done
    
    # Check if we're in the dotfiles directory
    if [[ ! -f "$SCRIPT_DIR/setup.sh" ]]; then
        error "This script must be run from the dotfiles directory"
        exit 1
    fi
    
    success "Prerequisites verified"
}

run_installers() {
    info "Running installers..."
    
    # Make all install scripts executable
    chmod +x "$SCRIPT_DIR/install"/*.sh
    
    if [[ "$SYNC_ONLY" == "true" ]]; then
        info "Sync mode: Only updating symlinks"
        "$SCRIPT_DIR/install/symlinks.sh"
        return 0
    fi
    
    # Run installers in order
    if [[ "$SKIP_PACKAGES" != "true" ]]; then
        "$SCRIPT_DIR/install/packages.sh"
        
        # Run Homebrew installer on macOS
        if is_macos; then
            "$SCRIPT_DIR/install/homebrew.sh"
        fi
    fi
    
    if [[ "$SKIP_SHELL" != "true" ]]; then
        "$SCRIPT_DIR/install/shell.sh"
    fi
    
    if [[ "$SKIP_SYMLINKS" != "true" ]]; then
        "$SCRIPT_DIR/install/symlinks.sh"
    fi
    
    if [[ "$SKIP_DEV" != "true" ]]; then
        "$SCRIPT_DIR/install/development.sh"
    fi
}

show_post_install_message() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    Dotfiles Setup Complete! 🎉                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    if [[ "$SYNC_ONLY" != "true" ]]; then
        echo -e "${YELLOW}Next steps:${NC}"
        echo "  1. Restart your terminal or run: source ~/.zshrc"
        echo "  2. Authenticate with Graphite: gt auth --token <your_cli_auth_token>"
        
        if is_macos; then
            echo "  3. Open HammerSpoon and enable accessibility permissions"
        fi
        
        echo
        echo -e "${BLUE}To sync dotfiles on another machine:${NC}"
        echo "  1. Pull latest changes: git pull"
        echo "  2. Run sync: ./setup.sh --sync"
    else
        echo -e "${GREEN}✓ Dotfiles synced successfully${NC}"
    fi
    
    echo
    echo -e "${CYAN}State directory: $STATE_DIR${NC}"
    echo -e "${CYAN}View logs in: $HOME/.dotfiles-logs/${NC}"
    echo
}

main() {
    parse_args "$@"
    
    # Header
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                     Dotfiles Setup Script                          ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    setup_logging
    verify_prerequisites
    run_installers
    show_post_install_message
}

# Run main function
main "$@"