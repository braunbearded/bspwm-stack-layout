#!/bin/sh
id=999010

script_name="stack-layout.sh"
exclude="(grep|vim|nano|nvim|EDITOR|toggle-$script_name)"
pids="$(ps -aux | grep "$script_name" | grep -vE "$exclude" | \
    awk '{s = $2 " " s} END {print s}')"

if [ "$pids" = "" ]; then
    message="Stack layout activated (global)"
    if [ "$BSPWM_STACK_GLOBAL" != "" ]; then
        curr_des="$(bspc query -D -d --names)"
        message="Stack layout activated for desktop $curr_des"
        echo "$curr_des" >> "$BSPWM_STACK_GLOBAL"
    fi
    dunstify -r "$id" -i "start" "$message"
    stack-layout.sh &
else
    if [ "$BSPWM_STACK_GLOBAL" != "" ]; then
        managed_desktops="$(cat $BSPWM_STACK_GLOBAL)"
        curr_des="$(bspc query -D -d --names)"

        case "$managed_desktops" in
            *"$curr_des"*) echo "$managed_desktops" | \
                    grep -v "$curr_des" > "$BSPWM_STACK_GLOBAL"
                message="Stack layout deactivated for desktop $curr_des"
                icon="stop"
                bspc node "@$curr_des:/" -E
                [ "$(cat $BSPWM_STACK_GLOBAL | wc -l)" -eq 0 ] && kill $pids;;
            *) echo "$curr_des" >> "$BSPWM_STACK_GLOBAL"
                message="Stack layout activated for desktop $curr_des"
                icon="start";;
        esac
    else
        message="Stack layout deactivated"
        icon="stop"
        bspc node "@$curr_des:/" -E
        kill $pids
    fi
    dunstify -r "$id" -i "$icon" "$message"
fi
