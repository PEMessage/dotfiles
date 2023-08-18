
if [ -n "$BASH_VERSION" ]; then

    __fzfcmd() {
        [[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
            echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
    }

    __fzf_history__() {
        local output opts script
        opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
        script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
        output=$(
        builtin fc -lnr -2147483648 |
            last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e "$script" |
            FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) --query "$READLINE_LINE"
                    ) || return
                    READLINE_LINE=${output#*$'\t'}
                    if [[ -z "$READLINE_POINT" ]]; then
                        echo "$READLINE_LINE"
                    else
                        READLINE_POINT=0x7fffffff
                    fi
    }

    # Required to refresh the prompt after fzf
    bind -m emacs-standard '"\er": redraw-current-line'

    bind -m vi-command '"\C-z": emacs-editing-mode'
    bind -m vi-insert '"\C-z": emacs-editing-mode'
    bind -m emacs-standard '"\C-z": vi-editing-mode'

    if (( BASH_VERSINFO[0] < 4 )); then
        # CTR  # CTRL-R - Paste the selected command from history into the command line
      bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u"$(__fzf_history__)"\e\C-e\er"'
      bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
      bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
    else
      # CTRL-R - Paste the selected command from history into the command line
      bind -m emacs-standard -x '"\C-r": __fzf_history__'
      bind -m vi-command -x '"\C-r": __fzf_history__'
      bind -m vi-insert -x '"\C-r": __fzf_history__'
    fi

fi
