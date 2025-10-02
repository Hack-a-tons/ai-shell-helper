#!/usr/bin/env bash

# Get the absolute path to the 'a' script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Choose an alias for your AI shell helper:"
echo "1. a        - Short and simple"
echo "2. ask      - Descriptive and clear"
echo "3. ai       - Clear purpose"
echo "4. cmd      - Command-focused"
echo ""
echo "Copy and paste one of these commands:"
echo "alias a='$SCRIPT_DIR/a'"
echo "alias ask='$SCRIPT_DIR/a'"
echo "alias ai='$SCRIPT_DIR/a'"
echo "alias cmd='$SCRIPT_DIR/a'"
