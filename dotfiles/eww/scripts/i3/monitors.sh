#!/bin/bash

(
    echo initial # Trigger initial update
    i3-msg -t subscribe -m '[ "output" ]'
) | while IFS='' read line; do
    i3-msg -t get_outputs | jq -c 'map(select(.active == true) | {(.name): {primary, current_workspace}}) | add'
done
