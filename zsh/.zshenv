typeset -U path

export TERM="xterm-256color"
export EDITOR="nvim"
export VISUAL="gedit"
export MANPAGER="nvim +Man!"

# cargo/rust
if [ -d "$HOME/.cargo/bin" ]; then
  path=("$HOME/.cargo/bin" $path)
fi

# fnm
if command -v fnm &> /dev/null; then
  eval "`fnm env`"
fi

# Ghcup
if [ -f "$HOME/.ghcup/env" ]; then
  path=("$HOME/.ghcup/env" $path)
fi

# goenv
if [ -d "/opt/goenv" ]; then
  export GOENV_ROOT="/opt/goenv"
  path=("$GOENV_ROOT/bin" $path)
  eval "$(goenv init -)"
fi

if [ -n "$GOPATH" ] && [ -d "$GOPATH/bin" ]; then
  path=("$GOPATH/bin" $path)
fi

# juliaup
if [ -d "$HOME/.juliaup/bin" ]; then
  path=("$HOME/.juliaup/bin" $path)
fi

# pnpm
if [ -d "$HOME/.local/share/pnpm" ]; then
  path=("$HOME/.local/share/pnpm" $path)
fi

# opencode
if [ -d "$HOME/.opencode/bin" ]; then
  path=("$HOME/.opencode/bin" $path)
fi

if [ -d "$HOME/.local/bin" ]; then
  path=("$HOME/.local/bin" $path)
fi
