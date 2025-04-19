#!/bin/bash

source "${BASH_SOURCE%/*}/util.sh"

subscribe "^submap" | while IFS='' read line; do
    hyprctl submap | sed -z 's/[[:space:]]*$//' | jq -R --slurp -c '{
    name: .,
    visible: (. != "default")
}'
done
