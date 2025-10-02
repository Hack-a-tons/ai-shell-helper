#!/usr/bin/env bash

# Get the absolute path to the 'a' script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "AI Shell Helper Setup"
echo "Available aliases: 'pls' and 'please'"
echo ""

# Determine shell config file
if [[ "$SHELL" == *"zsh"* ]]; then
    CONFIG_FILE="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    CONFIG_FILE="$HOME/.bashrc"
else
    CONFIG_FILE="$HOME/.profile"
fi

# Check if aliases already exist
PLS_EXISTS=$(grep -q "alias pls=" "$CONFIG_FILE" 2>/dev/null && echo "yes" || echo "no")
PLEASE_EXISTS=$(grep -q "alias please=" "$CONFIG_FILE" 2>/dev/null && echo "yes" || echo "no")

if [[ "$PLS_EXISTS" == "yes" && "$PLEASE_EXISTS" == "yes" ]]; then
    echo "Both aliases already exist in $CONFIG_FILE"
    echo "You can use 'pls' and 'please' commands right away!"
    echo "If they're not working, run: source $CONFIG_FILE"
    exit 0
fi

read -p "Add aliases permanently to your shell config? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Add aliases if they don't exist
    if [[ "$PLS_EXISTS" == "no" ]]; then
        echo "alias pls='$SCRIPT_DIR/a'" >> "$CONFIG_FILE"
        echo "Added 'pls' alias to $CONFIG_FILE"
    else
        echo "'pls' alias already exists"
    fi
    
    if [[ "$PLEASE_EXISTS" == "no" ]]; then
        echo "alias please='$SCRIPT_DIR/a'" >> "$CONFIG_FILE"
        echo "Added 'please' alias to $CONFIG_FILE"
    else
        echo "'please' alias already exists"
    fi
    
    echo "Setup complete! Restart your terminal or run 'source $CONFIG_FILE' to use the aliases."
else
    echo "Manual setup - copy and paste these commands:"
    echo "alias pls='$SCRIPT_DIR/a'"
    echo "alias please='$SCRIPT_DIR/a'"
fi
