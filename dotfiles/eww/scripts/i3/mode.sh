#!/bin/bash

(
    echo initial
    i3-msg -t subscribe -m '[ "mode" ]'
) | while IFS='' read line; do
    i3-msg -t get_binding_state | jq -c '.visible = (.name != "default")'
done
