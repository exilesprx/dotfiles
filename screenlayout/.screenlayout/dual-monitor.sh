#!/bin/sh

# Configure dual monitor setup
# eDP-1: Laptop screen (primary) at 1920x1080
# HDMI-2: External monitor at 1920x1080 to the right of laptop screen
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
       --output DP-1 --off \
       --output HDMI-1 --off \
       --output HDMI-2 --mode 1920x1080 --pos 1920x0 --rotate normal

echo "Dual monitor configuration applied successfully."
