#!/bin/bash

exec >>/tmp/eww.log
exec 2>&1

if [ $# -ne 0 ]; then
    echo >&2 "Usage: $0 SCRIPTNAME"
    exit 1
fi

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

eww kill
eww daemon
for i in $(seq 1 10); do
    if eww ping &>/dev/null; then
        break
    fi
    sleep 1
done
if ! eww ping &>/dev/null; then
    echo >&2 "Eww daemon failed to start"
    exit 1
fi

"$script_dir/wm.sh" launch
