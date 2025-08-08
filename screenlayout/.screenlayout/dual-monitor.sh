#!/bin/sh

#!/bin/sh
# Dynamic dual-monitor setup (dock / MST safe). Works when invoked from zsh.
# Strategy:
#  1. Detect internal panel (primary or eDP/LVDS)
#  2. Detect first other connected output (e.g. DP-1-3, HDMI-2, etc.)
#  3. Try to use 1920x1080 on both; if unavailable, use that output's preferred (*) mode; fallback to first mode.

set -eu

# Desired internal resolution and preferred refresh (override with WANT_MODE / WANT_REFRESH)
want_mode=${WANT_MODE:-1920x1080}
want_refresh=${WANT_REFRESH:-60}

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
       echo "No external display detected; single-monitor only." >&2
       exec xrandr --output "$internal" --primary --auto
fi

pick_internal_mode() {
       out="$1"
       block=$(xrandr --query | sed -n "/^$out connected/,/^[^[:space:]]/p")
       modes=$(printf '%s\n' "$block" | awk '/^[[:space:]]/{print $1}')
       if printf '%s\n' "$modes" | grep -qx "$want_mode"; then
              echo "$want_mode"; return 0
       fi
       star=$(printf '%s\n' "$block" | awk '/\*/{gsub(/^[[:space:]]+/,"",$0); print $1; exit}')
       if [ -n "$star" ]; then
              echo "$star"; return 0
       fi
       printf '%s\n' "$modes" | head -n1
}

mode_int=$(pick_internal_mode "$internal")
if [ -z "$mode_int" ]; then
       echo "Failed to resolve internal mode" >&2
       exit 1
fi

int_width=${mode_int%x*}
pos_ext="${int_width}x0"

refresh_flag_int=""
if [ -n "$want_refresh" ]; then
       block_int=$(xrandr --query | sed -n "/^$internal connected/,/^[^[:space:]]/p")
       if printf '%s\n' "$block_int" | awk -v m="$mode_int" -v r="$want_refresh" '($1==m){for(i=2;i<=NF;i++) if ($i ~ r) f=1} END{exit f?0:1}'; then
              refresh_flag_int="--rate $want_refresh"
       fi
fi

echo "Configuring internal=$internal($mode_int${refresh_flag_int:+ @${want_refresh}Hz}) external=$external(auto)" >&2
PRIMARY_CMD="xrandr --output $internal --primary --mode $mode_int $refresh_flag_int --pos 0x0 --rotate normal --output $external --auto --pos $pos_ext --rotate normal"
echo "Running: $PRIMARY_CMD" >&2
if ! eval "$PRIMARY_CMD"; then
       echo "Primary xrandr command failed; retrying once." >&2
       eval "$PRIMARY_CMD" || true
fi

# Small wait to allow link training
sleep 0.4

# Verify external became active (has geometry)
XR_NOW=$(xrandr --query | awk -v E="$external" '$1==E {print}')
if printf '%s' "$XR_NOW" | grep -q '+[0-9]\++[0-9]\+'; then
       echo "External $external active." >&2
else
       echo "External $external still no geometry; forcing --auto and DPMS on." >&2
       xrandr --output "$external" --auto --pos "$pos_ext" --rotate normal || true
       (command -v xset >/dev/null 2>&1 && xset dpms force on) || true
fi

echo "Dual monitor configuration applied (internal: $mode_int${refresh_flag_int:+ @${want_refresh}Hz}, external: auto)."

# Optional: set per‑monitor wallpapers to avoid a stretched single image.
# Define WALLPAPER_INT and WALLPAPER_EXT environment variables before calling the script, e.g.:
#   WALLPAPER_INT=~/Pictures/wall_laptop.jpg WALLPAPER_EXT=~/Pictures/wall_external.jpg ~/.screenlayout/dual-monitor.sh
# Requires 'feh' (or adapt for 'nitrogen'). Order of images must match monitor left->right.
if command -v feh >/dev/null 2>&1; then
       if [ -n "${WALLPAPER_INT:-}" ] && [ -n "${WALLPAPER_EXT:-}" ]; then
              feh --no-fehbg --bg-fill "$WALLPAPER_INT" "$WALLPAPER_EXT" || true
       fi
fi
