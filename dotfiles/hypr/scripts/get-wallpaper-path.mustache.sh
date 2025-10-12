#!/bin/sh

set -euo pipefail

if [ "$#" -eq 1 ]; then
    month="$1"
else
    month=$(date +%m)
fi
year=$(date +%Y)

wallpaper="{{ wallpapersDir }}/$year/$month.jpg"

if !  [ -f "$wallpaper" ]; then
    notify-send -u critical "Wallpaper for $year-$month not found at $wallpaper"
    exit 1
fi

echo "$wallpaper"
