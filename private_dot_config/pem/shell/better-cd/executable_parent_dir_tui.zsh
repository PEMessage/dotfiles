
parent_dir_tui_func() {
    local selected_dir="$(fzy_parent_dir "$(pwd)")"

    # Check if fzy_parent_dir succeeded and returned a non-empty directory
    if [[ $? -eq 0 && -n "$selected_dir" && -d "$selected_dir" ]]; then
        cd  "${selected_dir}"
        zle reset-prompt
    else
        zle reset-prompt
    fi
}

zle -N parent_dir_tui_func

bindkey '^[[1;3D' parent_dir_tui_func
