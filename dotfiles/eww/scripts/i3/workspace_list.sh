#!/bin/bash

(
    echo initial # Trigger initial update
    i3-msg -t subscribe -m '[ "workspace" ]'
) | while IFS='' read line; do
    i3-msg -t get_workspaces | jq -c 'group_by(.output) | map({(.[0].output): map({name, focused, urgent, visible})}) | add'
done
