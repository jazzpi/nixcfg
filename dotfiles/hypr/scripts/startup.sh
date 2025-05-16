#!/usr/bin/env bash

# TODO: Replace with systemd units that require eww & dunst to have been started

RUN="uwsm app --"

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
$RUN thunderbird &
$RUN nm-applet --indicator &
$RUN ibus-daemon -r &
$RUN spotify &
$RUN signal-desktop &
$RUN telegram-desktop &
$RUN firefox &
$RUN nextcloud &
