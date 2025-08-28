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

# update the code.desktop file to point to the this
# script so variables are set correctly
stow-code-launcher:
  #!/usr/bin/sh
  home="$HOME"
  stow -v --adopt --target={{target}}/.vscode vscode
  # ensure the launcher is executable
  chmod +x "{{target}}/.vscode/code-launcher.sh" || true
  # place a user override for the desktop entry and update Exec= to use the launcher
  desktop_dir="$home/.local/share/applications"
  desktop_file="$desktop_dir/code.desktop"
  mkdir -p "$desktop_dir"
  if [ ! -f "$desktop_file" ]; then
    if [ -f "/usr/share/applications/code.desktop" ]; then
      install -m 0644 "/usr/share/applications/code.desktop" "$desktop_file"
    else
      echo "code.desktop not found in /usr/share/applications; skipping Exec replacement." >&2
      exit 0
    fi
  fi
  # Replace only Exec lines that invoke /usr/bin/code, keep args intact
  sed -E -i "s#^([[:space:]]*Exec=)/usr/bin/code([[:space:]]|$)#\\1$home/.vscode/code-launcher.sh\\2#g" "$desktop_file"
  echo "Updated Exec entries in $desktop_file to use $home/.vscode/code-launcher.sh"
