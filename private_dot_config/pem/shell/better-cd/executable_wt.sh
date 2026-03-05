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

    # Internal functions
    __wt_internal_worktree_list() {
        git worktree list
    }

    __wt_internal_help_message() {
        echo -e "wt lets you switch between your git worktrees with speed.\n"
        echo "Usage:"
        echo -e "\twt <worktree-name>: search for worktree names and change to that directory."
        echo -e "\twt -i: interactively select a worktree using fzf."
        echo -e "\twt list: list out all the git worktrees."
        echo -e "\twt update: update to the latest release of worktree switcher."
        echo -e "\twt version: show the CLI version."
        echo -e "\twt help: shows this help message."
    }

    __wt_internal_goto_main_worktree() {
        local main_worktree=$(git worktree list --porcelain | grep -E 'worktree ' | awk '{print $0; exit}' | cut -d ' ' -f2-)

        if [ -n "$main_worktree" ]; then
            echo "Changing to main worktree at: $main_worktree"
            cd "$main_worktree"
        fi
    }


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

    # Main logic
    if [ $# -eq 0 ]; then
        __wt_internal_help_message
        return 0
    fi

    case "$1" in
        list)
            __wt_internal_worktree_list
            ;;
        help)
            __wt_internal_help_message
            ;;
        version)
            echo "Version: $VERSION"
            ;;
        -)
            __wt_internal_goto_main_worktree
            return 0
            ;;
        *)
            # Escape forward slash for grep
            local search_term=$(echo "$1" | sed 's/\//\\\//g')

            if [[ "$is_interactive" == true ]]; then
                directory=$(git worktree list --porcelain |
                awk '/worktree/ {wt=$2} /branch/ {sub("refs/heads/", "", $2); print wt " [" $2 "]"}' |
                fzf --query "" --height=10% --no-multi --exit-0 |
                awk '{print $1}')
            else
                directory=$(git worktree list --porcelain | grep -E 'worktree ' | awk '/'"$search_term"'/ {print; exit}' | cut -d ' ' -f2-)
            fi

            # Change worktree if directory is found
            if [ -n "$directory" ]; then
                echo "Changing to worktree at: $directory"
                cd "$directory"
            fi
            ;;
    esac
}
