#!/usr/bin/env zsh
# cq - Claude Query
# Pipe any command output directly into your existing Claude Code session.
#
# Usage:
#   cq <command>          # wrapper mode (auto captures stderr)
#   <command> 2>&1 | cq   # pipe mode
#
# vs official:
#   | claude              # opens NEW session
#   cq / | cq             # pipes into EXISTING session

function cq() {
    local input

    if [ -t 0 ]; then
        # Wrapper mode: cq gcc main.c
        if [ -z "$*" ]; then
            echo "Usage: cq <command> or <command> 2>&1 | cq"
            return 1
        fi
        input=$(eval "$@" 2>&1)
        echo "$input"
    else
        # Pipe mode: gcc main.c 2>&1 | cq
        input=$(cat)
        echo "$input"
    fi

    _cq_send "$input"
}

function _cq_send() {
    local input="$1"

    # Detect multiplexer and send to existing Claude Code session
    if command -v wezterm > /dev/null 2>&1; then
        _cq_send_wezterm "$input" && return
    fi

    if [ -n "$TMUX" ] && command -v tmux > /dev/null 2>&1; then
        _cq_send_tmux "$input" && return
    fi

    # Fallback: claude --continue
    echo "[No Claude Code pane found. Starting with --continue...]"
    echo "$input" | claude --continue
}

function _cq_send_wezterm() {
    local input="$1"
    local claude_pane
    claude_pane=$(wezterm cli list 2>/dev/null \
        | grep "Claude Code" \
        | awk '{print $3}' \
        | head -1)

    if [ -z "$claude_pane" ]; then
        # No Claude Code pane found — auto-launch in a new split
        echo "[cq] No Claude Code pane found. Launching..."
        wezterm cli split-pane --right -- claude --continue 2>/dev/null
        sleep 2
        claude_pane=$(wezterm cli list 2>/dev/null \
            | grep "Claude Code" \
            | awk '{print $3}' \
            | head -1)
        [ -z "$claude_pane" ] && return 1
    fi

    wezterm cli send-text --pane-id "$claude_pane" "$input"$'\n'
    wezterm cli activate-pane --pane-id "$claude_pane"
    echo "[cq → Claude Code pane: $claude_pane]"
    return 0
}

function _cq_send_tmux() {
    local input="$1"
    local claude_pane
    claude_pane=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' 2>/dev/null \
        | grep "Claude Code" \
        | awk '{print $1}' \
        | head -1)

    if [ -z "$claude_pane" ]; then
        # No Claude Code pane found — auto-launch in a new split
        echo "[cq] No Claude Code pane found. Launching..."
        tmux split-window -h "claude --continue" 2>/dev/null
        sleep 2
        claude_pane=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' 2>/dev/null \
            | grep "Claude Code" \
            | awk '{print $1}' \
            | head -1)
        [ -z "$claude_pane" ] && return 1
    fi

    tmux send-keys -t "$claude_pane" "$input" Enter
    tmux select-pane -t "$claude_pane"
    echo "[cq → Claude Code tmux pane: $claude_pane]"
    return 0
}
