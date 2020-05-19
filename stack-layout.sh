#!/bin/sh
# stack layout for bspwm
# based on: https://www.reddit.com/r/bspwm/comments/euq5r7/a_dwmlike_stack_layout_script_for_bspwm/
# credits to w0ntfix (https://www.reddit.com/user/w0ntfix)

master_scale=0.6

check_desktop() {
    touch "$BSPWM_STACK_GLOBAL"
    manage_desktop="$(cat $BSPWM_STACK_GLOBAL)"
    current_desktop="$(bspc query -D "$1" -d --names)"
    case "$manage_desktop" in
        *"$current_desktop"*) echo "1";;
    esac
}

set_master() {
    win_count="$(bspc query -N "@$1:/1" -n .descendant_of.window | wc -l)"
    if [ "$win_count" -gt 1 ]; then
        new_master="$(bspc query -N "@$1:/1" -n .descendant_of.window | \
            head -n 1)"
    fi
    if [ "$new_master" != "" ]; then
        for wid in $(bspc query -N "@$1:/1" -n .descendant_of.window | \
            grep -v "$new_master"); do

            bspc node "$wid" -n "@$1:/2"
        done
        bspc node "$new_master" -n "@$1:/1"
    fi
}

correct_rotation() {
    node="$1"
    want="\"$2\""
    have="$(bspc query -T -n "$node" | jq ".splitType")"

    if [ ! "$have" = "$want" ]; then
        bspc node "$node" -R 270
    fi
}

arrange_stack() {
    stack_node="$(bspc query -N "@$1:/2" -n)"

    for parent in $(bspc query -N "@$1:/2" -n .descendant_of.!window | \
        grep -v "$stack_node"); do

        correct_rotation "$parent" horizontal
    done
    bspc node "@$1:/2" -B
}

resize_master() {
    mon_width="$(bspc query -T -m | jq ".rectangle.width")"
    want="$(echo "$master_scale" \* "$mon_width" | bc -l | sed 's/\..*//')"
    have="$(bspc query -T -n "@$1:/1" | jq ".rectangle.width")"
    bspc node "@$1:/1" --resize right $((want - have)) 0
}

bspc subscribe node_remove node_add | while read -r node; do
    desktop="$(echo "$node" | awk '{print $3}')"
    if [ "$BSPWM_STACK_GLOBAL" = "" ] || [ "$(check_desktop "$desktop")" = 1 ]; then
        set_master "$desktop"
        arrange_stack "$desktop"
        resize_master "$desktop"
    fi
done
