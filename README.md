# cq — Claude Query

> Pipe any command output directly into your **existing** Claude Code session.

```bash
curl -fsSL https://raw.githubusercontent.com/zen4399/cq/main/install.sh | bash && source ~/.zshrc
```

## The Problem

Every time you hit an error, you:
1. Copy the error output
2. Switch to Claude Code pane
3. Paste
4. Lose your conversation context

**7 steps. 2 context switches. Every. Single. Time.**

## The Solution

```bash
cq gcc main.c
```

One command. Zero context switches. Existing session preserved.

## How It Works

```
cq gcc main.c
    │
    ├─ Runs: gcc main.c 2>&1   (auto-captures stderr)
    │
    ├─ Finds Claude Code pane via WezTerm / tmux IPC
    │
    └─ Injects output into existing session + auto-focus
```

vs the official `| claude`:

```bash
gcc main.c 2>&1 | claude   # opens NEW session (context lost)
cq gcc main.c              # pipes into EXISTING session (context preserved)
```

## Install

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/zen4399/cq/main/install.sh | bash && source ~/.zshrc
```

**Or via git clone:**
```bash
git clone https://github.com/zen4399/cq
cd cq && ./install.sh
source ~/.zshrc
```

## Usage

### Wrapper mode (recommended)

```bash
cq gcc main.c
cq make
cq ./a.out
cq cargo build
cq npm install
```

Automatically captures both stdout and stderr. No `2>&1` needed.

### Pipe mode

```bash
cat error.log | cq
tail -f app.log | cq
grep "ERROR" app.log | cq
```

## Requirements

- [Claude Code CLI](https://claude.ai/code)
- zsh
- One of:
  - [WezTerm](https://wezfurlong.org/wezterm/) (macOS/Linux/Windows)
  - tmux (macOS/Linux)

## Compatibility

| Terminal | Status |
|----------|--------|
| WezTerm  | ✅ Supported |
| tmux     | ✅ Supported |
| iTerm2   | 🚧 Coming soon |
| Others   | ⬇️ Falls back to `claude --continue` |

## Auto-launch

If no Claude Code pane is detected, cq **automatically opens one** in a new split pane:

```
[cq] No Claude Code pane found. Launching...
→ WezTerm splits right, launches claude --continue
→ Sends output to the new pane
```

No manual setup required. Just run `cq` and it handles everything.

## License

MIT
