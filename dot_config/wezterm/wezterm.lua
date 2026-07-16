-- ============================================================
--  WezTerm Configuration (Fully Structured)
--  Common settings + platform-specific overrides
-- ============================================================

local wezterm = require("wezterm")  ---@type Wezterm
local act = wezterm.action
local config = wezterm.config_builder() ---@type Config

-- ============================================================
--  1. Common settings (all platforms)
-- ============================================================

-- Appearance
config.font_size = 13.0
config.cursor_thickness = "200%"
config.default_cursor_style = "BlinkingBar"
config.animation_fps = 120
config.color_scheme = 'Campbell (Gogh)'

-- Colors (white cursor)
config.colors = {
    cursor_bg = "#FFFFFF",
    cursor_fg = "#000000",
    cursor_border = "#FFFFFF",
}

-- Global key bindings
config.keys = {
    { key = 'P', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
}

config.skip_close_confirmation_for_processes_named = {
    'bash',
    'sh',
    'zsh',
    'fish',
    'tmux',
    'cmd.exe'
}

-- ------------------------------------------------------------
--  2. KeyMap
-- ------------------------------------------------------------

local function pane_right_click(window, pane)
    local has_selection = window:get_selection_text_for_pane(pane) ~= "" or
                          window:get_selection_escapes_for_pane(pane) ~= ""
    if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
    else
        window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
    end
end

-- Mouse bindings (Shift+left click selection, right click copy/paste)
config.mouse_bindings = {
    -- Left click + Shift: Cell selection
    {
        event = { Down = { streak = 1, button = "Left" } },
        mods = "SHIFT",
        action = act { SelectTextAtMouseCursor = "Cell" },
    },
    {
        event = { Drag = { streak = 1, button = "Left" } },
        mods = "SHIFT",
        action = act { ExtendSelectionToMouseCursor = "Cell" },
    },
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "SHIFT",
        action = act { CompleteSelectionOrOpenLinkAtMouseCursor = "ClipboardAndPrimarySelection" },
    },
    -- Right click (with or without Shift): calls pane_right_click function
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "SHIFT",
        action = wezterm.action_callback(pane_right_click),
    },
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = wezterm.action_callback(pane_right_click),
    },
}

local function newtab_menu(window, pane)
    local choices = {}
    local all_domains = wezterm.mux.all_domains()

    for _, domain in ipairs(all_domains) do
        table.insert(choices, {
            label = domain:label(),
            id = domain:name(),
        })
    end

    window:perform_action(
        wezterm.action.InputSelector {
            title = "New Shell",
            choices = choices,
            fuzzy = false,
            action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
                if id then
                    inner_window:perform_action(
                        wezterm.action.SpawnCommandInNewTab {
                            domain = { DomainName = id }
                        },
                        inner_pane
                    )
                end
            end),
        },
        pane
    )
end

wezterm.on('new-tab-button-click', function(
    window,
    pane,
    button,
    _ -- default_action
)
    if button == 'Right' then
        newtab_menu(window, pane)
        return false
    end
    return true -- left click using default behave
end)

-- ============================================================
--  4. Platform-specific settings (font, default program, launch menu)
-- ============================================================
local os_name = wezterm.target_triple  -- e.g. "x86_64-pc-windows-msvc"

if os_name:find("windows") then
    -- ---------- Windows ----------
    config.font = wezterm.font_with_fallback({
        "Cascadia Mono NF",
        "Microsoft YaHei UI",        -- Chinese font for Windows
    })
end

-- ============================================================
--  5. Return the final configuration
-- ============================================================
return config
