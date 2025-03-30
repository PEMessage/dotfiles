local wezterm = require("wezterm")
local act = wezterm.action


local config = {
    -- ==========================
    -- Color and style
    -- ==========================
    font_size = 13.0,

    font = wezterm.font_with_fallback({
        "Cascadia Mono NF",
        -- Fallback fonts if Cascadia Mono NF isn't available
        "Microsoft YaHei UI"
    }),

    default_prog = { 'wsl', '~' },
    cursor_thickness = "200%",
    default_cursor_style = "BlinkingBar",
    colors = {
        cursor_bg = "#FFFFFF",     -- Pure white cursor
        cursor_fg = "#000000",     -- Black text inside cursor (for better visibility)
        cursor_border = "#FFFFFF", -- White cursor border
    },
    color_scheme = 'Campbell (Gogh)',

    mouse_bindings = {

        --  Left + Shift
        {
            event={ Drag ={streak=1, button="Left"}},
            mods="SHIFT",
            action=wezterm.action{ExtendSelectionToMouseCursor = "Cell"},
        },
        {
            event={ Down ={streak=1, button="Left"}},
            mods="SHIFT",
            action=wezterm.action{SelectTextAtMouseCursor = "Cell"},
        },
        {
            event={ Up ={streak=1, button="Left"}},
            mods="SHIFT",
            action=wezterm.action{CompleteSelectionOrOpenLinkAtMouseCursor = "ClipboardAndPrimarySelection"},
        },
        -- Right + Shift
        {
            event={ Down ={streak=1, button="Right"}},
            mods="SHIFT",
            action=wezterm.action{SelectTextAtMouseCursor = "Cell"},
        },
        {
            event={ Up ={streak=1, button="Right"}},
            mods="SHIFT",
            action=wezterm.action{CompleteSelectionOrOpenLinkAtMouseCursor = "ClipboardAndPrimarySelection"},
        },
        -- Right Paste
        {
            event = { Up = { streak = 1, button = "Right" } },
            mods = "NONE",
            action = wezterm.action{  PasteFrom = "Clipboard" },
        },
    },
    launch_menu = {
        -- Default PowerShell (Windows)
        {
            label = "💻 PowerShell",
            args = { "powershell" },
        },
        -- WSL (Ubuntu)
        {
            label = "🐧 WSL",
            args = { "wsl", "~" },
        },
        -- CMD (fallback)
        {
            label = "💻 CMD",
            args = { "cmd.exe" },
        },
    },
}


return config
