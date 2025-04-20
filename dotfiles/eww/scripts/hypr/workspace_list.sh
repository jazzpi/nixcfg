#!/bin/bash

source "${BASH_SOURCE%/*}/util.sh"

subscribe "^(focusedmon|workspace|destroyworkspace)" | while IFS='' read line; do
    monitors=$(
        hyprctl -j monitors | jq -c '
map({
    (.name):
    {
        "model": .model | gsub("\\s"; "___"),
        "focused": (.focused and (.disabled | not)),
        "active": .activeWorkspace.name
    }
}) | add'
    )
    hyprctl -j workspaces | jq -c --argjson monitors "$monitors" '
group_by(.monitor) | map($monitors[.[0].monitor] as $monitor | {
    ($monitor.model):
    (map({
        name,
        urgent: false,
        visible: ($monitor.active == .name),
        focused: ($monitor.focused and ($monitor.active == .name)),
    }) | sort_by(.name))
}) | add
'
done
