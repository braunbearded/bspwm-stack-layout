#!/bin/sh
# stack layout for bspwm
# based on: https://www.reddit.com/r/bspwm/comments/euq5r7/a_dwmlike_stack_layout_script_for_bspwm/
# credits to w0ntfix (https://www.reddit.com/user/w0ntfix)

master_scale=0.6

check_desktop() {
    touch "$BSPWM_STACK_LAYOUT"
    manage_desktop="$(cat $BSPWM_STACK_LAYOUT)"
    current_desktop="$(bspc query -D "$1" -d --names)"
    case "$manage_desktop" in
        *"$current_desktop"*) echo "1";;
    esac
}

set_master() {
    win_count="$(bspc query -N "@$1:/1" -n .descendant_of.window | wc -l)"
    if [ "$win_count" -ne 1 ]; then
        new_master="$(bspc query -N "@$1:/1" -n .descendant_of.window | \
            head -n 1)"

        if [ -z "$new_master" ]; then
            new_master=$(bspc query -N "@$1:/2" -n last.descendant_of.window | \
                head -n 1)
        fi

        for wid in $(bspc query -N "@$1:/1" -n .descendant_of.window | \
            grep -v "$new_master"); do

            bspc node "$wid" -n "@$1:/2"
        done
        bspc node "$new_master" -n "@$1:/1"
    fi
}

correct_rotation() {
    node="$1"
    want="$2"
    have="$(bspc query -T -n "$node" | grep -o 'splitType":"[a-z]*' | head -1 | cut -c 13-)"

    if [ ! "$have" = "$want" ]; then
        bspc node "$node" -R 270
    fi
}

arrange_stack() {
    correct_rotation "@$1:/" vertical
    correct_rotation "@$1:/2" horizontal

    stack_node="$(bspc query -N "@$1:/2" -n)"

    for parent in $(bspc query -N "@$1:/2" -n .descendant_of.!window | \
        grep -v "$stack_node"); do

        correct_rotation "$parent" horizontal
    done
    bspc node "@$1:/2" -B
}

resize_master() {
    mon_width="$(bspc query -T -m | grep -o 'width":[0-9]*' | head -1 | cut -c 8-)"
    want="$(echo "$master_scale" \* "$mon_width" | bc -l | sed 's/\..*//')"
    have="$(bspc query -T -n "@$1:/1" | grep -o 'width":[0-9]*' | head -1 | cut -c 8-)"
    bspc node "@$1:/1" --resize right $((want - have)) 0
}

bspc subscribe node_remove node_add | while read -r node; do
    desktop="$(echo "$node" | awk '{print $3}')"
    if [ "$BSPWM_STACK_LAYOUT" = "" ] || \
        [ "$(check_desktop "$desktop")" = 1 ]; then

        event="$(echo "$node" | awk '{print $1}')"
        w_id="$(echo "$node" | awk '{print $4}')"
        [ "$event" = "node_add" ] && w_id="$(echo "$node" | awk '{print $5}')"

        w_state="$(bspc query -T -n "$w_id" | grep -o 'state":"[a-z]*' | cut -c 9-)"

        if [ "$w_state" != "floating" ]; then
            set_master "$desktop"
            arrange_stack "$desktop"
            resize_master "$desktop"
        fi
    fi
done
