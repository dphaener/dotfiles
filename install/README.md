# Dotfiles Installation System

This directory contains the modular, idempotent installation system for dotfiles.

## Architecture

The installation system is designed with the following principles:

1. **Idempotency**: Every script can be run multiple times safely
2. **Modularity**: Each concern is separated into its own script
3. **State Tracking**: Completed steps are tracked in `~/.dotfiles-state`
4. **Cross-Platform**: Works on both macOS and Linux
5. **Error Handling**: Proper error messages and logging

## Scripts

### Core Files

- **`helpers.sh`** - Common functions used by all installers:
  - Logging functions (info, success, warn, error)
  - Platform detection (is_macos, is_linux)
  - Safe operations (safe_link, safe_git_clone, append_if_missing)
  - State management (mark_completed, is_completed, run_step)
  - Package management helpers

### Installation Modules

- **`homebrew.sh`** - macOS Homebrew setup:
  - Installs Homebrew if not present
  - Installs packages from Brewfile
  - Updates existing Homebrew installation

- **`shell.sh`** - Shell environment setup:
  - Installs Oh My Zsh
  - Installs Zsh plugins (completions, syntax highlighting, autosuggestions)
  - Sets Zsh as default shell
  - Updates existing installations

- **`symlinks.sh`** - Creates all dotfile symlinks:
  - Configuration files (.zshrc, .gitconfig, etc.)
  - Config directory items (nvim, starship, etc.)
  - Binary scripts (~/bin)
  - Platform-specific configs (HammerSpoon on macOS)

- **`development.sh`** - Development tools setup:
  - ASDF version manager
  - Ruby and Node.js via ASDF
  - Essential Ruby gems
  - Fastmod (if Rust is available)
  - Linux: build tools and compilation from source

- **`packages.sh`** - System package installation:
  - macOS system settings
  - Linux sudo configuration

## Usage

### Full Installation

```bash
# Run from dotfiles directory
./setup.sh
```

### Sync After Updates

```bash
# Pull latest changes
git pull

# Only update symlinks
./setup.sh --sync
```

### Partial Installation

```bash
# Skip specific components
./setup.sh --skip-packages  # Skip system packages
./setup.sh --skip-shell     # Skip shell setup
./setup.sh --skip-dev       # Skip development tools

# Run individual installers
./install/symlinks.sh       # Just create/update symlinks
./install/shell.sh          # Just setup shell environment
```

### Reset and Reinstall

```bash
# Clear all completion markers and start fresh
./setup.sh --reset-state

# Then run setup normally
./setup.sh
```

## State Management

The system tracks completed installation steps in `~/.dotfiles-state/`:

```bash
# View completed steps
ls ~/.dotfiles-state/

# Manually mark a step as completed
touch ~/.dotfiles-state/step_name

# Remove a completion marker to re-run a step
rm ~/.dotfiles-state/step_name
```

## Logging

All installation runs are logged to `~/.dotfiles-logs/`:

```bash
# View latest log
ls -la ~/.dotfiles-logs/
tail -f ~/.dotfiles-logs/setup-*.log
```

## Adding New Installation Steps

To add a new installation step:

1. Add a function to the appropriate installer script
2. Use `run_step` to make it idempotent:

```bash
install_my_tool() {
    # Installation logic here
    return 0  # Return 0 on success
}

# In main()
run_step "my_tool_install" "Installing my tool" install_my_tool
```

3. The step will automatically be tracked and skipped if already completed

## Troubleshooting

### Installation Fails

1. Check the log file in `~/.dotfiles-logs/`
2. Fix the issue
3. Re-run setup (it will skip completed steps)

### Need to Re-run a Step

```bash
# Remove the completion marker
rm ~/.dotfiles-state/step_name

# Re-run setup
./setup.sh
```

### Complete Reset

```bash
# Remove all state
rm -rf ~/.dotfiles-state

# Remove all symlinks (careful!)
# ... manually remove symlinks ...

# Start fresh
./setup.sh
```