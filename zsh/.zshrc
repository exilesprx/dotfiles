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

# Zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

[ -f "$HOME/.zsh_aliases" ] && source "$HOME/.zsh_aliases"
