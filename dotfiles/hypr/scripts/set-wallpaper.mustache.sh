#!/bin/sh

set -euo pipefail

if [ "$#" -eq 1 ]; then
    month="$1"
else
    month=$(date +%m)
fi
year=$(date +%Y)

wallpaper="{{ wallpapersDir }}/$year/$month.jpg"

if ! [ -f "$wallpaper" ]; then
    notify-send -u critical "Wallpaper for $year-$month not found at $wallpaper"
    exit 1
fi

wpaperd_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/wpaperd"
mkdir -p "$wpaperd_config_dir"

cat >"$wpaperd_config_dir/config.toml" <<EOF
[any]
path = "$wallpaper"
EOF

ln -fs "$wallpaper" "${XDG_STATE_HOME:-$HOME/.local/state}/lockscreen.jpg"
