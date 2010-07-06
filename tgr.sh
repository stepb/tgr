#!/bin/bash
#
# TODO describe
#
# Copyright (c) 2010 stepb <mail4stb@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Library General Public License as published
# by the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

###################################
### General functions           ###
###################################

usage() {
    echo "usage: `basename $0` -s | --sync  [<commit-message>]"
    exit 1
}

error_if_not_inside_work_tree() {
    if [ "$(git rev-parse --is-inside-work-tree)" != "true" ]; then
        echo " You do not appear to be inside a git working tree!"
        exit 1
    fi
}

cd_to_top_level() {
    cd "$(git rev-parse --show-cdup)"
}

git_fetch_and_maybe_rebase() {
    if git fetch 2>&1 | grep '.\+'; then
        git rebase origin/master || return 1
    fi
}

###################################
### Top level functions         ###
###################################

## [<commit-message>]
tgr_sync() {
    error_if_not_inside_work_tree
    cd_to_top_level
    if ! git status --porcelain | grep '.\+'; then
       ## no local mods
        if ! git branch | grep '.\+' ||
            ! git log origin/master...HEAD 2>&1 | grep '.\+'; then
           ## no local commits
            if git fetch 2>&1 | grep '.\+'; then
                git pull || exit 1
            else
                echo " Nothing to sync!"
            fi
        else
           ## local commits
            git_fetch_and_maybe_rebase || exit 1
            git push origin master || exit 1
        fi
    else
       ## local mods
        git add -A || exit 1
        [ "$1" ] && local cmsg="$1" || local cmsg="`date`"
        git commit -m "$cmsg" || exit 1
        git_fetch_and_maybe_rebase || exit 1
        git push origin master || exit 1
    fi
}

while [ "$1" ]; do
    case "$1" in
        -s|--sync )
            tgr_sync "$2"
            exit 0;;
        * ) usage;;
    esac
done

exit 0
