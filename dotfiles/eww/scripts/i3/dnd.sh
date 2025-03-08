#!/bin/bash

usage() {
    echo >&2 "Usage: dnd.sh set true|false"
    exit 1
}

if [ $# -ne 2 ] || [ "$1" != "set" ]; then
    usage
fi

case "$2" in
true)
    dunstctl set-paused true
    eww update dnd=true
    ;;
false)
    dunstctl set-paused false
    eww update dnd=false
    ;;
*)
    usage
    ;;
esac
