#! /bin/bash

monitors=$(xrandr --query | batgrep -A 0 -B 0 " connected" | awk '/ connected/ {print $1}')
monitor_count=$(echo "$monitors" | wc -w)

echo "Found $monitor_count monitors"
for monitor in $monitors; do
  echo "Found $monitor"
done

if [ "$monitor_count" -eq 1 ]; then
  "$HOME/.screenlayout/single-monitor.sh"
elif [ "$monitor_count" -eq 2 ]; then
  "$HOME/.screenlayout/dual-monitor.sh"
else
  echo "No configuration for this setup"
fi
