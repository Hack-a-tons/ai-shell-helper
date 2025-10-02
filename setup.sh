#!/usr/bin/env bash

# Get the absolute path to the 'a' script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Run this command to create the alias for your current session:"
echo "alias a='$SCRIPT_DIR/a'"
