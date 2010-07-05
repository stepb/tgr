#!/bin/bash

path="`dirname $0`"
for arg in "$path/tgr" "$path/tgr.sh"; do
    [ -e "$arg" ] && tgr="$arg"
done
[ ! "$tgr" ] && echo " Could not find tgr.sh" && exit 1

"$tgr" -s "$@"
