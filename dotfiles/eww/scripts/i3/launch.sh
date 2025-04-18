#!/bin/bash

TRIGGER_UPDATE_DELAY=1

pipe=$(mktemp -u --suffix=ewwlaunch-XXXXXX)
mkfifo -m 600 "$pipe"

update_bars() {
    if [ $# -ne 2 ]; then
        echo >&2 "Usage: update_bars <prev_outputs> <now_outputs>"
        return 1
    fi
    prev_outputs="$1"
    now_outputs="$2"
    new=$(jq -c -n --argjson prev "$prev_outputs" --argjson now "$now_outputs" '$now - $prev')
    old=$(jq -c -n --argjson prev "$prev_outputs" --argjson now "$now_outputs" '$prev - $now')
    for output in $(echo "$old" | jq -r '.[]'); do
        echo "Removing $output"
        eww close "bar_$output"
    done
    for output in $(echo "$new" | jq -r '.[]'); do
        echo "Adding $output"
        eww open bar --id "bar_$output" --arg "monitor=$output"
    done
}

# Update process
(
    last_updated=-1
    prev_outputs="[]"
    while true; do
        # Non-blocking read, see https://stackoverflow.com/a/6448737/2192641
        read -t "$TRIGGER_UPDATE_DELAY" maybe_trigger <>"$pipe"
        if [ $? -eq 0 ]; then
            last_trigger="$maybe_trigger"
        elif [ "$last_updated" != "$last_trigger" ]; then
            # Timeout, i.e. no new triggers in TRIGGER_UPDATE_DELAY seconds
            now_outputs=$(i3-msg -t get_outputs | jq -c 'map(select(.active == true) | .name)')
            update_bars "$prev_outputs" "$now_outputs"
            prev_outputs="$now_outputs"
            last_updated="$last_trigger"
        fi
    done
) &
trap "echo 'killing bg'; ps -p $!; kill $!" EXIT # Kill the update process when the script exits

next_trigger=0
(
    echo initial # Trigger initial update
    i3-msg -t subscribe -m '[ "output" ]'
) | while IFS='' read line; do
    echo "$next_trigger" >"$pipe"
    next_trigger=$((next_trigger + 1))
done
