#!/usr/bin/env zsh

# Source the .zshrc file to set up the goenv environment
source ~/.zshrc

# Launch VS Code, inheriting the now-correct environment variables
exec /usr/bin/code "$@"
