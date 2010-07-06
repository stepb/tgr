#!/bin/bash

testdir="$PWD/`dirname $0`/.."
tgr="$testdir/../tgr.sh"
res="$testdir/res"
work="$testdir/work"

curtest=

###################################
### Test preparation functions  ###
###################################

clean_arg() {
    rm -rf "$1"
    mkdir -p "$1"
}

create_res() {
    [ -e "$res" ] && clean_arg "$res"
    pushd "$res"
    git init --bare proj.git
    popd
}

pre_test() {
    [ ! -e "$res" ] && echo "pre_test: \`$res' doesn't exist" && exit 1
    [ -e "$work" ] && clean_arg "$work"
    cp -r "$res"/* "$work"
    pushd "$work" > /dev/null
    git clone proj.git proj-c1 > /dev/null 2>&1
    git clone proj.git proj-c2 > /dev/null 2>&1
    popd > /dev/null
}

###################################
### Test helper functions       ###
###################################

begin_test() {
    pre_test
    curtest="$1"
    echo -e "\e[1m $curtest\e[0m"
    cd "$work"
}

fail_test() {
    echo -e "\e[1;31m Failed: $curtest\e[0m"
    exit 1
}

## <location> <work-file> <work-str>
do_work() {
    echo "$3" > "$1/$2"
}

## <location> <work-file> <work-str>
do_work_commit_and_push() {
    do_work "$@"
    pushd "$1" > /dev/null
    git add "$2"
    git commit -m "work" > /dev/null
    git push origin master > /dev/null 2>&1
    popd > /dev/null
}

###################################
### Tests                       ###
###################################

sync_nothing_to_sync_test() {
    begin_test "sync_nothing_to_sync_test"
    cd proj-c1
    "$tgr" -s || fail_test
}

sync_no_local_mods_test() {
    begin_test "sync_no_local_mods_test"
    do_work_commit_and_push proj-c2 c2.work "work work work"
    cd proj-c1
    "$tgr" -s || fail_test
}

sync_local_mods_nothing_to_sync_test() {
    begin_test "sync_local_mods_nothing_to_sync_test"
    do_work proj-c1 c1.work "work work work"
    cd proj-c1
    "$tgr" -s || fail_test
}

sync_local_mods_test() {
    begin_test "sync_local_mods_test"
    do_work_commit_and_push proj-c2 c2.work "work work work"
    do_work proj-c1 c1.work "work work work"
    cd proj-c1
    "$tgr" -s || fail_test
}

sync_commits_no_local_mods_nothing_to_sync_test() {
    begin_test "sync_commits_no_local_mods_nothing_to_sync_test"
    do_work proj-c1 c1.work "work work work"
    cd proj-c1
    git add c1.work
    git commit -m "work" > /dev/null
    "$tgr" -s || fail_test
}

create_res
sync_nothing_to_sync_test
sync_no_local_mods_test
sync_local_mods_nothing_to_sync_test
sync_local_mods_test
sync_commits_no_local_mods_nothing_to_sync_test
