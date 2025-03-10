set shell := ["bash", "-c"]

TARGET_DIR := "$HOME"

default: help

help:
  @echo "Commands to stow and unstow dotfiles"

stow-all:
  @for dir in $(find . -mindepth 1 -maxdepth 1 -type d ! -name ".git"); do \
    stow -v --target={{TARGET_DIR}} $(basename "$dir"); \
  done

[confirm('Are you sure you want to delete all the files? y/n')]
unstow-all:
  @for dir in $(find . -mindepth 1 -maxdepth 1 -type d ! -name ".git"); do \
    stow -v --delete --target={{TARGET_DIR}} $(basename "$dir"); \
  done

[confirm('Are you sure you want to restow all the files? y/n')]
restow-all:
  @for dir in $(find . -mindepth 1 -maxdepth 1 -type d ! -name ".git"); do \
    stow -v --restow --target={{TARGET_DIR}} $(basename "$dir"); \
  done

stow PACKAGE:
  stow -v --target={{TARGET_DIR}} {{PACKAGE}}

unstow PACKAGE:
  stow -v --delete --target={{TARGET_DIR}} {{PACKAGE}}

stow-libinput:
  stow -v --target=/usr/share/X11/xorg.conf.d/ x11
