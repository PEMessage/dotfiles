
# - set is the alias of set-option
# - setw is the alias of set-window-option
# See: https://github.com/zaiste/tmuxed.git

# --------------------------------
# Basic Setting Zone
# --------------------------------
    set -g base-index 1 # 设置窗口的起始下标为1
    set -g pane-base-index 1 # 设置面板的起始下标为1
    set-window-option -g automatic-rename on # 自动重命名
    # set-option -g renumber-windows on 

    # Ture Color support
    # set -g default-terminal "xterm-256color"
    # set -as terminal-overrides ",xterm*:Tc"

    # Thanks to: https://github.com/vercel/hyper/issues/3338#issuecomment-469089888
    bind-key -T copy-mode-vi WheelUpPane send -N3 -X scroll-up
    bind-key -T copy-mode-vi WheelDownPane send -N3 -X scroll-down


    # See: https://github.com/tmux/tmux/wiki/FAQ#how-do-i-use-a-256-colour-terminal
    set -g default-terminal "screen-256color"
    # # all term outside 
    set-option -ga terminal-overrides ',*-256color*:Tc'
    set-option -ga terminal-overrides ',*-256color*:RGB'

    # sync: Bracketed Synchronized Output
    #       to avoid neovim cursor blinking during ui update
    # Using `tmux display -p "#{client_termfeatures}"`
    # `tmux show-option -s terminal-features` to checking
    set -as terminal-features ',xterm*:Sync'

    # Override terminal capabilities to forward cursor-shape escape sequences.
    # Fixes Vim/Neovim cursor not changing on mode switch.
    # Work on tmux v2.6 but not v3.7c
    # Ss = set cursor style (CSI Ps SP q)
    #   \E[ = ESC [ (CSI)
    #   %p1%d = print first argument (style number: 1-6)
    #   ' q' = space + q (required by ANSI)
    # Se = reset to steady block (CSI 2 SP q)
    # !!! REMOVE !!!: DUE TO ISSUE ON OLD DISTRO
    # set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'

    set -g extended-keys on


    # From: tmux-plugins/tmux-sensible
    set-option -g history-limit 50000

    # Title
    set -g set-titles off
    # set -g set-titles-string '#(whoami)@#H:#W(#S)'

    # Clock
    set -g clock-mode-style 24
    set -g clock-mode-colour white

    set -g xterm-keys on

    run-shell "tmux setenv -g TMUX_VERSION $(tmux -V | grep -o '[0-9]\\\+\\\.[0-9]*')"

    # fix opencode esc not work !
    set-option -g escape-time 10

