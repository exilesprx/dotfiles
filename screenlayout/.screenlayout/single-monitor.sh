#!/bin/sh

# Single monitor setup (turn off all externals, keep only internal panel active)
# Dynamically finds internal (eDP/LVDS) and powers down every other connected output (including MST like DP-1-3).

set -eu

XRANDR_OUT=$(xrandr --query)

# Identify internal (primary first else eDP/LVDS pattern)
INTERNAL=$(printf '%s\n' "$XRANDR_OUT" | awk '/ connected primary/{print $1; exit}')
if [ -z "$INTERNAL" ]; then
       INTERNAL=$(printf '%s\n' "$XRANDR_OUT" | awk '/ connected/ && $1 ~ /eDP|LVDS/ {print $1; exit}')
fi
if [ -z "$INTERNAL" ]; then
       echo "Could not determine internal panel (eDP/LVDS)." >&2
       exit 1
fi

# Collect other connected outputs
OTHERS=$(printf '%s\n' "$XRANDR_OUT" | awk -v I="$INTERNAL" '/ connected/ && $1!=I {print $1}')

CMD="xrandr --output $INTERNAL --primary --mode 1920x1080 --pos 0x0 --rotate normal"
for o in $OTHERS; do
       CMD="$CMD --output $o --off"
done

echo "Running: $CMD" >&2
if eval "$CMD"; then
       echo "Single monitor configuration applied successfully (active: $INTERNAL)."
else
       echo "Failed to apply single monitor configuration." >&2
       exit 1
fi
