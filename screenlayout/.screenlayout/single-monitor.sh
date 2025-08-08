#!/bin/sh

# Single monitor setup (turn off all externals, keep only internal panel active)
# Dynamically finds internal (eDP/LVDS) and powers down every other connected output (including MST like DP-1-3).

set -eu

# Preferred resolution / refresh (override with WANT_MODE / WANT_REFRESH env vars)
want_mode=${WANT_MODE:-1920x1080}
want_refresh=${WANT_REFRESH:-60}

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

# Determine if desired mode exists; else fall back to preferred (*) or first mode
pick_mode() {
       out=$1
       block=$(printf '%s\n' "$XRANDR_OUT" | sed -n "/^$out connected/,/^[^[:space:]]/p")
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

mode_int=$(pick_mode "$INTERNAL")
refresh_flag=""
if [ -n "$want_refresh" ]; then
       block_int=$(printf '%s\n' "$XRANDR_OUT" | sed -n "/^$INTERNAL connected/,/^[^[:space:]]/p")
       if printf '%s\n' "$block_int" | awk -v m="$mode_int" -v r="$want_refresh" '($1==m){for(i=2;i<=NF;i++) if ($i ~ r) f=1} END{exit f?0:1}'; then
              refresh_flag="--rate $want_refresh"
       fi
fi

CMD="xrandr --output $INTERNAL --primary --mode $mode_int $refresh_flag --pos 0x0 --rotate normal"
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
