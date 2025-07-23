#!/usr/bin/env bash

# Zellijinator (Zellij Session Manager) aliases

# Short aliases for zellijinator
alias zel='zellijinator'
alias zm='zellijinator'

# Quick start aliases for common sessions
alias zrails='zellijinator start rails-dev'
alias znode='zellijinator start node-dev'
alias zdev='zellijinator start simple-dev'

# List available layouts
alias zlist='zellijinator list'

# List active sessions
alias zsessions='zellijinator sessions'

# Quick edit layout
alias zedit='zellijinator edit'

# Direct Zellij layout commands
alias zl='zellij --layout'

# Function to start Zellij with a layout in the current directory
zhere() {
    local layout="${1:-simple-dev}"
    local layout_file="${HOME}/.config/zellij/layouts/${layout}.kdl"
    
    if [[ ! -f "$layout_file" ]]; then
        echo "Layout '${layout}' not found. Available layouts:"
        zellijinator list
        return 1
    fi
    
    # Use current directory name as session name
    local session_name="$(basename "$PWD")-$(date +%H%M%S)"
    zellij --layout "$layout_file" --session "$session_name"
}

# Function to create a project-specific layout
zproject() {
    local project_name="${1:-$(basename "$PWD")}"
    local layout_file=".zellij-layout.kdl"
    
    if [[ -f "$layout_file" ]]; then
        echo "Starting Zellij with project layout..."
        zellij --layout "$layout_file" --session "$project_name"
    else
        echo "No .zellij-layout.kdl found in current directory."
        echo "Would you like to create one? (y/n)"
        read -r response
        if [[ "$response" == "y" ]]; then
            cp "${HOME}/.config/zellij/layouts/simple-dev.kdl" "$layout_file"
            echo "Created .zellij-layout.kdl - edit it to customize your project layout"
            ${EDITOR:-nvim} "$layout_file"
        fi
    fi
}