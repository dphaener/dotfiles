#!/usr/bin/env bash

# Zellij Session Manager aliases

# Short alias for zellij-manager
alias zm='zellij-manager'

# Quick start aliases for common sessions
alias zrails='zellij-manager start rails-dev'
alias znode='zellij-manager start node-dev'
alias zdev='zellij-manager start simple-dev'

# List available layouts
alias zlist='zellij-manager list'

# List active sessions
alias zsessions='zellij-manager sessions'

# Quick edit layout
alias zedit='zellij-manager edit'

# Direct Zellij layout commands
alias zl='zellij --layout'

# Function to start Zellij with a layout in the current directory
zhere() {
    local layout="${1:-simple-dev}"
    local layout_file="${HOME}/.config/zellij/layouts/${layout}.kdl"
    
    if [[ ! -f "$layout_file" ]]; then
        echo "Layout '${layout}' not found. Available layouts:"
        zellij-manager list
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

# Proxy management aliases

# Monitor proxy in Zellij
alias zproxy='zellij-manager start proxy-monitor'

# Start proxy service
alias proxy-start='launchctl load ~/Library/LaunchAgents/com.user.on-proxy.plist'

# Stop proxy service
alias proxy-stop='launchctl unload ~/Library/LaunchAgents/com.user.on-proxy.plist'

# Restart proxy service
alias proxy-restart='proxy-stop && sleep 2 && proxy-start'

# Check proxy status
alias proxy-status='launchctl list | grep com.user.on-proxy'

# View proxy logs
alias proxy-logs='tail -f ~/.local/log/on-proxy.log'
alias proxy-errors='tail -f ~/.local/log/on-proxy.error.log'

# Enable daily restart
alias proxy-enable-restart='launchctl load ~/Library/LaunchAgents/com.user.on-proxy-restart.plist'

# Disable daily restart
alias proxy-disable-restart='launchctl unload ~/Library/LaunchAgents/com.user.on-proxy-restart.plist'