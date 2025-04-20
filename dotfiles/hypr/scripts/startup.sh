#!/usr/bin/env bash

poll() {
    timeout=$1
    shift
    while ! eval "$@" && ((timeout-- > 0)); do
        sleep 1
    done
    ((!timeout))
}

set -e

# Wait for EWW and Dunst to start (so we have a tray and notifications)
poll 10 '(eww ping && pgrep dunst)' || true
sleep 1

# Actually start the applications
thunderbird &
nm-applet --indicator &
ibus-daemon -r &
spotify &
signal-desktop &
telegram-desktop &
firefox &
nextcloud &
