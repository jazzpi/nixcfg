#!/bin/bash

source "${BASH_SOURCE%/*}/util.sh"

subscribe "^(focusedmon|workspace|destroyworkspace)" | while IFS='' read line; do
    monitors=$(
        hyprctl -j monitors | jq -c '
map({
    (.id | tostring):
    {
        "focused": (.focused and (.disabled | not)),
        "active": .activeWorkspace.name
    }
}) | add'
    )
    # echo "$monitors"
    hyprctl -j workspaces | jq -c --argjson monitors "$monitors" '
group_by(.monitorID) | map({
    (.[0].monitorID | tostring):
    map($monitors[.monitorID | tostring] as $monitor | {
        name,
        urgent: false,
        visible: ($monitor.active == .name),
        focused: ($monitor.focused and ($monitor.active == .name)),
    })
}) | add
'
done
