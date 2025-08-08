#!/bin/bash

set -euo pipefail

XR=$(xrandr --query)

# Identify internal panel (primary first, else eDP/LVDS heuristic)
INTERNAL=$(printf '%s\n' "$XR" | awk '$2=="connected" && / primary / {print $1; exit}')
if [ -z "$INTERNAL" ]; then
  INTERNAL=$(printf '%s\n' "$XR" | awk '$2=="connected" && $1 ~ /eDP|LVDS/ {print $1; exit}')
fi
[ -z "$INTERNAL" ] && INTERNAL=eDP-1

# Collect sets
CONNECTED=$(printf '%s\n' "$XR" | awk '$2=="connected" {print $1}')
DISCONNECTED_WITH_GEOM=$(printf '%s\n' "$XR" | awk '$2=="disconnected" && $3 ~ /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {print $1}')
ACTIVE_OUTPUTS=$(printf '%s\n' "$XR" | awk '$2=="connected" && $3 ~ /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {print $1}')

CONNECTED_COUNT=$(printf '%s\n' "$CONNECTED" | wc -w)
ACTIVE_COUNT=$(printf '%s\n' "$ACTIVE_OUTPUTS" | wc -w)
STALE_COUNT=$(printf '%s\n' "$DISCONNECTED_WITH_GEOM" | wc -w)

echo "Connected:$CONNECTED_COUNT[$CONNECTED] Active:$ACTIVE_COUNT[$ACTIVE_OUTPUTS] Stale:$STALE_COUNT[$DISCONNECTED_WITH_GEOM] Internal:$INTERNAL"

# Attempt to wake stale outputs (they have geometry but show disconnected) – common with MST docks
if [ "$STALE_COUNT" -gt 0 ]; then
  for so in $DISCONNECTED_WITH_GEOM; do
    echo "Attempting re-enable of stale output $so" >&2
    xrandr --output "$so" --auto || true
  done
  # Short delay then re-query
  sleep 0.4
  XR=$(xrandr --query)
  CONNECTED=$(printf '%s\n' "$XR" | awk '$2=="connected" {print $1}')
  ACTIVE_OUTPUTS=$(printf '%s\n' "$XR" | awk '$2=="connected" && $3 ~ /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {print $1}')
  DISCONNECTED_WITH_GEOM=$(printf '%s\n' "$XR" | awk '$2=="disconnected" && $3 ~ /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {print $1}')
  CONNECTED_COUNT=$(printf '%s\n' "$CONNECTED" | wc -w)
  ACTIVE_COUNT=$(printf '%s\n' "$ACTIVE_OUTPUTS" | wc -w)
  STALE_COUNT=$(printf '%s\n' "$DISCONNECTED_WITH_GEOM" | wc -w)
  echo "Post-wake: Connected:$CONNECTED_COUNT[$CONNECTED] Active:$ACTIVE_COUNT[$ACTIVE_OUTPUTS] Stale:$STALE_COUNT[$DISCONNECTED_WITH_GEOM]" >&2
fi

relocate_from_outputs() {
  command -v i3-msg >/dev/null 2>&1 || return 0
  targets="$*"
  [ -z "$targets" ] && return 0
  # Loop until no workspace reports any target output
  for attempt in 1 2 3 4; do
    changed=0
    if command -v jq >/dev/null 2>&1; then
      for out in $targets; do
        wslist=$(i3-msg -t get_workspaces | jq -r --arg O "$out" '.[] | select(.output==$O) | .name')
        if [ -n "$wslist" ]; then
          for ws in $wslist; do
            i3-msg "workspace $ws; move workspace to output $INTERNAL" >/dev/null
            changed=1
          done
        fi
      done
    else
      for n in 1 2 3 4 5 6 7 8 9 10; do
        i3-msg "workspace $n; move workspace to output $INTERNAL" >/dev/null 2>&1 || true
      done
      changed=0
    fi
    [ $changed -eq 0 ] && break
    sleep 0.1
  done
}

run_single() {
  "$HOME/.screenlayout/single-monitor.sh"
  # Relocate any that still reference non-internal or stale outputs
  relocate_from_outputs $DISCONNECTED_WITH_GEOM
}

run_dual() {
  "$HOME/.screenlayout/dual-monitor.sh" || true
  # After enabling, relocate from stale (none expected), then optionally distribute
  relocate_from_outputs $DISCONNECTED_WITH_GEOM
}

# If we have stale outputs, evacuate their workspaces first (pre-emptive rescue)
if [ "$STALE_COUNT" -gt 0 ]; then
  relocate_from_outputs $DISCONNECTED_WITH_GEOM
fi

# Decide mode (need at least 2 truly connected outputs for dual)
if [ "$CONNECTED_COUNT" -ge 2 ]; then
  run_dual
else
  run_single
fi

# Apply wallpapers dynamically (non-blocking) if script present
if [ -x "$HOME/.screenlayout/set-wallpaper.sh" ]; then ( "$HOME/.screenlayout/set-wallpaper.sh" & ); fi
