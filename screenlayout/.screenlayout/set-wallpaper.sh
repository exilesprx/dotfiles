#!/bin/sh
# Dynamic wallpaper setter for i3 + feh
# Usage: invoked after display layout scripts.
# Config via environment variables (export in i3 config or shell):
#   WALLPAPER_SINGLE   - image for single monitor
#   WALLPAPER_LEFT     - left monitor image (dual/multi)
#   WALLPAPER_RIGHT    - right monitor image (dual/multi)
#   WALLPAPER_FILL_MODE (optional) one of: fill, scale, center, max, tile (default: fill)
# Falls back to using WALLPAPER_SINGLE (or last known feh image) if others unset.

set -eu

[ -z "${WALLPAPER_FILL_MODE:-}" ] && WALLPAPER_FILL_MODE=fill

# Provide sensible defaults if variables not exported (e.g. i3 'set' vars not in env)
DEFAULT_SINGLE="$HOME/Pictures/husky.jpg"
if [ -z "${WALLPAPER_SINGLE:-}" ] && [ -f "$DEFAULT_SINGLE" ]; then
  WALLPAPER_SINGLE="$DEFAULT_SINGLE"
fi

if ! command -v feh >/dev/null 2>&1; then
  echo "feh not installed; skipping wallpaper" >&2
  exit 0
fi

# Collect connected outputs in left-to-right order (by x offset)
# We parse xrandr and then sort by +X+Y geometry
outputs_info=$(xrandr --query | awk '/ connected/{print $1,$3}' | sed 's/primary //')
# Format: NAME GEOM (e.g. eDP-1 1920x1080+0+0 or DP-1-3 1920x1080+1920+0)
# Build list sorted by X offset
ordered=$(printf '%s\n' "$outputs_info" | awk 'NF==2 && $2 ~ /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {split($2,g,"+"); print g[2],$1}' | sort -n | awk '{print $2}')
count=$(printf '%s' "$ordered" | wc -w)

# Decide feh mode flag
case "$WALLPAPER_FILL_MODE" in
  fill) mode_flag=--bg-fill ;;
  scale) mode_flag=--bg-scale ;;
  center) mode_flag=--bg-center ;;
  max) mode_flag=--bg-max ;;
  tile) mode_flag=--bg-tile ;;
  *) mode_flag=--bg-fill ;;
esac

apply_single() {
  img="$1"
  [ -z "$img" ] && return 1
  [ -f "$img" ] || return 1
  feh --no-fehbg "$mode_flag" "$img" || true
}

apply_dual() {
  left="$1"; right="$2"
  # Require both exist
  if [ -f "$left" ] && [ -f "$right" ]; then
    feh --no-fehbg "$mode_flag" "$left" "$right" || true
    return 0
  fi
  return 1
}

# Attempt logic
if [ "$count" -le 1 ]; then
  # Single monitor scenario
  if ! apply_single "${WALLPAPER_SINGLE:-}"; then
    echo "Single wallpaper not set or missing; leaving existing background" >&2
  fi
else
  # Multi-monitor: use left/right images if provided; fall back to single repeated
  if ! apply_dual "${WALLPAPER_LEFT:-}" "${WALLPAPER_RIGHT:-}"; then
    # Try repeating single across heads (feh accepts the same image twice)
    if [ -n "${WALLPAPER_SINGLE:-}" ] && [ -f "${WALLPAPER_SINGLE:-}" ]; then
      # Duplicate for each head
      imgs=""
      for o in $ordered; do imgs="$imgs ${WALLPAPER_SINGLE}"; done
      # shellcheck disable=SC2086
      feh --no-fehbg "$mode_flag" $imgs || true
    else
      echo "No dual wallpapers defined; leaving existing background" >&2
    fi
  fi
fi

exit 0
