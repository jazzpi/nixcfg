#!/bin/bash

echo >&2 "inhibit_idle.sh not implemented for hyprland"
exit 1

usage() {
    echo >&2 "Usage: inhibit_idle.sh set true|false"
    exit 1
}

if [ $# -ne 2 ] || [ "$1" != "set" ]; then
    usage
fi

case "$2" in
true)
    xset s off -dpms
    eww update inhibit_idle=true
    ;;
false)
    xset s on +dpms
    eww update inhibit_idle=false
    ;;
*)
    usage
    ;;
esac
