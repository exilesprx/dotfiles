## Aliases
alias ls='lsd'
alias ll='lsd -lav --ignore-glob ".."'   # show long listing of all except ".."
alias l='lsd -lav --ignore-glob ".*"'   # show long listing but no hidden dotfiles except "."
alias vim='nvim'
alias dots='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias welcome='eos-welcome --once'
alias pac-clean='sudo pacman -Qdt | sudo pacman -Rns -'
alias cat='bat'
alias grep='batgrep'
alias clr='clear'

# Exports
export TERM="xterm-256color"
export EDITOR="nvim"
export VISUAL="gedit"
export MANPAGER="nvim +Man!"

# Ghcup
if [ -f "/home/acampbell/.ghcup/env" ]; then
  source "/home/acampbell/.ghcup/env" # ghcup-env
fi

# History for zsh
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# tmuxifier
if [[ -d "$HOME/.tmux/plugins/tmuxifier/bin" ]]; then
  PATH=$PATH:"$HOME/.tmux/plugins/tmuxifier/bin"
  eval "$(tmuxifier init -)"
fi

# Starship
eval "$(starship init zsh)"

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

# Use modern completion
autoload -Uz compinit
compinit
 
# zplug - manage plugins
source ~/.zplug/init.zsh
zplug "plugins/git", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
zplug "junegunn/fzf"

# zplug - install/load new plugins when zsh is started or reloaded
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load

# Zoxide - should be called after compinit
if [ -f "$HOME/.local/bin/zoxide" ]; then
  export PATH=$PATH:$HOME/.local/bin
  eval "$(zoxide init zsh)"
fi
