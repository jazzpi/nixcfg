#!/bin/bash

usage() {
    echo >&2 "Usage: player.sh monitor|up|down|play-pause"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

PLAYERS="spotify"

monitor() {
    playing=""
    metadata=""

    (
        playerctl -p "$PLAYERS" -F metadata --format '{{status}} ##### {{mpris:artUrl}} ##### {{artist}} ##### {{title}}'
    ) | while IFS='' read line; do
        if [ -z "$line" ]; then
            echo "{\"status\":\"stopped\",\"art\":\"\",\"artist\":\"\",\"title\":\"\"}"
        fi
        separated=$(echo "$line" | awk -F ' ##### ' 'BEGIN{OFS="\n";} {$1=$1}1')
        IFS=$'\n' read -rd '' status art artist title <<<"$separated"
        echo "{}" |
            jq -c --arg status "$status" --arg art "$art" --arg artist "$artist" --arg title "$title" \
                '.status = $status | .art = $art | .artist = $artist | .title = $title'
    done
}

case "$1" in
monitor)
    monitor
    ;;
up)
    playerctl -p "$PLAYERS" next
    ;;
down)
    playerctl -p "$PLAYERS" previous
    ;;
play-pause)
    playerctl -p "$PLAYERS" play-pause
    ;;
*)
    usage
    ;;
esac
