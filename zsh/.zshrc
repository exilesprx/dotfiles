# History for zsh
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt sharehistory histignorealldups

# Custom key binds
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

[ -f "$HOME/.zsh_aliases" ] && source "$HOME/.zsh_aliases"
[ -f "$HOME/.zsh_exports" ] && source "$HOME/.zsh_exports"

# cargo/rust
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# fnm
if command -v fnm &> /dev/null; then
  eval "`fnm env`"
fi

# Ghcup
if [ -f "$HOME/.ghcup/env" ]; then
  source "$HOME/.ghcup/env" # ghcup-env
fi

# goenv
if [ -d "/opt/goenv" ]; then
  export GOENV_ROOT="/opt/goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  eval "$(goenv init -)"
fi

if [ -n "$GOPATH" ] && [ -d "$GOPATH/bin" ]; then
  export PATH="$PATH:$GOPATH/bin"
fi

# Starship
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Zim
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

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/acampbell/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<


# pnpm
export PNPM_HOME="/home/acampbell/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
