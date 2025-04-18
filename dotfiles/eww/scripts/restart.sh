#!/bin/bash

exec >>/tmp/eww.log
exec 2>&1

if [ $# -ne 0 ]; then
    echo >&2 "Usage: $0 SCRIPTNAME"
    exit 1
fi

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

pkill eww
"$script_dir/wm.sh" launch
