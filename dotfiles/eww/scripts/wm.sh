#!/bin/bash

if [ $# -lt 1 ]; then
    echo >&2 "Usage: $0 SCRIPTNAME [ARGS...]"
    exit 1
fi

cd_len=$(echo -n "$XDG_CURRENT_DESKTOP" | wc -c)
sd_len=$(echo -n "$XDG_SESSION_DESKTOP" | wc -c)
if [ $cd_len -gt $sd_len ]; then
    xdg_desktop="$XDG_CURRENT_DESKTOP"
else
    xdg_desktop="$XDG_SESSION_DESKTOP"
fi

case "$xdg_desktop" in
*i3)
    desktop=i3
    ;;
*[Hh]yprland)
    desktop=hypr
    ;;
*)
    echo >&2 "Unsupported desktop '$xdg_desktop'"
    exit 1
    ;;
esac

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

script="$1"
shift 1

exec "$script_dir/$desktop/$script.sh" $@
