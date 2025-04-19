subscribe() {
    pattern="$1"

    next_trigger=0
    (
        echo initial
        socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
    ) | while IFS='' read line; do
        if [[ ! ($line == "initial" || $line =~ $pattern) ]]; then
            continue
        fi
        echo "$next_trigger"
        next_trigger=$((next_trigger + 1))
    done
}
