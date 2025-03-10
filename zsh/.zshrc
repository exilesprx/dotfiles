# History for zsh
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

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
if [ -f "$HOME/.cargo/bin/fnm" ]; then
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
  export PATH="$GOROOT/bin:$PATH"
  export PATH="$PATH:$GOPATH/bin"
fi

# Starship
if [ -f "$HOME/.cargo/bin/starship" ]; then
  eval "$(starship init zsh)"
fi

# SSH key
env=~/.ssh/agent.env
agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }
agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }
agent_load_env
# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)
if [ ! "$SSH_AUTH_SOCK" ] || [ "$agent_run_state" = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ "$agent_run_state" = 1 ]; then
    ssh-add
fi
unset env

# Zim
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
if [ -f "$ZIM_HOME/init.zsh" ]; then
  source ${ZIM_HOME}/init.zsh
fi

# Zoxide - should be called after compinit
if [ -f "$HOME/.cargo/bin/zoxide" ]; then
  eval "$(zoxide init zsh)"
fi

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/acampbell/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<

