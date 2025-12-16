
parent_dir_tui_func() {
    local selected_dir="$(parent_dir_tui "$(pwd)")"

    # Check if fzy_parent_dir succeeded and returned a non-empty directory
    if [[ $? -eq 0 && -n "$selected_dir" && -d "$selected_dir" ]]; then
        cd "${selected_dir}"
        echo "cd \"${selected_dir}\""
        zle accept-line
    else
        zle reset-prompt
    fi
}

zle -N parent_dir_tui_func
bindkey '^[[1;3D' parent_dir_tui_func


insert-cd-back-and-complete() {
    BUFFER="cd -"
    CURSOR=$#BUFFER  # Move cursor to end
    zle -R           # Refresh the line
    zle expand-or-complete  # Trigger completion
}

zle -N insert-cd-back-and-complete
bindkey '^[[1;3C' insert-cd-back-and-complete
