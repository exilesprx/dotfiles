#!/bin/sh

# Configure single monitor setup (laptop screen only)
# eDP-1: Laptop screen (primary) at 1920x1080
# All external monitors disabled
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
       --output DP-1 --off \
       --output HDMI-1 --off \
       --output HDMI-2 --off

echo "Single monitor configuration applied successfully."
