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
config.font_size = 13.5
-- config.freetype_render_target = 'HorizontalLcd'
-- config.front_end = "WebGpu"
config.cursor_thickness = "200%"
config.default_cursor_style = "BlinkingBar"
config.animation_fps = 120
config.color_scheme = 'Campbell (Gogh)'

config.freetype_load_target = 'HorizontalLcd'
config.freetype_render_target = 'HorizontalLcd'
-- config.freetype_load_flags = 'NO_HINTING'

-- Colors (white cursor)
config.colors = {
    cursor_bg = "#FFFFFF",
    cursor_fg = "#000000",
    cursor_border = "#FFFFFF",
}


config.skip_close_confirmation_for_processes_named = {
    'bash',
    'sh',
    'zsh',
    'fish',
    'tmux',
    'cmd.exe',
    'powershell.exe'
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

    for _, item in ipairs(config.launch_menu) do
        table.insert(choices, {
            label = item.label,
            id = "cmd:" .. wezterm.json_encode(item.args)
        })
    end

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
            -- fuzzy = false,
            action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
                if not id then
                    return
                end

                local prefix, data = id:match("^(%a+):(.*)$")
                if prefix == "cmd" then
                    local args = wezterm.json_parse(data)
                    inner_window:perform_action(
                        wezterm.action.SpawnCommandInNewTab {
                            args = args
                        },
                        inner_pane
                    )
                else
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
    if button == 'Right' or button == 'Left' then
        newtab_menu(window, pane)
        return false
    end
    return true -- left click using default behave
end)

-- Global key bindings
config.keys = {
    {
        key = 'P',
        mods = 'SHIFT|CTRL',
        action = act.ActivateCommandPalette
    },
    {
        key = 'N',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            newtab_menu(window, pane)
        end),
    },
    {
        key = 'O',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ShowTabNavigator,
    },
}

-- ============================================================
--  4. Platform-specific settings (font, default program, launch menu)
-- ============================================================
local os_name = wezterm.target_triple  -- e.g. "x86_64-pc-windows-msvc"


if os_name:find("windows") then
    config.default_prog = { "powershell.exe", "-NoLogo" }
    config.launch_menu = {
        {
            label = 'WSL',
            args = { 'wsl.exe', '~' },
        },
        {
            label = 'PowerShell',
            args = { 'powershell.exe', '-NoLogo' },
        },
        {
            label = 'CMD',
            args = { 'cmd.exe' },
        },
    }
    -- ---------- Windows ----------
    config.font = wezterm.font_with_fallback({
        { family = "Cascadia Mono NF", weight = "Regular" },
        { family = "Microsoft YaHei UI", weight = "Regular" },
    })
    -- 显式指定粗体渲染规则
    config.font_rules = {
        {
            intensity = "Half",
            font = wezterm.font_with_fallback({
                { family = "Cascadia Mono NF", weight = "Regular" },
                { family = "Microsoft YaHei UI", weight = "Regular" },
            }),
        },
    }
end

-- ============================================================
--  5. Return the final configuration
-- ============================================================
return config
