#!/bin/bash



# debug
# jq '[ to_entries[] | select(.value.path[0] | test("pinpad/")) ]  | first ' module-info.json


tcd() {
    local target="$1"
    local current_dir="$(pwd)"

    while [ "$current_dir" != "/" ]; do
        if [ -e "$current_dir/$target" ]; then
            cd "$current_dir"
            return 0
        # elif [ "$(basename "$current_dir")" = "$target" ] ; then
        #     cd "$current_dir"
        #     return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    echo "No parent directory containing $target found; staying in $(pwd)."
    return 1
}

run() {
    file=$1
    regex=$2
    jq --arg regex "$regex" \
    '
    [
        to_entries[] |
        select(any(.value.path[]; test($regex))) |
        select(.value.class[] == "SHARED_LIBRARIES") 
    ]  as $list  |
        # $list
       "Ninja Module: \n\n" +
       ([ $list[] | .key ] | join(" ") )  +
       "\n\n",

       "Bash Module: \n\n{" +
       ([ $list[] | .key + ".so" ] | join(",") )  +
       "}\n\n"

    ' "$file" --raw-output
}

if [ $# -eq 1 ]; then
    file=auto
    regex="$1"
else
    file="$1"
    regex="$2"
fi


if [ "$file" = auto ] ; then
    tcd .repo
    files="$(find out/target/product -maxdepth 2 -name 'module-info.json')"
    for f in $files
    do
        echo "File: $f"
        echo
        run "$f" "$regex"
    done
else 
    run "$file" "$regex"
fi
