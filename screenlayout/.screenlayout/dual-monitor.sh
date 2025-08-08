#!/bin/sh

#!/bin/sh
# Dynamic dual-monitor setup (dock / MST safe). Works when invoked from zsh.
# Strategy:
#  1. Detect internal panel (primary or eDP/LVDS)
#  2. Detect first other connected output (e.g. DP-1-3, HDMI-2, etc.)
#  3. Try to use 1920x1080 on both; if unavailable, use that output's preferred (*) mode; fallback to first mode.

set -eu

want_mode=1920x1080

# 1. Internal panel
internal=$(xrandr --query | awk '/ connected primary/{print $1; exit}')
if [ -z "$internal" ]; then
       internal=$(xrandr --query | awk '/ connected/ && $1 ~ /eDP|LVDS/ {print $1; exit}')
fi
if [ -z "$internal" ]; then
       echo "Could not find internal panel" >&2
       exit 1
fi

# 2. External (any other connected)
external=$(xrandr --query | awk -v i="$internal" '/ connected/ {if ($1!=i) print $1}' | head -n1 || true)
if [ -z "$external" ]; then
       echo "No external display; reverting to single display on $internal" >&2
       exec xrandr --output "$internal" --primary --auto
fi

# Function to pick a mode
pick_mode() {
       out="$1"
       # Isolate that output's block
       block=$(xrandr --query | sed -n "/^$out connected/,/^[^[:space:]]/p")
       # Collect mode list (first column of indented lines)
       modes=$(printf '%s\n' "$block" | awk '/^[[:space:]]/{print $1}')
       if printf '%s\n' "$modes" | grep -qx "$want_mode"; then
              echo "$want_mode"; return 0
       fi
       star=$(printf '%s\n' "$block" | awk '/\*/{gsub(/^[[:space:]]+/,"",$0); print $1; exit}')
       if [ -n "$star" ]; then
              echo "$star"; return 0
       fi
       # first mode
       printf '%s\n' "$modes" | head -n1
}

mode_int=$(pick_mode "$internal")
mode_ext=$(pick_mode "$external")
if [ -z "$mode_int" ] || [ -z "$mode_ext" ]; then
       echo "Failed to resolve modes (internal=$mode_int external=$mode_ext)" >&2
       exit 1
fi

int_width=${mode_int%x*}
pos_ext="${int_width}x0"

echo "Configuring internal=$internal($mode_int) external=$external($mode_ext)" >&2
xrandr \
       --output "$internal" --primary --mode "$mode_int" --pos 0x0 --rotate normal \
       --output "$external" --mode "$mode_ext" --pos "$pos_ext" --rotate normal

echo "Dual monitor configuration applied successfully (internal: $mode_int, external: $mode_ext)."

# Optional: set per‑monitor wallpapers to avoid a stretched single image.
# Define WALLPAPER_INT and WALLPAPER_EXT environment variables before calling the script, e.g.:
#   WALLPAPER_INT=~/Pictures/wall_laptop.jpg WALLPAPER_EXT=~/Pictures/wall_external.jpg ~/.screenlayout/dual-monitor.sh
# Requires 'feh' (or adapt for 'nitrogen'). Order of images must match monitor left->right.
if command -v feh >/dev/null 2>&1; then
       if [ -n "${WALLPAPER_INT:-}" ] && [ -n "${WALLPAPER_EXT:-}" ]; then
              feh --no-fehbg --bg-fill "$WALLPAPER_INT" "$WALLPAPER_EXT" || true
       fi
fi
       # Fallback: first mode
