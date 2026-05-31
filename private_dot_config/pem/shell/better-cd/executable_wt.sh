#!/usr/bin/env bash

# Modify from: https://github.com/yankeexe/git-worktree-switcher
wt() {
    # local VERSION="0.1.2"
    # local TMP_PATH=$(mktemp)
    # local BINARY_PATH=$(which wt 2>/dev/null || echo "")
    # local JQ_URL="https://stedolan.github.io/jq/download"
    # local RELEASE_URL="https://github.com/yankeexe/git-worktree-switcher/releases/latest"
    # local RELEASE_API_URL="https://api.github.com/repos/yankeexe/git-worktree-switcher/releases/latest"
    local is_interactive=false
    local directory=""

    if [ $# -eq 0 ]; then
        set -- '-i'
    fi

    # Parse arguments for interactive flag
    for arg in "$@"; do
        if [[ "$arg" == "-i" ]]; then
            if command -v fzf &> /dev/null; then
                is_interactive=true
            else
                echo "Error: fzf is not installed for interactive mode"
                echo "Install from: https://github.com/junegunn/fzf#installation"
                return 1
            fi
            break
        fi
    done

    case "$1" in
        list)
            git worktree list
            return 0;
            ;;
        help)
            echo -e "wt lets you switch between your git worktrees with speed.\n"
            echo "Usage:"
            echo -e "\twt <worktree-name>: search for worktree names and change to that directory."
            echo -e "\twt -i: interactively select a worktree using fzf."
            echo -e "\twt list: list out all the git worktrees."
            echo -e "\twt update: update to the latest release of worktree switcher."
            echo -e "\twt version: show the CLI version."
            echo -e "\twt help: shows this help message."
            return 0
            ;;
        version)
            echo "Version: $VERSION"
            return 0
            ;;
        -)
            local main_worktree=$(git worktree list --porcelain | grep -E 'worktree ' | awk '{print $0; exit}' | cut -d ' ' -f2-)

            if [ -n "$main_worktree" ]; then
                # echo "Changing to main worktree at: $main_worktree"
                wt "$main_worktree"
            fi
            return 0
            ;;
        *)
            # do not return falldown
            ;;
    esac

    local search_term=$(echo "$1" | sed 's/\//\\\//g')

    if [[ "$is_interactive" == true ]]; then
        directory=$(git worktree list --porcelain |
            awk '
                /worktree/ {wt=$2}
                /HEAD/ {hash = substr($2, 1, 7)}
                /branch/ {sub("refs/heads/", "", $2); print wt " [" $2 "]"}
                /detached/ {print wt " [" hash "]"}
            ' |
            fzf --query "" --height=10% --no-multi --exit-0 |
            awk '{print $1}')
    else
        directory=$(git worktree list --porcelain | grep -E 'worktree ' | awk '/'"$search_term"'/ {print; exit}' | cut -d ' ' -f2-)
    fi

    # Change worktree if directory is found
    if [ ! -n "$directory" ]; then
        return 0
    fi

    # Get current directory relative to current worktree root
    local current_dir=$(pwd)
    local current_worktree=$(git rev-parse --show-toplevel)
    local rel_path=""

    # Try to find relative path from current worktree
    if [[ "$current_dir" == "$current_worktree"* ]]; then
        rel_path="${current_dir#$current_worktree}"
        # Remove leading slash if present
        rel_path="${rel_path#/}"
    fi

    # Try to change to the same relative path in the new worktree
    local target_dir="$directory"
    if [ -n "$repl_path" ] ; then
        echo "Changing to: $target_dir"
        cd "$target_dir"
        return 0
    fi

       # Try to preserve relative path if it exists
    local test_path="$rel_path"
    while [ -n "$test_path" ]; do
        if [ -d "$directory/$test_path" ]; then
            target_dir="$directory/$test_path"
            echo "Found path: $test_path"
            break
        fi
        test_path="${test_path%/*}"
    done

    if [ "$target_dir" = "$directory" ] && [ -n "$rel_path" ]; then
        echo "No matching subdirectory found, using worktree root"
    fi

    echo "Changing to: $target_dir"
    cd "$target_dir"
}
