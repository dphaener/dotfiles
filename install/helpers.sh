#!/bin/bash

# Helper functions for idempotent dotfiles installation
# This file provides common functions used across all install scripts

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly NC='\033[0m' # No Color

# Dotfiles directory
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly STATE_DIR="$HOME/.dotfiles-state"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running on macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Check if running on Linux
is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

# Mark a step as completed
mark_completed() {
    local step="$1"
    touch "$STATE_DIR/$step"
    success "Completed: $step"
}

# Check if a step has been completed
is_completed() {
    local step="$1"
    [[ -f "$STATE_DIR/$step" ]]
}

# Run a step if not already completed
run_step() {
    local step_name="$1"
    local step_description="$2"
    shift 2
    
    if is_completed "$step_name"; then
        info "Skipping: $step_description (already completed)"
        return 0
    fi
    
    info "Running: $step_description"
    if "$@"; then
        mark_completed "$step_name"
        return 0
    else
        error "Failed: $step_description"
        return 1
    fi
}

# Create a symlink safely
safe_link() {
    local src="$1"
    local target="$2"
    
    # Expand tilde in paths
    src="${src/#\~/$HOME}"
    target="${target/#\~/$HOME}"
    
    # Check if source exists
    if [[ ! -e "$src" ]]; then
        error "Source does not exist: $src"
        return 1
    fi
    
    # If target is already correctly linked, skip
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$src" ]]; then
        success "Already linked: $target → $src"
        return 0
    fi
    
    # Backup existing file if it exists and is not a symlink
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        warn "Backing up existing file: $target → $backup"
        mv "$target" "$backup"
    fi
    
    # Create parent directory if needed
    local target_dir
    target_dir=$(dirname "$target")
    mkdir -p "$target_dir"
    
    # Create the symlink
    ln -sf "$src" "$target"
    success "Linked: $target → $src"
}

# Append a line to a file if it doesn't already exist
append_if_missing() {
    local line="$1"
    local file="$2"
    
    # Expand tilde in file path
    file="${file/#\~/$HOME}"
    
    # Create file if it doesn't exist
    if [[ ! -f "$file" ]]; then
        echo "$line" > "$file"
        success "Created $file with: $line"
        return 0
    fi
    
    # Check if line already exists
    if grep -qxF "$line" "$file" 2>/dev/null; then
        info "Line already exists in $file: $line"
        return 0
    fi
    
    # Append the line
    echo "$line" >> "$file"
    success "Appended to $file: $line"
}

# Clone or update a git repository
safe_git_clone() {
    local repo_url="$1"
    local target_dir="$2"
    
    # Expand tilde in target path
    target_dir="${target_dir/#\~/$HOME}"
    
    if [[ -d "$target_dir/.git" ]]; then
        info "Repository already exists: $target_dir"
        info "Updating repository..."
        (
            cd "$target_dir" || return 1
            git pull --ff-only 2>/dev/null || {
                warn "Could not fast-forward, repository may have local changes"
            }
        )
        return 0
    fi
    
    # Clone the repository
    if git clone "$repo_url" "$target_dir"; then
        success "Cloned repository: $repo_url → $target_dir"
        return 0
    else
        error "Failed to clone repository: $repo_url"
        return 1
    fi
}

# Install a Homebrew package if not already installed (macOS only)
brew_install() {
    local package="$1"
    
    if ! is_macos; then
        error "brew_install called on non-macOS system"
        return 1
    fi
    
    if brew list "$package" &>/dev/null; then
        info "Already installed: $package"
        return 0
    fi
    
    info "Installing: $package"
    if brew install "$package"; then
        success "Installed: $package"
        return 0
    else
        error "Failed to install: $package"
        return 1
    fi
}

# Install a package using the system package manager
package_install() {
    local package="$1"
    
    if is_macos; then
        brew_install "$package"
    elif is_linux; then
        if command_exists apt-get; then
            if dpkg -l "$package" &>/dev/null; then
                info "Already installed: $package"
                return 0
            fi
            info "Installing: $package"
            sudo apt-get install -y "$package"
        elif command_exists yum; then
            if rpm -q "$package" &>/dev/null; then
                info "Already installed: $package"
                return 0
            fi
            info "Installing: $package"
            sudo yum install -y "$package"
        else
            error "No supported package manager found"
            return 1
        fi
    else
        error "Unsupported operating system"
        return 1
    fi
}

# Add an ASDF plugin if not already added
asdf_plugin_add() {
    local plugin="$1"
    local url="${2:-}"
    
    if asdf plugin list | grep -q "^$plugin\$"; then
        info "ASDF plugin already added: $plugin"
        return 0
    fi
    
    info "Adding ASDF plugin: $plugin"
    if [[ -n "$url" ]]; then
        asdf plugin add "$plugin" "$url"
    else
        asdf plugin add "$plugin"
    fi
    success "Added ASDF plugin: $plugin"
}

# Install a Ruby gem if not already installed
gem_install() {
    local gem="$1"
    
    if gem list -i "^$gem\$" &>/dev/null; then
        info "Gem already installed: $gem"
        return 0
    fi
    
    info "Installing gem: $gem"
    if gem install "$gem"; then
        success "Installed gem: $gem"
        return 0
    else
        error "Failed to install gem: $gem"
        return 1
    fi
}

# Ensure a directory exists
ensure_dir() {
    local dir="$1"
    
    # Expand tilde in path
    dir="${dir/#\~/$HOME}"
    
    if [[ -d "$dir" ]]; then
        return 0
    fi
    
    mkdir -p "$dir"
    success "Created directory: $dir"
}

# Add or update sudoers entry safely
safe_sudoers_add() {
    local user="$1"
    local rule="$2"
    local sudoers_file="/etc/sudoers.d/dotfiles-$user"
    
    # Check if rule already exists
    if sudo grep -q "^$user $rule" /etc/sudoers.d/* 2>/dev/null; then
        info "Sudoers rule already exists for $user"
        return 0
    fi
    
    # Create temporary file
    local temp_file
    temp_file=$(mktemp)
    echo "$user $rule" > "$temp_file"
    
    # Validate the file
    if sudo visudo -c -f "$temp_file" &>/dev/null; then
        sudo cp "$temp_file" "$sudoers_file"
        sudo chmod 440 "$sudoers_file"
        rm -f "$temp_file"
        success "Added sudoers rule for $user"
        return 0
    else
        rm -f "$temp_file"
        error "Invalid sudoers rule"
        return 1
    fi
}