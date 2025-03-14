#!/bin/bash

if ! brightnessctl -l -c backlight &>/dev/null; then
    echo "No backlight device found" >&2
    exit 0
fi

get_pct() {
    echo $((100 * $(brightnessctl get) / $(brightnessctl max)))
}

case "$1" in
get)
    get_pct
    ;;
change)
    level="$(get_pct)"
    case "$2" in
    up)
        level=$((level + 10))
        ;;
    down)
        level=$((level - 10))
        ;;
    esac
    level=$((level > 0 ? level : 1))
    brightnessctl set "$level%"
    eww update "backlightlevel=$level"
    ;;
*)
    echo >&2 "Usage: $0 get"
    exit 1
    ;;
esac
