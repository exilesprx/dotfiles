set shell := ["bash", "-c"]
set ignore-comments

target := "$HOME"

default: help

help:
  @echo "Commands to stow and unstow dotfiles"

# Using the --adopt flag to avoid conflicts with existing files
# Any existing files will be adopted into the package and when
# used with git, allows a comparison inside the stow package
# which the differences can either be kept or discarded.

stow package:
  stow -v --adopt --target={{target}} {{package}}

[confirm('Are you sure you want to unstow the package? y/n')]
unstow package:
  stow -v --delete --target={{target}} {{package}}

stow-libinput:
  stow -v --adopt --target=/usr/share/X11/xorg.conf.d/ x11

stow-tlp:
  stow -v --adopt --target=/etc/tlp.d/ tlp

stow-code-launcher:
  # update the code.desktop file to point to the this
  # script so variables are set correctly
  stow -v --adopt --target={{target}}/.vscode vscode
