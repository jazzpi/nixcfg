#!/bin/bash
exit 1

subscribe_monitors | while IFS='' read line; do
    hyprctl -j monitors | jq -c 'map(select(.disabled == false) | {(.name): {primary, current_workspace}}) | add'
done
