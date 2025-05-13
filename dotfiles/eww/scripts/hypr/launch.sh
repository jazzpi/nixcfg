#!/usr/bin/env bash

TRIGGER_UPDATE_DELAY=1

pipe=$(mktemp -u --suffix=ewwlaunch-XXXXXX)
mkfifo -m 600 "$pipe"

sanitize_model_name() {
    if [ $# -ne 1 ]; then
        echo >&2 "Usage: sanitize_model_name <output>"
        return 1
    fi
    echo "{}" | jq -r --arg o "$1" '$o | gsub("\\s"; "___")'
}

update_bars() {
    if [ $# -ne 2 ]; then
        echo >&2 "Usage: update_bars <prev_outputs> <now_outputs>"
        return 1
    fi
    prev_outputs="$1"
    now_outputs="$2"
    new=$(jq -c -n --argjson prev "$prev_outputs" --argjson now "$now_outputs" '$now - $prev')
    old=$(jq -c -n --argjson prev "$prev_outputs" --argjson now "$now_outputs" '$prev - $now')
    echo "$old" | jq -r '.[]' | while IFS='' read output; do
        output=$(sanitize_model_name "$output")
        echo "Removing $output"
        eww close "bar_$output"
    done
    echo "$new" | jq -r '.[]' | while IFS='' read output; do
        echo "Adding $output"
        width=$(hyprctl monitors -j | jq -r --arg output "$output" '.[] | select(.model == $output) | .width / .scale')
        output=$(sanitize_model_name "$output")
        eww open bar --id "bar_$output" --arg "monitor=$output" --arg "width=${width}px" # --screen "$output"
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
            now_outputs=$(hyprctl monitors -j | jq -c 'map(select(.disabled == false) | .model)')
            update_bars "$prev_outputs" "$now_outputs"
            prev_outputs="$now_outputs"
            last_updated="$last_trigger"
        fi
    done
) &
trap "echo 'killing bg'; ps -p $!; kill $!" EXIT # Kill the update process when the script exits

source "${BASH_SOURCE%/*}/util.sh"

subscribe "^monitor" >"$pipe"
# next_trigger=0
# (
#     echo initial # Trigger initial update
#     socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
# ) | while IFS='' read line; do
#     if [[ line == "initial" || line =~ "monitor*" ]]; then
#         continue
#     fi
#     echo "$next_trigger" >"$pipe"
#     next_trigger=$((next_trigger + 1))
# done
