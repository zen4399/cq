#!/usr/bin/env bash
set -e

ZSHRC="$HOME/.zshrc"
RAW_URL="https://raw.githubusercontent.com/zen4399/cq/main/cq.zsh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing cq..."

if grep -q "function cq" "$ZSHRC" 2>/dev/null; then
    echo "cq is already installed in $ZSHRC"
    echo "To reinstall, remove the cq block from $ZSHRC and run again."
    exit 0
fi

# curl経由 (pipe install) の場合はGitHubからダウンロード、
# git clone後のローカル実行の場合はローカルファイルを使用
if [ -f "$SCRIPT_DIR/cq.zsh" ]; then
    cat "$SCRIPT_DIR/cq.zsh" >> "$ZSHRC"
else
    curl -fsSL "$RAW_URL" >> "$ZSHRC"
fi

echo "" >> "$ZSHRC"

echo "✓ cq installed successfully."
echo ""
echo "Run the following to activate:"
echo "  source ~/.zshrc"
echo ""
echo "Usage:"
echo "  cq gcc main.c        # wrapper mode"
echo "  make 2>&1 | cq       # pipe mode"
