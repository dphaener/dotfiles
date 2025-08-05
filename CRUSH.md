# CRUSH.md - Dotfiles Repository Guide

## Build/Test/Lint Commands
- **Setup**: `./setup.sh` (full setup) or `./setup.sh --sync` (symlinks only)
- **Install packages**: `brew bundle` (install all Homebrew packages including Crush)
- **Shell check**: `shellcheck install/*.sh *.sh` (lint shell scripts)
- **Markdown lint**: `markdownlint-cli2 "**/*.md"` (lint markdown files)
- **Lua format**: `stylua nvim/` (format Neovim Lua configs)
- **Test setup**: `./setup.sh --reset-state && ./setup.sh` (clean test)

## Code Style Guidelines

### Shell Scripts (.sh)
- Use `#!/bin/bash` shebang
- Follow existing helper patterns from `install/helpers.sh`
- Use color constants: `RED`, `GREEN`, `YELLOW`, `BLUE`, `NC`
- Use logging functions: `info()`, `success()`, `warn()`, `error()`
- Make scripts idempotent with state tracking via `run_step()`
- Disable specific shellcheck rules in `.shellcheckrc` when needed
- Use `readonly` for constants, `local` for function variables

### Configuration Files
- **Lua** (Neovim): 2-space indentation, 120 char line width (stylua.toml)
- **Markdown**: 120 char line limit, allow HTML tags (markdownlint config)
- **Zsh**: Modular structure in `.zsh/` directory with topic-based files
- **Crush**: Configuration managed in `.config/crush/` with LSP settings

### File Organization
- Install scripts in `install/` directory with descriptive names
- Config files use dotfile convention (`.filename`)
- Neovim configs in `nvim/lua/` with plugin-based organization
- Shell aliases organized by topic in `.zsh/aliases/`
- Crush config and commands in `.config/crush/` (symlinked to `~/.config/crush/`)

### Error Handling
- Always use `set -e` in shell scripts for fail-fast behavior
- Use helper functions for common operations (symlinks, git clones)
- Backup existing files before overwriting
- Provide clear error messages with context