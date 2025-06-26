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

run() {
    if command -v "$1" &>/dev/null; then
        $RUN "$@" &
    fi
}

# Actually start the applications
run thunderbird
run nm-applet --indicator
run spotify
run signal-desktop
run Telegram
run firefox
run nextcloud
run slack
