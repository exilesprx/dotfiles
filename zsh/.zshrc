# Avoid duplicate entries in PATH
typeset -U path

# History for zsh
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt sharehistory histignorealldups

# Custom key binds
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Android sdk
if [ -d "$HOME/.local/share/android-sdk" ]; then
  export ANDROID_SDK_ROOT="$HOME/.local/share/android-sdk"
  path=("$ANDROID_SDK_ROOT/cmdline-tools/latest/bin" $path)
  path=("$ANDROID_SDK_ROOT/platform-tools" $path)
fi

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
if [ -d "$HOME/.local/share/goenv" ]; then
  export GOENV_ROOT="$HOME/.local/share/goenv"
  path=("$GOENV_ROOT/bin" $path)
  eval "$(goenv init -)"
fi

if [ -n "$GOPATH" ] && [ -d "$GOPATH/bin" ]; then
  path=("$GOPATH/bin" $path)
fi

# Starship
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Zim
ZIM_HOME="$HOME/.zim"
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
if [ -f "$ZIM_HOME/init.zsh" ]; then
  source ${ZIM_HOME}/init.zsh
fi

# Zoxide - should be called after compinit
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
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

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

[ -f "$HOME/.zsh_aliases" ] && source "$HOME/.zsh_aliases"
[ -f "$HOME/.zsh_functions" ] && source "$HOME/.zsh_functions"
