#!/usr/bin/env bash
set -e

ZSHRC="$HOME/.zshrc"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing cq..."

if grep -q "function cq" "$ZSHRC" 2>/dev/null; then
    echo "cq is already installed in $ZSHRC"
    echo "To reinstall, remove the cq block from $ZSHRC and run again."
    exit 0
fi

cat "$SCRIPT_DIR/cq.zsh" >> "$ZSHRC"
echo "" >> "$ZSHRC"

echo "✓ cq installed successfully."
echo ""
echo "Run the following to activate:"
echo "  source ~/.zshrc"
echo ""
echo "Usage:"
echo "  cq gcc main.c        # wrapper mode"
echo "  make 2>&1 | cq       # pipe mode"
