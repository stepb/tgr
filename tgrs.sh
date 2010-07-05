#!/bin/bash

path="`dirname $0`"
[ -e "$path/tgr.sh" ] && tgr="$path/tgr.sh" ||
    [ -e "$path/tgr" ] && tgr="$path/tgr" ||
        echo " Could not find tgr.sh" && exit 1
"$tgr" -s "$@"
