# Bspwm stack layout
You like bswpm but you are really missing a master and stack layout? Then
checkout this repo.

## Description
The main part of this repo is stack-layout.sh. The script subscripts to node_add and
node_remove events and performs based on the node some window resizeing or/and
moving operation on it. This script is pretty much a copy from this
[reddit post](https://www.reddit.com/r/bspwm/comments/euq5r7/a_dwmlike_stack_layout_script_for_bspwm/)
from reddit user [w0ntfix](https://www.reddit.com/user/w0ntfix).

Some stuff I changed/added:
- fully posix compliant
- fix floating windows bug
- stack-layout per desktop option
- toggle script

Check out toggle-stack-layout.sh if you want to toggle stack-layout.sh

## Installation
Put toggle-stack-layout.sh and stack-layout.sh somewhere in your path, so that
you are able to run it from anywhere.

### Dependencies
- bspwm
- awk
- dunst(ify)
- bc

### Settings
To enable "per desktop" option, just set BSPWM_STACK_LAYOUT Variable like so:

```
export BSPWM_STACK_LAYOUT="/tmp/manage-stack-desktop"
```

This file contains just the desktop names.

# Credits
[w0ntfix](https://www.reddit.com/user/w0ntfix)
[reddit post](https://www.reddit.com/r/bspwm/comments/euq5r7/a_dwmlike_stack_layout_script_for_bspwm/)

# Todo
This is script is far from perfect so if you have any questions or wishes,
let me know.
- improve performance
- set/save master width per desktop?