# --------------------------------
# Basic Key map
# --------------------------------
    # misc map
    # ----------------------------
    if-shell "test -e ~/.tmux.conf" \
    'bind r source-file ~/.tmux.conf \; display "Reload!"' \
    'bind r source-file ~/.config/tmux/tmux.conf \; display "Reload!"'
    # if-shell 'test -e ~/.tmux.conf' \
    # 'bind r source-file ~/.tmux.conf \; display "Reload!"' \
    # 'bind r source-file ~/.config/tmux/tmux.conf \; display "Reload!"'

    bind R move-window -r \; display-message "Windows renumbered"

    # Sort all tmux window
    bind s                                      \
        set -g renumber-windows on\;            \
        new-window\; kill-window\;              \
        set -g renumber-windows off\;           \
        display-message "Windows reordered..."
    bind 0 \
        set-window-option synchronize-panes\; \
        display-message "synchronize-panes is now #{?pane_synchronized,on,off}"

    bind j \
        send-keys -R\; \
        display-message "Clear!"
    bind ` \
        send-keys -R\; \
        clear-history\; \
        display-message "Clear All!"

    set -g focus-events on

    # copy mode 
    # ----------------------------
    # bind P paste-buffer
    # bind C-v paste-buffer
    # bind -n C-M-v copy-mode

    # Trouble shooting with `tmux bind -n TheKey lsk`
    # https://github.com/tmux/tmux/wiki/Modifier-Keys
    bind ] paste-buffer -p # prevent run command

    bind -n C-M-o paste-buffer -p
    bind -n M-O paste-buffer -p

    # NOTE !!! Will cause nvim random input at Start not using it !!!
    # NOTE !!! Will cause nvim random input at Start not using it !!!
    # ===============================================================
    # bind -n M-P paste-buffer -p
    # bind -n M-S-DC paste-buffer -p
    # ===============================================================
    bind -n C-M-p command-prompt # maybe this is safe?


    # Thanks to https://www.reddit.com/r/commandline/comments/8wv0w6/interactively_moving_panes_to_other_windows/?tl=zh-hans
    bind-key M choose-tree -Zw "join-pane -t '%%'"
    bind-key C-m choose-tree -Zs "join-pane -t '%%'"


    # Credit: https://stackoverflow.com/questions/12524308/bash-strip-trailing-linebreak-from-output

    bind -n M-I \
        run-shell "echo '#{pane_current_path}'  | sed -Ez '\$ s/\\n+$//' | tmux load-buffer -" \; \
        display "Copy to buffer: '#{pane_current_path}'"
    bind -n C-M-i \
        run-shell "echo '#{pane_current_path}'  | sed -Ez '\$ s/\\n+$//' | tmux load-buffer -" \; \
        display "Copy to buffer: '#{pane_current_path}'"


    bind -n C-M-b choose-buffer # yank ring
    bind -n C-M-z resize-pane -Z # yank ring

    bind-key v select-layout even-horizontal
    bind-key h select-layout even-vertical

    # vi copy mode
    # ----------------------------
    # setw -g mode-keys vi 
    set-window-option -g mode-keys vi # 开启vi风格后，支持vi的C-d、C-u、hjkl等快捷键

    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

    # exit copy mode after 'y'
    bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 
    # bind-key -T copy-mode-vi y send-keys -X copy-selection

    # prevent tmux from exiting copy mode after selection with mouse
    # Credit: https://dabase.com/tips/shell/2022/Tmux-configuration/
    unbind -Tcopy-mode MouseDragEnd1Pane
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection
    bind-key -T copy-mode-vi MouseDown2Pane paste-buffer -p

    # another setup by may report error 
    # ----------------------------
    # bind -n vi-copy v begin-selection # 绑定v键为开始选择文本
    # bind -n vi-copy y copy-selection # 绑定y键为复制选中文本
    # bind-key -T copy-mode-vi 'v' send -X begin-selection
    # bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
    # bind-key -t vi-copy 'v' begin-selection
    # bind-key -t vi-copy 'y' copy-selection

# --------------------------------
# Fast window navigation
# --------------------------------
    bind -n C-M-h select-pane -L
    bind -n C-M-j select-pane -D
    bind -n C-M-k select-pane -U
    bind -n C-M-l select-pane -R
    # See: https://superuser.com/questions/343572/how-do-i-reorder-tmux-windows
    # bind-key -n T swap-window -t 1
    # bind-key -n C-M-Left swap-window -t -1 \; previous-window
    # bind-key -n C-M-Right swap-window -t +1 \; next-window
    if-shell -b '[ "$(echo "$TMUX_VERSION >= 3.0" | bc)" = 1 ]' " \
        bind-key -n C-M-Left swap-window -t -1 -d ; bind-key -n C-M-Right swap-window -t +1 -d "
    if-shell -b '[ "$(echo "$TMUX_VERSION < 3.0" | bc)" = 1 ]' " \
        bind-key -n C-M-Left swap-window -t -1 ; bind-key -n C-M-Right swap-window -t +1 "

    bind -n C-M-e next-window
    # Credit: https://nju-projectn.github.io/ics-pa-gitbook/ics2023/0.5.html
    bind -n C-M-w new-window -c "#{pane_current_path}" -a -t +1
    bind -n C-M-q previous-window
    
    bind -n C-M-c splitw -h -c '#{pane_current_path}' # 水平方向新增面板，默认进入当前目录
    bind -n C-M-x confirm-before -p "kill-pane #P? (y/n)" kill-pane

# --------------------------------
# Function List
# --------------------------------
    is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'"

    switch_mouse='set -g mouse ; display "Mouse #{?mouse,ON,OFF}!"'
    switch_vim_mouse='send-keys "#{?mouse,a,b}"'

# --------------------------------
# osc 52
# --------------------------------

    if-shell -b '[ "$(echo "$TMUX_VERSION >= 3.3" | bc)" = 1 ]' " \
        set-window-option -g allow-passthrough on "


    # transfer copied text to attached terminal with yank
    # transfer most-recently copied text to attached terminal with yank
    # transfer previously copied text (chosen from a menu) to attached terminal
    if-shell -b '[ "$(echo "3.3 > $TMUX_VERSION  &&  $TMUX_VERSION >= 2.4" | bc)" = 1 ]' " \
        bind-key -T copy-mode-vi Y send-keys -X copy-pipe 'yank > #{pane_tty}' ; \
        bind-key -n M-y run-shell 'tmux save-buffer - | yank > #{pane_tty}' ; \
        bind-key -n M-Y choose-buffer 'run-shell tmux save-buffer -b \"%%%\" - | yank > #{pane_tty}'"


# --------------------------------
# Mouse support
# --------------------------------
    # mouse support
    set-option -g mouse on
    # bind-key -n C-M-m run-shell 'tmux-toggle-mouse toggle #{pane_tty}'
    # https://superuser.com/a/1858501
    set -s command-alias[10] toggle-mouse="run-shell \"tmux-toggle-mouse toggle #{pane_tty}\""
    bind-key -n C-M-r run-shell 'tmux-edit-history'
    # bind-key -n C-M-i run-shell 'tmux-debug #{pane_tty}'



# --------------------------------
# vim-tmux-navigator
# --------------------------------
# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator

    bind-key -n 'M-H' if-shell "$is_vim" 'send-keys M-H'  'select-pane -L'
    bind-key -n 'M-J' if-shell "$is_vim" 'send-keys M-J'  'select-pane -D'
    bind-key -n 'M-K' if-shell "$is_vim" 'send-keys M-K'  'select-pane -U'
    bind-key -n 'M-L' if-shell "$is_vim" 'send-keys M-L'  'select-pane -R'

    bind-key -n 'M-X' if-shell "$is_vim" 'send-keys M-X'  'confirm-before -p "kill-pane #P? (y/n)" kill-pane'
    bind-key -n 'M-C' if-shell "$is_vim" 'send-keys M-C'  'split-window -h -c "#{pane_current_path}"'

    tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
    if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'M-\\' if-shell \"$is_vim\" 'send-keys M-\\'  'select-pane -l'"
    if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'M-\\' if-shell \"$is_vim\" 'send-keys M-\\\\'  'select-pane -l'"

    # Credit: https://hackmd.io/@DailyOops/persistent-tmux-popup?type=view
    # Credit: https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
    bind -n "C-M-t" if-shell 'case "$(tmux display-message -p #S)" in float* ) exit 0;; *) exit 1;; esac ; ' \
        "detach-client" \
        "run-shell 'tmux-popup'"

# --------------------------------
# Statue Line Theme(Onedrak)
# --------------------------------
    # This tmux statusbar config was created by tmuxline.vim
    # on Thu, 15 Jun 2023
    # See: https://coolors.co/palette/cae5ff-acedff-89bbfe-6f8ab7-615d6c
    set -g status-justify "left"
    set -g status "on"
    set -g status-left-style "none"
    set -g status-right-style "none"
    set -g status-right-length "100"
    set -g status-left-length "100"
    set -g status-style "none,bg=#252525"
    set -g status-left "#[fg=#252525,bg=#89bbfe] #h #[fg=#89bbfe,bg=#252525,nobold,nounderscore,noitalics]"
    set -g status-right "#[fg=#3b3b3b,bg=#252525,nobold,nounderscore,noitalics]#[fg=#a1b7cc,bg=#3b3b3b] %Y-%m-%d | %H:%M #[fg=#89bbfe,bg=#3b3b3b,nobold,nounderscore,noitalics]#[fg=#252525,bg=#89bbfe] #S "


    # https://raw.githubusercontent.com/tmux/tmux/3.7/CHANGES
    # Since 3.7:
    #   In the command prompt (C-b :) and message line,
    #   the background is by default drawn only behind the text itself;
    #   it fills the entire line width only
    #   if fill= is explicitly added (see the CHANGES entry for tmux 3.7, commit 19f3fb1).
    set -g message-command-style "fg=#a1b7cc,bg=#3b3b3b,fill=#3b3b3b"
    set -g message-style "fg=#a1b7cc,bg=#3b3b3b,fill=#3b3b3b"


    set -g pane-border-style "fg=#3b3b3b"
    set -g pane-active-border-style "fg=#89bbfe"

    # setw -g window-status-activity-style "none"
    # setw -g window-status-style "none,fg=#777777,bg=#252525"
    # setw -g window-status-format "#[fg=#777777,bg=#252525] #I |#[fg=#777777,bg=#252525] #W "
    # setw -g window-status-current-format "#[fg=#252525,bg=#3b3b3b,nobold,nounderscore,noitalics]#[fg=#a1b7cc,bg=#3b3b3b] #I |#[fg=#a1b7cc,bg=#3b3b3b] #W #[fg=#3b3b3b,bg=#252525,nobold,nounderscore,noitalics]"

    # See: https://tmuxai.dev/tmux-alerts-monitoring/
    setw -g window-status-separator ""

    setw -g window-status-style "fg=#777777,bg=#252525"
    # setw -g window-status-format " #I | #W "
    setw -g window-status-format " #I #{?window_bell_flag,!,|} #W "

    setw -g window-status-current-style "fg=#a1b7cc,bg=#3b3b3b"
    setw -g window-status-current-format " #I | #W "

    set-window-option -g monitor-activity off
    set-window-option -g monitor-bell on
    # set-window-option -g monitor-silence 5

    # setw -g window-status-activity-style "fg=#ff0000,bg=#252525,bold"
    setw -g window-status-bell-style "fg=#ff5555,bg=#252525,bold"
# --------------------------------
# Statue Line Theme(pimux)
# --------------------------------

    # PEM_TMUX_INACTIVITY="#3b3b3b"
    # PEM_INACTIVITY_MINUS="#252525"

    
    # PEM_TMUX_HIGHTLIGHT_PLUS="#a0d0f0"
    # PEM_TMUX_HIGHTLIGHT="#3fcfff"
    # PEM_TMUX_HIGHTLIGHT_MINUS="#32a5cc"

    # PEM_TMUX_HIGHTLIGHT2="#ff7f4b"
    # # Pane
    # set -g pane-border-style "fg=$PEM_TMUX_INACTIVITY"
    # set -g pane-active-border-style "fg=$PEM_TMUX_HIGHTLIGHT_MINUS,bg=default"

    # # Window
    # setw -g window-status-format " #I|#W "
    # setw -g window-status-current-format "  #I|#W  "
    # setw -g window-status-separator ""
    # set-window-option -g monitor-activity on

    # setw -g window-status-current-style "bg=$PEM_TMUX_INACTIVITY,fg=$PEM_TMUX_HIGHTLIGHT_PLUS,bold"
    # # setw -g window-status-activity-style bg=default,fg=$PEM_TMUX_HIGHTLIGHT_PLUS,bold,blink
    # setw -g window-status-style bg=default,fg=$PEM_TMUX_HIGHTLIGHT_PLUS,dim

    # # Status
    # set -g status-position bottom
    # set -g status-left "#[fg=black]#{?client_prefix,#[bg=$PEM_TMUX_HIGHTLIGHT2] ... ,#[bg=$PEM_TMUX_HIGHTLIGHT_PLUS] NOR }"
    # set -g status-right "#[fg=$PEM_TMUX_HIGHTLIGHT_PLUS,dim] %Y-%m-%d | %H:%M | #S:#I.#P | 𝅘𝅥𝅮 "

    # set -g status-style "none,bg=black"

    # # Message(command and echo style)
    # set -g message-style fg=$PEM_TMUX_HIGHTLIGHT,bg=black,bright

    # # Copymode color(default yellow)
    # set -g mode-style bg=$PEM_TMUX_HIGHTLIGHT,fg=black


# --------------------------------
# Plug List
# --------------------------------
     set -g @tpm_plugins '          \
       tmux-plugins/tpm             \
       fcsonline/tmux-thumbs        \
       artemave/tmux_super_fingers  \
    '

       # RTBHOUSE/tmux-picker \
       # ddzero2c/tmux-easymotion \
       # tmux-plugins/tmux-copycat    \
    # Plugin fcsonline/tmux-thumbs
    # ----------------------------
    set -g @thumbs-fg-color green
    set -g @thumbs-hint-fg-color '#d76971'
    set -g @thumbs-select-fg-color '#d76971'
    set -g @thumbs-multi-fg-color '#ffff00'
    # set -g @thumbs-regexp-1 ' (\W+) ' # Match emails
    set -g @thumbs-command 'tmux send-keys "{}"'

    # Plugin tmux-plugins/tmux-copycat
    # ----------------------------
    # This remap not work, I dont why, use M-h instead(default)
    set -g @copycat_hash_search 'C-h'

    # Plugin fmount/tmux-quickfix
       # fmount/tmux-quickfix         \
    # ----------------------------
    # C-b z to open quickfix
    # set -g @quickfix-key `

# --------------------------------
# .tmux.conf ref start
# --------------------------------
    # # source tmux.init
    # if "test -f ~/.config/pem/config/tmux/init.cr" \
    #     "source ~/.config/pem/config/tmux/init.cr"



    # if "test ! -d ~/.config/tmux/plugins/tpm" \
    #    "run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins'"
    # set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.config/tmux/plugins'
    # # # List of plugins
    # # set -g @plugin 'tmux-plugins/tmux-copycat'

        
    # # Initialize TMUX plugin manager 
    # # (keep this line at the very bottom of tmux.conf)
    # run-shell '~/.config/tmux/plugins/tmux-thumbs/tmux-thumbs.tmux'
    # run '~/.config/tmux/plugins/tpm/tpm'
# --------------------------------
# .tmux.conf ref end
# --------------------------------
#
# vim: set syntax=tmux:
