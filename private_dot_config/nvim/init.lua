-- +++++++++++++++++++++++++++++++++++++++++++
-- File: init.lua
-- Author: PEMessage
-- Description: This is my NeoVIM configuration
-- Last Modified: 2024-03-13
-- +++++++++++++++++++++++++++++++++++++++++++

-- 1. Global Options
-- ===========================================

PE = {}  -- Global Options Var
PE.logo = {
    '   ██████╗ ███████╗███╗   ███╗███████╗███████╗███████╗ █████╗  ██████╗ ███████╗ ',
    '   ██╔══██╗██╔════╝████╗ ████║██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝ ██╔════╝ ',
    '   ██████╔╝█████╗  ██╔████╔██║█████╗  ███████╗███████╗███████║██║  ███╗█████╗   ',
    '   ██╔═══╝ ██╔══╝  ██║╚██╔╝██║██╔══╝  ╚════██║╚════██║██╔══██║██║   ██║██╔══╝   ',
    '   ██║     ███████╗██║ ╚═╝ ██║███████╗███████║███████║██║  ██║╚██████╔╝███████╗ ',
    '   ╚═╝     ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ',
}

-- 2. LazyNvim Auto Install
-- ===========================================

-- Debug Lsp
-- vim.lsp.set_log_level(vim.log.levels.DEBUG)
-- vim.lsp.log.set_format_func(vim.inspect)

-- Debug define
-- vim.g.editorconfig = false
-- vim.cmd('filetype off')
-- vim.cmd('syntax off')


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
-- local LazyUtil = require("lazy.core.util")

-- vim.keymap.set('i', 'jj', '<C-[>')


-- 3. Gernal Setting
-- ===========================================
local section = function ()
    -- -------------------------------------------
    -- 3.1 Basic Setting Zone
    -- -------------------------------------------
    -- vim.o.nocompatible = true     -- 禁用 vi 兼容模式
    vim.o.helplang     = "cn"      -- 设置中文帮助手册
    vim.o.wrap         = false          -- 关闭自动换行
    vim.o.ruler        = true            -- 显示光标位置
    vim.o.ffs          = 'unix,dos,mac' -- 文件换行符，默认使用 unix 换行符
    vim.o.mouse        = 'a'
    -- vim.o.diffopt = "linematch:60"
    vim.o.diffopt = vim.o.diffopt .. ",internal,algorithm:patience,iwhite"
    vim.o.fileencodings = 'ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,default,latin1,utf-16,shift-jis'


    -- Thanks to:
    -- https://github.com/nvim-mini/MiniMax/blob/44a93eaf2652cb437a27489c9620f4b1b4221141/configs/nvim-0.11/plugin/10_options.lua#L77C40-L77C80
    vim.o.iskeyword = '@,48-57,_,192-255,-'  -- Treat dash as `word` textobject part
    vim.o.virtualedit   = 'block' -- Allow going past end of line in blockwise mode
    vim.o.spelloptions  = 'camel' -- Treat camelCase word parts as separate words
    -- -------------------------------------------
    -- 3.3 Search Zone
    -- -------------------------------------------
    vim.o.ignorecase = true  --  smartcase depend this options
    -- use `/\C` to temporay disable this
    vim.o.smartcase = true   -- 智能搜索大小写判断，默认忽略大小写，除非搜索内容包含大写字母
    vim.o.incsearch = true   -- 查找输入时动态增量显示查找结果
    vim.o.hlsearch  = true   -- 高亮搜索内容

    -- -------------------------------------------
    -- 3.4 Tab and Indent Setting
    -- -------------------------------------------
    vim.o.tabstop     = 4                          -- Tab 长度，默认为8
    vim.o.smarttab    = true                       -- 根据文件中其他地方的缩进空格个数来确定一个tab是多少个空格
    vim.o.expandtab   = true                       -- 展开Tab

    vim.o.shiftwidth  = 4                          -- 缩进长度，设置为4
    vim.o.autoindent  = true                       -- 自动缩进
    vim.o.smartindent = true                       -- Insert indents automatically

    vim.o.backspace   = 'eol,start,indent'         -- 类似所有编辑器的删除键
        -- unmenu PopUp.-1-
    vim.cmd [[
        unmenu PopUp.How-to\ disable\ mouse
    ]]
    vim.cmd [[
        menu PopUp.Go\ to\ Define <c-]>
        menu PopUp.Back\  <c-t>
    ]]
    vim.cmd [[ set cinkeys-=0# ]]
    -- -------------------------------------------
    -- 3.5 Windows Setting
    -- -------------------------------------------
    vim.o.completeopt = 'menu,menuone,noselect,noinsert' -- Better Complete
    vim.o.number      = true -- Print line number
    vim.o.splitright  = true -- Put new windows right of current
    vim.o.pumheight = 10

    vim.o.jumpoptions = "stack"

    -- vim.api.nvim_create_autocmd( { 'FileType' },{
    --     pattern       = { 'help','man' },
    --     command       = 'wincmd L'
    -- })
    vim.api.nvim_create_augroup('vimrc_help', {clear = true})
    vim.api.nvim_create_autocmd({'BufEnter'}, {
        group = 'vimrc_help',
        pattern = { '*.*' },
        command = 'if &buftype == \'help\' | wincmd L | endif',
    })
    local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
    vim.api.nvim_clear_autocmds({ group = lastplace })
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = lastplace,
        pattern = { "*" },
        desc = "remember last cursor place",
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
        end,
    })


    -- -------------------------------------------
    -- 3.6 Stateline Setting
    -- -------------------------------------------
    vim.o.laststatus  = 2  -- 总是显示状态栏
    vim.o.showtabline = 2  -- 总是显示标签栏
    vim.o.splitright = true      -- 水平切割窗口时，默认在右边显示新窗口

    vim.o.showmode = false -- other plug will show status in statusline, not message line(mini.align need this)

    vim.diagnostic.config({ virtual_text = false })
    vim.g.inlay_hints_visible = true
    vim.lsp.inlay_hint.enable(true)

end
section()


-- 5. LazyNvim Auto Install
-- ===========================================
require("lazy").setup({
    -- -------------------------------------------
    -- 5.0 Essiential Plug
    -- -------------------------------------------
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        enabled = true,
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            preset = "helix",
            delay = 500,
            plugins = {
                spelling = {
                    enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                    suggestions = 5, -- how many suggestions should be shown in the list?
                },
            },
            spec = {
                { "<leader>n", group = "Line Nuber" },
                { "[", group = "prev" },
                { "]", group = "next" },
                { "g", group = "goto" },
            },
            icons = {
                mappings = false,
                keys = {
                    Up = "Up",
                    Down = "Down",
                    Left = "Left",
                    Right = "Right",
                    C = "<C> ",
                    M = "<M> ",
                    D = "<D> ",
                    S = "<S> ",
                    CR = "<CR> ",
                    Esc = "<ESC>",
                    ScrollWheelDown = "<MSD> ",
                    ScrollWheelUp = "<MSU>",
                    NL = "<NL>",
                    BS = "<BS>",
                    Space = "<SP>",
                    Tab = "<T>",
                    F1 = "F1",
                    F2 = "F2",
                    F3 = "F3",
                    F4 = "F4",
                    F5 = "F5",
                    F6 = "F6",
                    F7 = "F7",
                    F8 = "F8",
                    F9 = "F9",
                    F10 = "F10",
                    F11 = "F11",
                    F12 = "F12",
                },
            },
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
                "<leader>w",
                "<cmd>lua require('which-key').show({ preset = 'moderm', keys = '<c-w>', loop = true }) end",
                desc = "Hydra Mode",
            },
        },
    },
    -- {
    --     "phanen/lazy-help.nvim",
    --     ft = "lazy"
    -- },

    -- { 'projekt0n/github-nvim-theme' },
    -- { 'catppuccin/nvim' },
    -- {
    --     'uloco/bluloco.nvim',
    --     lazy = false,
    --     priority = 1000,
    --     dependencies = { 'rktjmp/lush.nvim' },
    --     config = function()
    --         -- your optional config goes here, see below.
    --         require("bluloco").setup({
    --             style = "auto",               -- "auto" | "dark" | "light"
    --             transparent = false,
    --             italics = false,
    --             terminal = vim.fn.has("gui_running") == 1, -- bluoco colors are enabled in gui terminals per default.
    --             guicursor   = true,
    --         })
    --
    --         vim.opt.termguicolors = true
    --         vim.cmd('colorscheme bluloco')
    --
    --     end,
    -- },
    -- {
    --     "Alexis12119/nightly.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         vim.cmd.colorscheme "nightly"
    --     end,
    -- },
    {
        'wuelnerdotexe/vim-enfocado',
        enabled = false,
        lazy = false,
        priority = 900,
        config = function ()
            vim.cmd [[ colorscheme enfocado ]]
        end
    },
    {
        "uga-rosa/ccc.nvim",
        lazy = true,
        opts = {},
        cmd = { 'CccPick' }
    },
    {
        'navarasu/onedark.nvim',
        enabled = true,
        lazy = false,
        priority = 900,
        opts = {
            style = 'deep',
            colors = {
                pe_gray = "#7c8dab",    -- define a new color
                pe_blue = "#499cff",    -- define a new color
                -- bg0 = "#1f2329", -- bg from darker
                -- bg0 = "#181818", -- bg come from 'wuelnerdotexe/vim-enfocado'
                bg0 = "#1a1a1a", -- more red and green, less blue compare to above
                bg1 = "#282c34",
                bg2 = "#30363f",
                bg3 = "#323641",
                bg_d = "#181b20",
                bg_blue = "#61afef",
                bg_yellow = "#e8c88c",
            },
            highlights = {
                Comment = {fg = '$pe_gray'},
                ['@comment'] = {fg = '$pe_gray'},
                ['@lsp.type.comment'] = {fg = '$pe_gray'},
                -- DiffAdd = {bg = '#8bcd5b', fg = '#1a212e'},

                -- Telescope
                TelescopePromptBorder = {fg = '$blue'},
                TelescopeResultsBorder = {fg = '$grey'},
                TelescopePreviewBorder = {fg = '$grey'},

                -- visual-whitespace
                VisualNonText = {fg = '$grey', bg = '$bg3'}
            },

            code_style = {
                comments = 'none',
                keywords = 'none',
                functions = 'none',
                strings = 'none',
                variables = 'none'
            },
        },
        config = function(_,opts)
            require('onedark').setup(opts)
            require('onedark').load()
        end,
    },
    {
        "backdround/improved-search.nvim",
        keys = {
            -- Search next / previous
            { "n", "<cmd>lua require('improved-search').stable_next()<cr>", mode = {"n", "x", "o"}, desc = "Search next" },
            { "N", "<cmd>lua require('improved-search').stable_previous()<cr>", mode = {"n", "x", "o"}, desc = "Search previous" },

            -- Search selected text in visual mode
            { "*", "<cmd>lua require('improved-search').in_place()<cr>", mode = "x", desc = "Search selection forward" },
        },
    },
    {
        'mangelozzi/rgflow.nvim',
        opts = {
            -- Set the default rip grep flags and options for when running a search via
            -- RgFlow. Once changed via the UI, the previous search flags are used for
            -- each subsequent search (until Neovim restarts).
            cmd_flags = "--smart-case --fixed-strings --ignore --max-columns 200",

            default_ui_mappings = true,
            default_quickfix_mappings = false,

            mappings = {
                ui = {
                    -- Normal mode maps
                    n = {
                        ["<c-c>"] = "close",         -- With the ui open, discard and close the UI window
                    },
                },
            }
        },
        keys = {
            -- For some reason, vim registers <C-/> as <C-_>
            -- See https://stackoverflow.com/questions/9051837/how-to-map-c-to-toggle-comments-in-vim
            {'<c-_>', mode = {'n'}, '<cmd>lua require("rgflow").open_cword()<CR>', desc = "Rgflow" },
            {'<c-_>', mode = {'v'}, '<cmd>lua require("rgflow").open_visual()<CR>', desc = "Rgflow" },
        },
    },
    {
        "nvim-mini/mini.move",
        opts = {
            mappings = {
                left = '<M-h>',
                right = '<M-l>',
                down = '<M-j>',
                up = '<M-k>',
            },
        }

    },
    -- -------------------------------------------
    -- 5.1 Style Plugin
    -- -------------------------------------------
    {
        -- active indent guide and indent text objects
        -- indent animation
        "nvim-mini/mini.indentscope",
        version = false, -- wait till new 3.7.0 release to put it back on semver
        enabled = true,
        event = { "BufReadPre", "BufNewFile" },
        opts = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify" },
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })
            vim.cmd [[highlight MiniIndentscopeSymbol guifg=#419cff gui=nocombine]]
            return {
                options = { try_as_border = true },
                symbol = "│",
            }
        end,
    },
    -- {
    --     'nvim-mini/mini.align',
    --     lazy = false,
    --     mappings = {
    --         start = 'ga',
    --         start_with_preview = 'gA',
    --     },
    --     version = '*'
    -- },
    {
        'nvim-mini/mini.icons',
        opts = {
            style = 'ascii',
        }
    },
    {
        'mcauley-penney/visual-whitespace.nvim',
        enabled = true,
        event = "ModeChanged *:[vV\22]", -- optionally, lazy load on entering visual mode
        opts = function ()

            return {
                match_types = {
                    space = false,
                    tab = true,
                    nbsp = true,
                    lead = false,
                    trail = false,
                },
            }
        end

    },
    {
        "lukas-reineke/indent-blankline.nvim",
        -- The indent that always exist one
        enabled = true,
        main = 'ibl', -- Version 3, instead of indent_blankline
        event = { "BufReadPost", "BufNewFile" },
        -- Version 2
        -- config = function(_,opts)
        --     require("indent_blankline").setup({
        --         char = '┆',
        --         filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
        --     })
        --     vim.cmd [[highlight IndentBlanklineChar guifg=#455573 gui=nocombine]]
        -- end
        --
        -- Version 3
        opts = function(_, _)
            -- use Inspect/InspectTree to check highlight
            -- See: help hl-IblIndent
            -- Default: takes the values from |hl-Whitespace| when not defined ~
            -- So this set must be set before setup()
            vim.cmd [[
                highlight IblIndent guifg=#455574 gui=nocombine
            ]]
            return {
                debounce = 100,
                indent = {
                    char = "|",
                    -- This will causing telescope.colorscheme live show error !!!
                    -- DONT USE IT !!!
                    -- highlight = 'IndentBlanklineChar'
                },
                exclude = {
                    filetypes = {
                        "help",
                        "alpha",
                        "dashboard",
                        "neo-tree",
                        "Trouble",
                        "lazy",
                        "mason"
                    }
                },
                scope = {
                    enabled = false
                }
            }
        end
    },
    {
        'PEMessage/alpha-nvim',
        event = "VimEnter",
        -- dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function ()
            local startify = require('alpha.themes.startify')
            startify.nvim_web_devicons.enabled = false
            startify.section.header.val = PE.logo
            startify.section.header.opts.hl = "String"

            startify.mru_opts.mru_start = 0
            startify.mru_opts.mru_cwd_start = 10

            startify.config.layout = {
                { type = "padding", val = 1 },
                startify.section.header,
                { type = "padding", val = 2 },
                startify.section.top_buttons,
                startify.section.mru,
                startify.section.mru_cwd,
                { type = "padding", val = 1 },
                startify.section.bottom_buttons,
                startify.section.footer,
            }
            require'alpha'.setup(startify.config)
            vim.keymap.set(
                "n", "<leader>st",
                '<cmd>tab new<cr><cmd>Alpha<cr>',
                { desc = "Startify(using Alpha)" }
            )
        end
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@diagnostic disable-next-line: undefined-doc-name
        ---@module snacks
        ---@type snacks.Config
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            -- dim = { enabled = true },
            -- dashboard = { enabled = true },
            -- explorer = { enabled = true },
            -- indent = { enabled = true },
            -- input = { enabled = true },
            -- picker = { enabled = true },
            -- notifier = { enabled = true },
            quickfile = { enabled = true },
            -- scope = { enabled = true },
            -- scroll = { enabled = true },
            -- statuscolumn = { enabled = true },
            -- words = { enabled = true },
        },
        keys = {
        }
    },
    -- {
    --     'yamatsum/nvim-cursorline',
    --     enabled = false,
    --     opts = {
    --         cursorline = {
    --             enable = true,
    --             timeout = 1000,
    --             number = false,
    --         },
    --         cursorword = {
    --             enable = false,
    --             -- min_length = 3,
    --             -- hl = { underline = true },
    --         }
    --     }
    -- },
    {
        'nvim-mini/mini.cursorword',
        opts = {
            delay = 300,
        },
        version = false
    },
    {
        "delphinus/auto-cursorline.nvim",
        opts = {
             wait_ms = 1000,
        },
    },
    {
        'nvim-lualine/lualine.nvim',
        enabled = true,
        dependencies = {
            -- 'nvim-tree/nvim-web-devicons',
            -- 'L3MON4D3/LuaSnip',
            -- 'hrsh7th/vim-vsnip',
            -- opt = true
        },
        opts = function ()
            local luasnip_status = {
                function ()
                    local ok, luasnip = pcall(require, 'luasnip')
                    if not ok then
                        return ''  -- Luasnip not installed/loaded
                    end

                    local session = luasnip.session
                    if type(session) ~= 'table' or type(session.current_nodes) ~= 'table' then
                        return ''
                    end

                    local node = session.current_nodes[vim.api.nvim_get_current_buf()]
                    if not node then
                        return ''

                    end

                    local expand_or_jumpable_ok, expand_or_jumpable = pcall(luasnip.expand_or_jumpable)
                    local in_snippet_ok, in_snippet = pcall(luasnip.in_snippet)

                    if (expand_or_jumpable_ok and expand_or_jumpable) and (in_snippet_ok and in_snippet) then
                        return '[Snippet]'
                    end

                    return ''
                end,
                color = { fg = '#98c379' }
            }
            -- local vsnip_status = {
            --     function()
            --         if vim.fn.exists('*vsnip#jumpable') == 0 then
            --             return ''
            --         end
            --         local in_snippet = vim.fn['vsnip#jumpable'](1) == 1 or vim.fn['vsnip#jumpable'](-1) == 1
            --
            --         if in_snippet then
            --             return '[Snippet]'
            --         else
            --             return ''
            --         end
            --     end,
            --     color = { fg = '#98c379' }
            -- }

            return {
                options = {
                    theme = 'auto',
                    icons_enabled = false,
                    component_separators = { left = '|', right = '|' },
                    section_separators = { left = '', right = '' },
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'branch', 'diff', 'diagnostics'},
                    lualine_c = {
                        'filename',
                        -- vsnip_status,
                        luasnip_status,
                        'searchcount'
                    },
                    lualine_x = {'encoding', 'fileformat', 'filetype'},
                    lualine_y = {'progress'},
                    lualine_z = {'location'}
                },
            }
        end
    },
    {
        'akinsho/toggleterm.nvim',
        opts = {
            open_mapping = [[<M-S-u>]],
            direction = 'float',
            float_opts = {
                col = function()
                    return vim.o.columns - math.floor(vim.o.columns * 0.4)
                end,
                width = function()
                    return math.floor(vim.o.columns * 0.4)
                end,
                row = function()
                    return vim.o.lines - math.floor(vim.o.lines * 0.4)
                end,
                height = function()
                    return math.floor(vim.o.lines * 0.4)
                end,
            }
        }
    },
    -- {
    --     'sunjon/Shade.nvim',
    --     opts = {
    --         overlay_opacity = 50,
    --         opacity_step = 1,
    --         keys = {
    --             toggle = '<Leader>s',
    --         }
    --     }
    -- },
    {
        'fei6409/log-highlight.nvim',
        ft = 'log',
        opts = {}
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        enabled = false,
        -- if you use standalone mini plugins
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
        opts = {},
    },
    {
        "PEMessage/inspector.nvim",
        lazy = true,
        cmd = { 'InspectFloat' },
        opts = function (_, _)
            -- Thanks to:
            -- https://www.reddit.com/r/neovim/comments/1dvvdj3/how_to_easily_identify_highlight_groups/
            -- https://gist.github.com/roycrippen4/e65c8987f1e7a09959ea69e04362e15c
            -- https://gist.github.com/aaronedev/ef03f3460052ebd885bc08d5cc6bf190
            vim.api.nvim_create_user_command("InspectFloat",
                'lua require("inspector").toggle_float_inspector()',
                {})

            return {}
        end,
    },
    -- {
    --     'luochen1990/rainbow',
    --     event = { "BufReadPost", "BufNewFile" },
    --     config = function ()
    --         vim.g.rainbow_active = 1
    --         vim.g.cursorword_delay = 600
    --         vim.cmd([[
    --             let g:rainbow_conf = {
    --            \   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
    --            \   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
    --            \   'operators': '_,_',
    --            \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    --            \   'separately': {
    --            \       '*': 0,
    --            \       'vim': 0,
    --            \       'make': {
    --            \           'parentheses': ['start=/$\+(/ end=/)/', 'start=/\[/ end=/\]/'],
    --            \       },
    --            \       'nerdtree': 0,
    --            \   }
    --            \}
    --
    --            nnoremap <f1> :exec 'syn list '.synIDattr(synID(line('.'), col('.'), 0), 'name')<cr>
    --
    --            augroup rainbow_auto
    --               autocmd!
    --               autocmd FileType make syntax clear makeIdent
    --            augroup END
    --         ]])
    --         -- code
    --     end
    -- },
    -- -------------------------------------------
    -- 5.2 Editing Plugin
    -- -------------------------------------------
    -- {
    --     "is0n/jaq-nvim",
    --     opts = {
    --         -- Uses shell commands
    --         external = {
    --             cpp = 'echo 123'
    --         },
    --     },
    --     config = function (_,opts)
    --         require('jaq-nvim').setup(opts)
    --     end
    -- },
    {
        "ii14/neorepl.nvim",
        cmd = 'Repl',
        lazy = true,
        dependencies = {
            "hrsh7th/nvim-cmp",
            -- "nvim-treesitter/nvim-treesitter",
        },
        config = function(_, _)
            require('cmp').setup.filetype('neorepl', {
                enabled = false
            })
            -- Seem not work
            -- vim.treesitter.language.register("lua", "neorepl")
        end,
    },
    {
        "Zeioth/compiler.nvim",
        enabled = false,
        dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
        -- cmd = {
        --     'CompilerOpen', 'CompilerRedo', 'CompilerStop'
        -- },
        opts = {},
        keys = {
            {
                '<leader>rff',
                '<cmd>CompilerOpen<cr>',
                mode = 'n', desc = 'Open Compiler', noremap = true, silent = true
            },
            {
                '<leader>rr',
                '<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>',
                mode = 'n', desc = 'Redo Last Compiler Option',
                noremap = true, silent = true
            },
        },
    },
    { -- The task runner we use
        "stevearc/overseer.nvim",
        enabled = false,
        commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
        opts = {
            task_list = {
                direction = "bottom",
                min_height = 25,
                max_height = 25,
                default_detail = 1
            },
        },
    },
    {
        'numToStr/Comment.nvim',
        event = "VeryLazy",
        opts = {}
    },
    {
        'kevinhwang91/nvim-bqf',
        enabled = true,
        dependencies = { 'junegunn/fzf' }, -- for fzf-mode under quickfix using `zf`
        ft = 'qf',
        opts = {
            auto_resize_height = true, -- highly recommended enable
            preview = {
                auto_preview = true,
                show_scroll_bar = false,
                win_height = 5,
            },
        },
    },
    {
        'stevearc/quicker.nvim',
        ft = "qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {},
    },
    {
        'kylechui/nvim-surround',
        event = "VeryLazy",
        opts = {},
    },
    {
        'phaazon/hop.nvim',
        branch = 'v2', -- optional but strongly recommended
        enabled = false,
        event = "VeryLazy",
        opts = {},
        keys = {
            { '<space>', "<cmd>lua require('hop').hint_char1()<CR>", mode = 'n', desc = 'Hop to char', remap = true },
            { '<leader>hp', "<cmd>lua require('hop').hint_patterns()<CR>", desc = 'Hop Pattern', remap = true },
        },
    },
    {
        'PEMessage/flash.nvim',
        event = "VeryLazy",
        enabled = true,
        opts = function ()
            -- easymotion like highlight
            vim.cmd [[ highlight! link FlashMatch String ]]
            vim.cmd [[ highlight! link FlashCurrent ErrorMsg ]]
            vim.cmd [[ highlight! link FlashLabel Search ]]
            return {
                modes = {
                    -- Disable search integration. Better to use "s" if I want flash search.
                    -- If enabling this, make sure to remove the verymagic rebind
                    -- (https://github.com/folke/flash.nvim/issues/278).
                    search = {
                        enabled = false,
                    },
                    char = {
                        enabled = false,
                    }
                },
            }
        end,

        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump({
                jump = { autoexit = false }
            }) end, desc = "Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },

    },
    {
        "willothy/flatten.nvim",
        -- config = true,
        -- or pass configuration with
        opts = {
            window = {
                open = "alternate",
            },
        },
        -- Ensure that it runs first to minimize delay when opening file from terminal
        lazy = false,
        priority = 1001,
    },

    -- -------------------------------------------
    -- 5.3 Legacy Plugin
    -- -------------------------------------------
    {
        'yianwillis/vimcdoc',
        event = 'CmdlineEnter'
    },
    {
        'PEMessage/pdir.nvim',
        lazy = true,
        keys = {
            { '<m-left>',  function() require('pdir').open_parent( - 1)end, },
            { '<m-right>', function() require('pdir').open_parent(1)   end, },
        }
    },
    -- {
    --     'PEMessage/parent_dir_tui.vim',
    --     lazy = false,
        -- keys = {
        --     {'<m-left>', '<cmd>ParentDirTuiLeft<CR>'},
        --     {'<m-right>', '<cmd>ParentDirTuiRight<CR>'},
        -- }
    -- },
    {
        'tpope/vim-sleuth', -- Maybe nmac427/guess-indent.nvim ?
        cmd = {'Sleuth'},
        lazy = true,
        init = function()
            vim.cmd [[ command UnSleuth setlocal et sw=4 ts=4 ]]
        end,
    },
    {
        'rubberduck203/aosp-vim',
    },
    {
        'PEMessage/generate-ninja.vim',
        ft = 'gn',
    },
    {
        'PEMessage/ghostty.vim',
    },
    {
        'tpope/vim-rsi',
        event = { 'InsertEnter', 'CmdLineEnter' },
    },
    {
        'tpope/vim-fugitive',
        event = 'VeryLazy',
    },
    {
        'justinmk/vim-dirvish',
    },
    {
        'tpope/vim-eunuch',
        event = 'VeryLazy',
        config = function(_, _)
            vim.cmd [[
            delcommand Unlink
            delcommand Remove
            ]]
        end,
    },
    {
        'tpope/vim-unimpaired',
    },
    {
        'axelf4/vim-strip-trailing-whitespace',
        event = {'InsertEnter', 'BufEnter'}
    },
    {
        'thinca/vim-quickrun',
        keys = {
            { "<leader>rkk", mode = { "n" }, '<cmd>QuickRun<CR>', desc = "QuickRun" },
        },
    },
    { 'wsdjeg/vim-fetch' },
    {
        "terryma/vim-expand-region",
        dependencies = {
            'kana/vim-textobj-user',
            'kana/vim-textobj-line',
        },
        keys = {
            { "<CR>", mode = { "n", "v", "x" }, "<Plug>(expand_region_expand)", desc = "Expand region expand" },
            { "<BS>", mode = { "n", "v", "x" }, "<Plug>(expand_region_shrink)", desc = "Expand region shrink" },
        },
        init = function()
            vim.g.expand_region_text_objects = {
                ['iw'] = 0,
                ['iW'] = 0,
                ['i"'] = 0,
                ['a"'] = 0,
                ["i'"] = 0,
                ["a'"] = 0,
                ['i]'] = 0,
                ['a]'] = 0,
                ['i)'] = 0,
                ['a)'] = 0,
                ['i}'] = 1,
                ['a}'] = 1,
                ['il'] = 1,
            }
        end
    },

    -- {
    --     'gorkunov/smartpairs.vim',
    --     init = function ()
    --         vim.g.smartpairs_key = 'v'
    --         vim.g.smartpairs_nextpairs_key = 'v'
    --         vim.g.smartpairs_revert_key = '<BS>'
    --     end
    -- },
    {
        "mg979/vim-visual-multi",
        event = 'VeryLazy',
        enabled = true,
        init  = function()
            vim.g.M_default_mappings = 0
            vim.g.VM_mouse_mappings  = 1
            vim.g.VM_maps = {
                ['Find Under']          = '<C-h>',
                ['Find Subword Under']  = '<C-h>',
                ['Exit']                = '<C-c>',
                -- Arrow Key
                ["Add Cursor Up"]       = '<C-Up>',
                ["Add Cursor Down"]     = '<C-Down>',
                -- Mouse
                ["Mouse Cursor"]        = '<C-LeftMouse>',
                -- Multi-Mode
                ["Align"]               = '<C-a>',
                ["Enlarge"]             = "=",
                ["Shrink"]              = "-",
                -- Move
                ["Find Next"]           = ']',
                ["Find Prev"]           = '[',
                ["Remove Region"]       = 'Q',
                ["Skip Region"]         = 'q'
            }
        end,
    },
    {
        "jake-stewart/multicursor.nvim",
        enabled = false,
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()

            local set = vim.keymap.set
            set({"n", "x"}, "<c-up>", function() mc.lineAddCursor(-1) end)
            set({"n", "x"}, "<c-down>", function() mc.lineAddCursor(1) end)
            set({"n", "x"}, "<m-up>", function() mc.lineSkipCursor(-1) end)
            set({"n", "x"}, "<m-down>", function() mc.lineSkipCursor(1) end)


            set("n", "<c-leftmouse>", mc.handleMouse)
            set("n", "<c-leftdrag>", mc.handleMouseDrag)
            set("n", "<c-leftrelease>", mc.handleMouseRelease)

            mc.addKeymapLayer(function(layerSet)

                -- Select a different cursor as the main one.
                layerSet({"n", "x"}, "<m-h>", mc.prevCursor)
                layerSet({"n", "x"}, "<m-l>", mc.nextCursor)

                local function exit()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end
                layerSet("n", "<esc>", exit)
                layerSet("n", "<c-c>", exit)
            end)

            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { reverse = true })
            hl(0, "MultiCursorVisual", { link = "Visual" })
            hl(0, "MultiCursorSign", { link = "SignColumn"})
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { reverse = true })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
        end
    },
    {
        'PEMessage/vim-text-process',
        event = { 'InsertEnter', 'CmdLineEnter' },
        config = function ()
            -- vim.g.textproc_inline_script = {
            --     ['format_json'] = 'python3 -c "import json.tool ; json.tool.main()"',
            --     ['format_py']   = 'python3 -m autopep8 -',
            --     ['spliter_before'] = 'bash -c \' echo sed "s@^$1@===================\\n@g\' -- '
            -- }
            vim.cmd [[
            let g:textproc_inline_script = {
            \'format_json': 'python3 -c "import json.tool ; json.tool.main()"',
            \'format_py': 'python3 -m autopep8 -',
            \'spliter_before': 'bash -c ''sed "s@^$1@===================\n@g"'' -- ',
            \}
            ]]
        end
    },
    -- {
    --     'easymotion/vim-easymotion',
    --     event = 'VeryLazy',
    --     enabled = false,
    --     init = function()
    --         vim.g.EasyMotion_smartcase        = 1
    --         vim.g.EasyMotion_do_mapping       = 0
    --         vim.g.EasyMotion_enter_jump_first = 1
    --         vim.g.EasyMotion_space_jump_first = 1
    --         vim.g.EasyMotion_use_upper        = 1
    --         vim.keymap.set(
    --             'n',
    --             '/','<Plug>(easymotion-sn)',
    --             {   desc = 'Search using easymotion',
    --                 remap = true,
    --             }
    --
    --         )
    --         -- DEPRECATE:
    --         -- vim.keymap.set(
    --         --     'n',
    --         --     '<leader>/','/',
    --         --     {   desc = 'Search using origin VIM /',
    --         --         remap = true,
    --         --     }
    --         --
    --         -- )
    --     end,
    -- },
    {
        'junegunn/vim-easy-align',
        event = 'VeryLazy',
        keys = {
            { "ga", "<Plug>(EasyAlign)", mode = { "x" }, desc = "EasyAlign (visual mode)" },
        }

    },
    { 'tpope/vim-repeat', event = 'VeryLazy' },

    {
        'lewis6991/gitsigns.nvim',
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
                delay = 800,
                ignore_whitespace = false,
                virt_text_priority = 100,
            },
            diff_opts = {
                ignore_whitespace = false,
                ignore_whitespace_change = false,
            },
        },
        keys = {
            {
                '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<cr>', mode = 'n',
                desc = 'Toggle line blame', silent = true
            },
            {
                '[c', "&diff ? '[c' : ':Gitsigns prev_hunk<CR>'", mode = 'n',
                desc = 'Previous git changed line', silent = true, expr = true
            },
            {
                ']c', "&diff ? ']c' : ':Gitsigns next_hunk<CR>'", mode = 'n',
                desc = 'Next git changed line', silent = true, expr = true
            },
            {
                --- @note if we want pass range to cmd, we must use : instead of <cmd>
                '<leader>u', ':Gitsigns reset_hunk<cr>', mode = {'n', 'v'},
                desc = 'Reset git hunk', silent = true
            },
            {
                '<leader>a', ':Gitsigns stage_hunk<cr>', mode = {'n', 'v'},
                desc = 'Add(Stage) or Toggle git hunk', silent = true
            },
        },
    },
    {
        "chentoast/marks.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        'inkarkat/vim-mark',
        event = 'BufRead',
        dependencies = 'inkarkat/vim-ingo-library',
        init = function()
            vim.g.mw_no_mappings = 1
            vim.g.mwAutoLoadMarks = 1
            vim.g.mwMaxMatchPriority = 10
        end,
        keys = {
            { '<Leader>mt', '<Plug>MarkToggle', mode = 'n', desc = 'vim-mark toggle' },
            { '<Leader>mc', '<Plug>MarkClear', mode = 'n', desc = 'vim-mark clear' },
            { '<leader>m', '<Plug>MarkSet', mode = 'x', desc = 'Set visual vim-mark' },
            { 'n', '<Plug>MarkSearchAnyOrDefaultNext', mode = 'n', desc = 'Next mark' },
            { 'N', '<Plug>MarkSearchAnyOrDefaultPrev', mode = 'n', desc = 'Previous mark' },
        },
    },
    {
        'kana/vim-gf-diff',
        dependencies = {
            'PEMessage/vim-gf-user'
        },
        ft = { 'diff', 'git' }
    },
    {
        'trevorhauter/gitportal.nvim',
        enabled = false,
        opts = {}
    },
    {
        "julienvincent/hunk.nvim",
        opts = {
            -- icons = {
            --     selected = "*",
            --     deselected = "",
            --     partially_selected = "",
            --
            --     folder_open = ">",
            --     folder_closed = "-",
            -- },
        },
        dependencies = { 'MunifTanjim/nui.nvim' },
        cmd = { "DiffEditor" },
    },
    {
        "christoomey/vim-tmux-navigator",
        -- Do not use very lazy prevent not init
        lazy = true,
        keys = {
            { "<M-S-h>", "<cmd>TmuxNavigateLeft<cr>", mode = {"n", "i", "v", "t"}, desc = "Navigate Left" },
            { "<M-S-j>", "<cmd>TmuxNavigateDown<cr>", mode = {"n", "i", "v", "t"}, desc = "Navigate Down" },
            { "<M-S-k>", "<cmd>TmuxNavigateUp<cr>", mode = {"n", "i", "v", "t"}, desc = "Navigate Up" },
            { "<M-S-l>", "<cmd>TmuxNavigateRight<cr>", mode = {"n", "i", "v", "t"}, desc = "Navigate Right" },
        },
        init = function()
            vim.g.tmux_navigator_no_mappings = 1
        end
    },
    -- -------------------------------------------
    -- 5.4 Treesitter (HEAVY Zone after)
    -- -------------------------------------------
    -- {
    --     'nvim-treesitter/nvim-treesitter',
    --     branch = 'main', -- required: main is the new rewrite
    --     build = ':TSUpdate', -- ensures parsers are updated
    --     lazy = false, -- treesitter does NOT support lazy-loading
    --     opts = {
    --         ensure_installed = {
    --             'json',
    --             'xml',
    --             'css',
    --             'vim',
    --             'lua',
    --             'c',
    --             'cpp',
    --             'make',
    --             -- from lspsage:
    --             -- You need to install the Treesitter markdown and markdown_inline parser.
    --             -- If you are not sure if you have them, run :checkhealth
    --             'markdown',
    --             'markdown_inline',
    --             'go',
    --             'java',
    --             'python',
    --             'vimdoc',
    --             'bash',
    --             'kotlin',
    --             'javascript',
    --         },
    --         indent = { enable = true },
    --         highlight = { enable = true },
    --         folds = { enable = true },
    --     },
    --     config = function(_, opts)
    --         -- Thanks:
    --         -- https://www.reddit.com/r/neovim/comments/1kuj9xm/comment/mu6acjr/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    --         -- https://github.com/xaaha/dev-env/blob/main/nvim/.config/nvim/lua/xaaha/plugins/lsp-nvim-treesitter.lua
    --         local already_installed = require("nvim-treesitter.config").get_installed()
    --         local need_install = vim.iter(opts.ensure_installed)
    --             :filter(function(parser) return not vim.tbl_contains(already_installed, parser) end)
    --             :totable()
    --         require("nvim-treesitter").install(need_install)
    --
    --         local have = function (what, query)
    --             what = what or vim.api.nvim_get_current_buf()
    --             what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]
    --             local lang = vim.treesitter.language.get_lang(what)
    --             if lang == nil or require("nvim-treesitter.config").get_installed()[lang] == nil then
    --                 return false
    --             end
    --             if query and not vim.treesitter.query.get(lang, query) then
    --                 return false
    --             end
    --             return true
    --         end
    --
    --         -- https://github.com/LazyVim/LazyVim/blob/42c9f7152b9bd1a4f739b115390370c208dc2a55/lua/lazyvim/plugins/treesitter.lua#L101
    --         vim.api.nvim_create_autocmd("FileType", {
    --             group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
    --             callback = function(ev)
    --                 local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
    --                 if not have(ft) then
    --                     return
    --                 end
    --
    --                 local function enabled(feat, query)
    --                     local f = opts[feat] or {}
    --                     if type(f.disable) == "table" and vim.tbl_contains(f.disable, lang) then
    --                         return false
    --                     end
    --                     if type(f.enable) == "table" then
    --                         return vim.tbl_contains(f.enable, lang) and have(ft, query)
    --                     end
    --                     if f.disable == true then
    --                         return false
    --                     end
    --                     return have(ft, query)
    --                 end
    --
    --                 -- highlighting
    --                 if enabled("highlight", "highlights") then
    --                     pcall(vim.treesitter.start, ev.buf)
    --                 end
    --
    --                 -- indents
    --                 if enabled("indent", "indents") then
    --                     vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    --                 end
    --
    --                 -- folds
    --                 if enabled("folds", "folds") then
    --                     vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    --                 end
    --             end,
    --         })
    --     end,
    -- },
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = { 'williamboman/mason.nvim' },
        branch = 'main', -- required: main is the new rewrite
        build = ':TSUpdate', -- ensures parsers are updated
        lazy = false, -- treesitter does NOT support lazy-loading
    },
    {
        'MeanderingProgrammer/treesitter-modules.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        lazy = false, -- treesitter does NOT support lazy-loading
        opts = {
            highlight = {
                enable = true,
                disable = { 'markdown', 'lua', 'make' },
                additional_vim_regex_highlighting = false,
            },
            disable = function(lang,bufnr)
                return lang == "ninjia" and vim.api.nvim_buf_line_count(bufnr) > 50000
            end,
            -- rainbow = {
            --     enable = true,
            --     -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
            --     extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            --     max_file_lines = nil, -- Do not enable for files with more than n lines, int
            --     -- colors = {}, -- table of hex strings
            --     -- termcolors = {} -- table of colour name strings
            -- },
            indent = { enable = { 'python','lua'  } },
            ensure_installed = {
                'json',
                'xml',
                'toml',
                'css',
                'html',
                'vim',
                'lua',
                'c',
                'cpp',
                'make',
                'cmake',
                'gn',
                'bash',
                -- from lspsage:
                -- You need to install the Treesitter markdown and markdown_inline parser.
                -- If you are not sure if you have them, run :checkhealth
                'markdown',
                'markdown_inline',
                'go',
                'java',
                'python',
                'vimdoc',
                'bash',
                'kotlin',
                'javascript',
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = '<CR>',
                    node_incremental = '<CR>',
                    node_decremental = '<BS>',
                    scope_incremental = '<TAB>',
                }
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        branch = 'main',
        enabled = false,
        opts = {
            enable = false,
            max_lines = 3
        }
    },
    {
        "Wansmer/sibling-swap.nvim",
        opts = {
            use_default_keymaps = false,
        },
        lazy = true,
        keys = {
            {
                "[,",
                '<cmd>lua require("sibling-swap").swap_with_left()<CR>',
                mode = "n",
                desc = "Swap with left sibling"
            },
            {
                "],",
                '<cmd>lua require("sibling-swap").swap_with_right()<CR>',
                mode = "n",
                desc = "Swap with right sibling"
            }
        }
    },
    {
        'HiPhish/rainbow-delimiters.nvim',
        init = function()
            -- NOTICE: we should disable this for large file, it will highlight entire file
            --         or maybe take a look of 'saghen/blink.pairs' ?
            -- ALSO SEE:
            --  https://github.com/HiPhish/rainbow-delimiters.nvim/issues/184#issuecomment-3085700893
            local large_file_handle = function (bufnr)
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                if line_count > 5000 then
                    return nil
                end
                return 'rainbow-delimiters.strategy.global'
            end

            vim.g.rainbow_delimiters = {
                [''] = 'rainbow-delimiters.strategy.global',
                strategy = {
                    cpp = large_file_handle,
                },
            }
        end,
        enabled = true,
    },

    {
        'ckolkey/ts-node-action',
        opts = function()
            local actions = require("ts-node-action.actions")
            -- local helpers = require("ts-node-action.helpers")

            -- local c_cpp_padding = {
            --     [","] = "%s ",
            --     ["{"] = "%s ",
            --     ["}"] = " %s",
            --     ["("] = "%s",
            --     [")"] = "%s",
            --     ["["] = "%s",
            --     ["]"] = "%s",
            -- }

            return {
                ['*'] = {
                    ['identifier'] = function() end,
                    ['arguments'] = actions.toggle_multiline(),
                    ['argument_list'] = actions.toggle_multiline(),
                },
            }
        end,
        keys = {
            {
                -- Choose your own keys, this works for me
                "M",
                '<cmd>lua require("ts-node-action").node_action()<CR>',
                mode = {
                    "v",
                    "n"
                },
                desc = "Trigger Node Action",
            },
        },
    },
    {
        "utilyre/barbecue.nvim",
        enabled = false,
        name = "barbecue",
        version = "*",
        dependencies = {
            "SmiteshP/nvim-navic",
            -- "nvim-tree/nvim-web-devicons", -- optional dependency
        },
        opts = {
            kinds = false,
            symbols = {
                separator = ">",
            },
            -- configurations go here
        },
    },
    {
        'Bekaboo/dropbar.nvim',
        enabled = true,
        event = 'VeryLazy',
        opts = {
            sources = {
                path = {
                    preview = false,
                }
            },
            bar = {
                sources = function(buf, _)
                    local sources = require('dropbar.sources')
                    local utils = require('dropbar.utils')
                    if vim.bo[buf].ft == 'markdown' then
                        return {
                            sources.path,
                            sources.markdown,
                        }
                    end
                    if vim.bo[buf].buftype == 'terminal' then
                        return {
                            sources.terminal,
                        }
                    end
                    return {
                        utils.source.fallback({
                            sources.lsp,
                            sources.treesitter,
                            sources.path,
                        }),
                    }
                end
            },
            icons = {
                -- enable = false,
                ui  = {
                    bar = {
                        separator = ' > '
                    },
                },
            }
        },
        config = function(_,opts)
            vim.cmd [[ highlight! link WinBar StatusLine ]]
            vim.cmd [[ highlight! link WinBarNC StatusLineNC ]]

            -- Setup defconfig to '', a workaround for using icons.disable will cause DAP-UI report error
            local def_symbols = require('dropbar.configs').opts.icons.kinds.symbols
            for key, _ in pairs(def_symbols) do
                def_symbols[key] = ""
            end

            require('dropbar').setup(opts)
            local dropbar_api = require('dropbar.api')
            vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
            vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
        end

        -- optional, but required for fuzzy finder support
        -- dependencies = {
            -- 'nvim-telescope/telescope-fzf-native.nvim'
        -- }
    },


    -- -------------------------------------------
    -- 5.5 Telescope Setting

    -- -------------------------------------------
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        dependencies = { 'nvim-telescope/telescope.nvim', 'j-hui/fidget.nvim' },
        event = 'VimEnter',
        build = 'make',
        cond = function()
            return vim.fn.executable("make") == 1 or vim.fn.executable("cmake") == 1
        end,
        opts = {
            -- Also See: https://github.com/debugloop/telescope-undo.nvim
            -- don't use `defaults = { }` here, do this in the main telescope spec
            extensions = {
                fzf = {
                    fuzzy = true,                    -- false will only do exact matching
                    override_generic_sorter = true,  -- override the generic sorter
                    override_file_sorter = true,     -- override the file sorter
                    case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                }
            },
        },
        -- Thanks to:
        -- https://github.com/Jaetan/dotfiles/blob/78ae9683123d8f234c3ed4c77e3ca4f561ef1695/.config/nvim/lua/plugins/telescope_extras.lua#L7
        config = function(plugin, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            local ok, _ = pcall(telescope.load_extension, "fzf")

            if not ok then

                local retry = function(_)
                    if vim.fn.executable("cmake") == 1 then
                        -- Cmake 4.0 need CMAKE_POLICY_VERSION_MINIMUM
                        return "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5" ..
                            "&& cmake --build build --config Release --target install"
                    end
                    if vim.fn.executable("make") == 1 then
                        return "make"
                    end
                end
                vim.print(plugin.build)

                plugin.build = retry()
                vim.notify("Failed to load telescope-fzf extension")
                require("lazy").build({
                    plugins = { plugin },
                    show = true -- Set to false if you want it to happen silently in the background
                })
            end
        end,
    },
    {
        "jmacadie/telescope-hierarchy.nvim",
        brnach = 'feature/type',
        dependencies = {
            {
                "nvim-telescope/telescope.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
        },
        keys = {
            { -- lazy style key map
                -- Choose your own keys, this works for me
                "<leader>si",
                "<cmd>Telescope hierarchy incoming_calls<cr>",
                desc = "LSP: [S]earch [I]ncoming Calls",
            },
            {
                "<leader>so",
                "<cmd>Telescope hierarchy outgoing_calls<cr>",
                desc = "LSP: [S]earch [O]utgoing Calls",
            },
        },
        opts = {
            -- don't use `defaults = { }` here, do this in the main telescope spec
            extensions = {
                hierarchy = {
                    disable_devicons = true,
                    scroll_strategy = 'limit',
                },
                -- no other extensions here, they can have their own spec too
            },
        },
        config = function(_, opts)
            -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
            -- configs for us. We won't use data, as everything is in it's own namespace (telescope
            -- defaults, as well as each extension).
            require("telescope").setup(opts)
            require("telescope").load_extension("hierarchy")
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        -- since we use nvim-treesitter main branch, we should use master bracnh
        branch = 'master',
        enabled = true,
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope",
        -- See : help LazyKeysSpec
        keys = function(_, _)
            -- Helper function to create telescope dropdown config
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            local function disable_cursorline(prompt_bufnr, _)
                vim.api.nvim_buf_set_option(prompt_bufnr, "cursorline", false)
                vim.api.nvim_buf_set_var(prompt_bufnr, 'auto_cursorline_disabled', 1)
                return true
            end

            local function create_dropdown_config(opts)
                local defaults = {
                    layout_config = {
                        width = 0.8,
                    },
                    borderchars = {
                        prompt = { "─", "│", "-", "│", "┌", "┐", "│", "│" },
                        results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
                        preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    },
                    attach_mappings = disable_cursorline,
                }
                return require('telescope.themes').get_dropdown(vim.tbl_extend("force", defaults, opts or {}))
            end

            -- Helper function to create buffer picker
            local builtin = require('telescope.builtin')


            local function buffers_picker()
                builtin.buffers(create_dropdown_config({
                    sort_mru = true,
                    ignore_current_buffer = true,
                    path_display = { shorten = { len = 2, exclude = { 1, 2, -3, -2, -1 } } },
                    attach_mappings = function(prompt_bufnr, map)
                        disable_cursorline(prompt_bufnr, map)
                        map({ 'i', 'n' }, '<C-p>', function(...)
                            return actions.close(...)
                        end)
                        return true
                    end
                }))
            end

            -- Helper function to create oldfiles picker
            local function oldfiles_picker()
                builtin.oldfiles(create_dropdown_config({
                    previewer = false,
                    attach_mappings = function(prompt_bufnr, map)
                        disable_cursorline(prompt_bufnr, map)
                        map({ 'i', 'n' }, '<C-r>', function(...)
                            return actions.close(...)
                        end)
                        return true
                    end
                }))
            end

            -- Helper function to create find_files picker
            local function find_files_picker()
                builtin.find_files({
                    previewer = false,
                    path_display = { shorten = { len = 3, exclude = { 1, 2, -3, -2, -1 } } },
                    attach_mappings = disable_cursorline,
                })
            end

            local function modify_sorter_scoring(sorter)
                local original_scoring_fn = sorter.scoring_function
                sorter.scoring_function = function(...)
                    local score = original_scoring_fn(...)
                    return score < 0 and score or 1
                end
                return sorter
            end

            local function cmd_history()
                local default_text = ''
                local mode = vim.fn.mode()
                if mode == "c" then
                    if vim.fn.getcmdtype() ~= ":" then
                        return
                    end
                    default_text = vim.fn.getcmdline()
                    -- clean it, so that
                    -- 1. it will not being add to cmdline_history
                    -- 2. will not trigger a 'E492: Not an editor command' why???
                    vim.fn.setcmdline('')
                end

                builtin.command_history({
                    default_text = default_text,
                    -- ctrlp like style
                    layout_strategy = "bottom_pane",
                    sorting_strategy = "descending",
                    layout_config = {
                        height = 15,
                        mirror = true,
                        prompt_position = "bottom",
                    },
                    -- borderchars = false,
                    prompt_title = "",
                    results_title = "",
                    preview_title = "",
                    -- sorter
                    sorter = modify_sorter_scoring(
                        require('telescope.config').values.generic_sorter()
                    ),
                    attach_mappings = function(prompt_bufnr, map)
                        disable_cursorline(prompt_bufnr, map)

                        local picker = action_state.get_current_picker(prompt_bufnr)
                        local initial_text = picker and picker.default_text or ''

                        local function close(...)
                            actions.close(...)
                            if initial_text ~= '' then
                                vim.api.nvim_feedkeys(":" .. initial_text, "n", true)
                            end
                        end

                        map({ "i", "n" }, "<enter>", actions.edit_command_line)
                        map({ "i", "n" }, "<C-c>", close)
                        map({ "i", "n" }, "<C-q>", close)
                        return true
                    end,
                })
            end

            return {
                {"<C-p>", buffers_picker, "Buffers" },
                {"<C-r>", oldfiles_picker, "MRU" },
                {"<C-e>", find_files_picker, "Find Files" },
                {"<C-q>", cmd_history,  "Commands History", mode = {"c", "n"}, noremap = true},
                {"<leader>tm", "<cmd>Telescope man_pages<cr>", "Telescope Man Pages" },
                {"<leader>td", "<cmd>Telescope lsp_definitions<cr>", "Telescope LSP Define" },
                {"<leader>th", "<cmd>Telescope help_tags<cr>", "Telescope Help Pages" },
                {"<leader>tf", "<cmd>Telescope find_files<cr>", "Telescope Find Files" },
                {"<leader>tg", "<cmd>Telescope live_grep<cr>", "Telescope Live Grep" },
                {"<leader>tt", "<cmd>Telescope<cr>", "Telescope All" },
            }
        end,
        opts = function()
            local actions = require('telescope.actions')
            local action_set = require('telescope.actions.set')

            return {
                defaults = {
                    -- layout_strategy = "center",
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    mappings = {
                        i = {
                            ['<C-j>'] = actions.move_selection_next,
                            ['<C-k>'] = actions.move_selection_previous,
                            ['<C-d>'] = function(...)
                                action_set.shift_selection(..., 3)
                            end,
                            ['<C-u>'] = function(...)
                                action_set.shift_selection(..., -3)
                            end,
                            ['<C-l>'] = actions.select_default,
                            ['<C-Down>'] = actions.cycle_history_next,
                            ['<C-Up>'] = actions.cycle_history_prev,
                            ['<C-f>'] = actions.preview_scrolling_down,
                            ['<C-b>'] = actions.preview_scrolling_up,
                        },
                        n = {
                            ['<C-j>'] = actions.move_selection_next,
                            ['<C-k>'] = actions.move_selection_previous,
                            ['<C-d>'] = function(...)
                                action_set.shift_selection(..., 3)
                            end,
                            ['<C-u>'] = function(...)
                                action_set.shift_selection(..., -3)
                            end,
                            ['q'] = actions.close,
                            ['<C-c>'] = actions.close,
                            ['<Esc>'] = actions.close,
                        },
                    },
                },
                pickers = {
                    colorscheme = {
                        enable_preview = true
                    },
                },
                init = function()
                    local wk = require('which-key')
                    wk.add({
                        { "<leader>n", group = "LineNumber Options" },
                    })
                end,
            }
        end,
    },

    -- -------------------------------------------
    -- 5.7 nvim-cmp plug
    -- -------------------------------------------
    -- {
    --     'saghen/blink.cmp',
    --     enabled = false,
    --     dependencies = { 'rafamadriz/friendly-snippets' },
    --     version = '1.*',
    --
    --     ---@module 'blink.cmp'
    --     ---@type blink.cmp.Config
    --     opts = {
    --         -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    --         -- 'super-tab' for mappings similar to vscode (tab to accept)
    --         -- 'enter' for enter to accept
    --         -- 'none' for no mappings
    --         --
    --         -- All presets have the following mappings:
    --         -- C-space: Open menu or open docs if already open
    --         -- C-n/C-p or Up/Down: Select next/previous item
    --         -- C-e: Hide menu
    --         -- C-k: Toggle signature help (if signature.enabled = true)
    --         keymap = {
    --             preset = 'enter',
    --             ['<Tab>'] = {
    --                 'select_next',
    --                 'snippet_forward',
    --                 'fallback'
    --             },
    --             ['<S-Tab>'] = {
    --                 'select_prev',
    --                 'snippet_backward',
    --                 'fallback'
    --             },
    --             ['<CR>'] = {
    --                 'accept',
    --                 'fallback'
    --             },
    --         },
    --
    --         appearance = {
    --             nerd_font_variant = ''
    --         },
    --
    --         -- (Default) Only show the documentation popup when manually triggered
    --         completion = {
    --             documentation = {
    --                 auto_show = false
    --             },
    --             list = {
    --                 selection = {
    --                     -- preselect = function(ctx) return not require('blink.cmp').snippet_active({ direction = 1 }) end
    --                     preselect = false,
    --                 }
    --             }
    --         },
    --         sources = {
    --             default = { 'lsp', 'path', 'snippets', 'buffer' },
    --         },
    --         fuzzy = { implementation = "prefer_rust_with_warning" }
    --     },
    --     opts_extend = { "sources.default" }
    -- },
    {
        'L3MON4D3/LuaSnip',
        dependencies = {
            'rafamadriz/friendly-snippets',
            'honza/vim-snippets',
            -- "mireq/luasnip-snippets",
        },
        config = function(_, opts)
            require('luasnip').setup(opts)
            -- #guard in here(cpp)
            require("luasnip.loaders.from_vscode").lazy_load() -- friendly-snippets
            require("luasnip.loaders.from_snipmate").lazy_load() -- vim-snippets

            -- Seem has bug??
            -- inside this will call 'require("luasnip.loaders.from_vscode").lazy_load()' for us
            -- require('luasnip_snippets.common.snip_utils').setup() -- mireq/luasnip-snippets
        end
    },
    {
        "hrsh7th/nvim-cmp",
        version = false, -- last release is way too old
        enabled = true,
        event = { 'InsertEnter', 'CmdLineEnter' },
        dependencies = {
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lsp',
            'andersevenrud/cmp-tmux',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'dmitmel/cmp-cmdline-history',
            'hrsh7th/cmp-nvim-lsp-document-symbol',

            'petertriho/cmp-git',

            -- vsnip config:
            -- 'rafamadriz/friendly-snippets',
            -- 'hrsh7th/cmp-vsnip',
            -- 'hrsh7th/vim-vsnip',

            -- luasnip config:
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'doxnit/cmp-luasnip-choice',
        },
        init = function ()
            vim.keymap.set('i','<C-l>','<Plug>(vsnip-expand-or-jump)')
        end,

        opts = function()
            local cmp = require('cmp')

            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local feedkey = function(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
            end

            local snip_status_ok, luasnip = pcall(require, "luasnip")

            return {
                -- view = {
                --     entries = {
                --         {name = 'native'}
                --     }
                -- },
                enabled = function()
                    local disabled = false

                    -- Thanks to: https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-completion-in-certain-contexts-such-as-comments
                    -- Check if vim-visual-multi is active
                    -- VM plugin typically sets these global variables when active
                    disabled = disabled or (vim.g.VM_Extension ~= nil and vim.b.VM_Selection ~= nil)
                    disabled = disabled or vim.bo.filetype == 'TelescopePrompt'
                    return not disabled
                end,
                snippet = {
                    expand = function(args)
                        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                    end,
                },
                completion = {
                    completeopt = "menu,menunone,noinsert,noselect",
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-u>'] = cmp.mapping.scroll_docs(4),
                    ['<C-k>'] = cmp.mapping.close_docs(),

                    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    -- ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    -- ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-y>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping(function(fallback)
                        -- Thanks to: https://github.com/musabadru/astronvim/blob/dc6e52dc57e903a5a1a0c3f7b6e5bdc811663744/cmp.lua#L7
                        -- Thanks to github issue
                        -- workaround for https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/13
                        local entry = cmp.get_selected_entry()
                        -- If no entry is selected OR if it's from signature help, fallback
                        if not entry or (entry.source and entry.source.name == 'nvim_lsp_signature_help') then
                            fallback()
                        else
                            cmp.mapping.confirm {
                                -- do not auto select first item
                                select = false,
                            }(fallback)
                        end
                    end),
                    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ['<S-CR>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.


                    -- Super Tab(vim-vsnip)
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()

                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        -- elseif vim.fn["vsnip#available"](1) == 1 then
                        --     feedkey("<Plug>(vsnip-expand-or-jump)", "")
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function()
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        -- elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                        --     feedkey("<Plug>(vsnip-jump-prev)", "")
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = 'lazydev' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'luasnip' },
                    { name = 'luasnip_choice' },
                    { name = 'tmux' },
                    { name = 'path' },
                    -- { name = 'vsnip'}
                }),
                formatting = {
                    format = function(entry, vim_item)
                        if entry.source.name == 'tmux' then
                            vim_item.kind = 'tmux'
                            vim_item.menu = nil
                            vim_item.kind_hl_group = 'Special'
                        end
                        -- Thanks to: https://github.com/hrsh7th/nvim-cmp/issues/88#issuecomment-906585635
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
                        return vim_item
                    end
                },
                -- experimental = {
                --     ghost_text = true,
                -- },

            }
        end,


        config = function(_, opts)
            local cmp = require('cmp')
            cmp.setup(opts)

            local default_config = require('cmp.config.default')()
            local comparators = default_config.sorting.comparators
            local function button_down_cmdline_history(entry1, entry2)
                local source1 = entry1.source.name
                local source2 = entry2.source.name

                if source1 == 'cmdline_history' and source2 ~= 'cmdline_history' then
                    return false
                end
                if source1 ~= 'cmdline_history' and source2 == 'cmdline_history' then
                    return true
                end

                return nil
            end
            -- should after compare.exact/compare.offset
            table.insert(comparators, 1, button_down_cmdline_history)

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'cmdline' },
                    {
                        name = 'cmdline_history',
                        max_item_count = 10,
                        keyword_length = 4
                    }
                },
                formatting = {
                    fields = { 'abbr', 'menu', 'kind' }, -- Remove 'kind' from fields
                    format = function(entry, vim_item)
                        if entry.source.name == 'cmdline' then
                            vim_item.kind = 'Cmd'
                        end
                        if entry.source.name == 'cmdline_history' then
                            vim_item.kind = 'Hist'
                            vim_item.kind_hl_group = 'Special'
                            entry.completion_item.documentation = vim_item.abbr
                            vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
                        end
                        return vim_item
                    end
                },
                -- Ensure that cmdline source always show first
                sorting = {
                    priority_weight = 2,
                    comparators = comparators
                },
                ---@diagnostic disable-next-line: missing-fields
                matching = { disallow_symbol_nonprefix_matching = false }
            })

            cmp.setup.cmdline({'/', '?'}, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    -- { name = 'buffer' },
                    { name = 'cmdline_history' },
                },
                completion = {
                    autocomplete = false,  -- 禁用自动弹出
                },
                formatting = {
                    fields = { 'abbr', 'menu', 'kind' }, -- Remove 'kind' from fields
                    format = function(entry, vim_item)
                        if entry.source.name == 'cmdline_history' then
                            vim_item.kind = 'Hist'
                            vim_item.kind_hl_group = 'Special'
                        end
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
                        return vim_item
                    end
                },
            })
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources(
                    { { name = 'git' },  },
                    { { name = 'buffer' },  }
                ),
            })
            ---@diagnostic disable-next-line: missing-fields
            require("cmp_git").setup({})
        end,
    },
    -- {
    --     'ray-x/lsp_signature.nvim',
    --     event = "InsertEnter",
    --     opts = {
    --         bind = true,
    --         floating_window = false,
    --         hint_inline = function() return true end,
    --         hi_parameter = "LspInlayHint",
    --         hint_prefix = '',
    --     },
    --     config = function(_, opts)
    --         vim.keymap.set(
    --             { 'i', 'n' }, '<C-k>', function()
    --                 require('lsp_signature').toggle_float_win()
    --             end, { silent = true, noremap = true, desc = 'toggle signature' }
    --         )
    --
    --         require'lsp_signature'.setup(opts)
    --     end,
    -- },
    {
        "j-hui/fidget.nvim", -- LSP Progress message UI
        event = 'VeryLazy',
        cmd =  { 'NotifyHistory' },
        opts = function ()
            vim.api.nvim_create_user_command('NotifyHistory',
                'lua require("fidget.notification").show_history()'
                ,{})
            return {
                progress = {
                    display = { done_icon = "OK" }
                },
                notification = {
                    override_vim_notify = true,
                }
            }
        end
    },
    -- {
    --     "soulis-1256/eagle.nvim", -- LSP Mouse Hover
    --     opts = {
    --         --override the default values found in config.lua
    --     }
    -- },
    -- {
    --     "ray-x/lsp_signature.nvim",
    --     enabled = false,
    --     event = "VeryLazy",
    --     opts = {
    --         hint_prefix = {
    --             above = "v",  -- when the hint is on the line above the current line
    --             current = "<",  -- when the hint is on the same line
    --             below = "^",  -- when the hint is on the line below the current line
    --         },
    --     },
    --     keys = {
    --         {
    --             "<C-k>", "<cmd>lua require('lsp_signature').toggle_float_win()<CR>",
    --             mode = "i", desc = "Toggle signature", silent = true, noremap = true
    --         },
    --     },
    -- },
    {
        'dstein64/nvim-scrollview',
        dependencies = {
            'lewis6991/gitsigns.nvim',
        },
        opts = {
            excluded_filetypes = {'nerdtree'},
            current_only = true,
            -- base = 'buffer',
            -- column = 80,
            signs_on_startup = {'search','diagnostics','cursor', 'marks'},
            -- signs_on_startup = {'all'},
        },
        config = function (_, opts)
            require('scrollview').setup(opts)
            require('scrollview.contrib.gitsigns').setup()

            vim.api.nvim_create_user_command('ScrollViewForceEnable',function()
                vim.g.scrollview_byte_limit = -1
                vim.g.scrollview_line_limit = -1
                vim.cmd [[ e % ]]
            end,{})

        end

    },

    -- -------------------------------------------
    -- 5.8 LSP Plug
    -- -------------------------------------------
    {

        "williamboman/mason.nvim",
        cmd = "Mason",
        event = 'VeryLazy',
        opts = {
            registries = {
                "github:PEMessage/mason-registry", -- custom for tree-sitter-cli static
                "github:mason-org/mason-registry",
            },
        }
    },
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        -- See: https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/39
        -- This plugin not support lazyload, but we manually call
        event = 'VeryLazy',
        dependencies = {
            'williamboman/mason.nvim',
        },
        opts = function()
            local tree_sitter = 'tree-sitter-cli'  -- default

            -- Check if we're on Linux and get distro info
            if vim.fn.has('unix') == 1 then
                local handle = io.open('/etc/os-release', 'r')
                if handle then
                    local content = handle:read('*a')
                    handle:close()
                    -- Check if it's Ubuntu 18.04
                    if content:match('NAME=.*[Uu]buntu') and content:match('VERSION_ID="18%.04"') then
                        tree_sitter = 'tree-sitter-cli-ub1804'
                    end
                end
            end

            vim.api.nvim_create_user_command( 'MasonWhichTreeSitterCli',
                function() vim.print(tree_sitter) end,
                { desc = 'Print which tree-sitter-cli' }
            )

            return {
                ensure_installed = {
                    tree_sitter,
                },
            }
        end,
        config =  function (_, opts)
            require('mason-tool-installer').setup(opts)
            -- If not lazyload, this run_on_start will be called in VimEnter
            -- See: mason-tool-installer.nvim/plugin/mason-tool-installer.lua
            -- Since we lazyload it(will not receives VimEnter event), do it manually
            require('mason-tool-installer').run_on_start()
        end
    },
    {
        'williamboman/mason-lspconfig.nvim',
        event = 'BufRead',
        dependencies = {
            'williamboman/mason.nvim',
            'neovim/nvim-lspconfig',
        },
        opts = {
            ensure_installed = {
                -- 'pylsp',
                'lua_ls',
                -- 'gopls',
                -- 'clangd',
                -- 'ccls'

            },
            automatic_enable = {
                "lua_ls",
                "rust_analyzer",
                "neocmake",
                "clangd",
                "pylsp",
                "gopls",
                "bashls",
                "kotlin_language_server",
                -- "ts_ls",
                "tsgo",
                -- "kotlin_lsp", -- See: https://github.com/desugar-64/kotlin-lsp-workspace-generator for android
                -- "jdtls" -- leave it to nvim-jdtls
                -- "java_language_server",
                "glsl_analyzer",
            }
        },
        config = function(_,opts)
            require("mason-lspconfig").setup(opts)

            -- lspconfig
            vim.lsp.config("*", {
                inlay_hints = { enabled = true },
            })

            -- See: https://github.com/LuaLS/lua-language-server/blob/996e21adedc503e92958105cb8e8959eaa9ab6f9/doc/en-us/config.md#hintenable
            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        hint = {
                            enable = true,
                        },
                    }
                }
            })
            -- Thanks to:
            -- https://github.com/derekzyl/nvim/blob/6537239beda2b54925bd7640cf384d086c7dc4ea/lua/inlay_hint.lua#L56C1-L67C7
            vim.lsp.config("gopls", {
                on_attach = function(client, _)
                    -- Check if inlay hints are supported
                    if client.server_capabilities.inlayHintProvider then
                        client.config.settings = client.config.settings or {}
                        client.config.settings.gopls = client.config.settings.gopls or {}
                        client.config.settings.gopls.hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        }
                    else
                        vim.notify("gopls doesn't support inlay hints (maybe older version)")
                    end
                end,
            })
            -- enable gopls automatically even if not install from mason
            -- if we type this manually, we might need a `edit %` to make lsp work
            vim.lsp.enable('gopls')

            vim.lsp.config("kotlin_lsp", {
                inlay_hints = { enabled = true },
                root_markers = {
                    'workspace.json', -- Used to integrate your own build system
                    'settings.gradle.kts'
                }
            })

            vim.lsp.config("kotlin_language_server", {
                inlay_hints = { enabled = true },
                root_markers = {
                    'settings.gradle.kts'
                }
            })
            vim.lsp.config("pylsp", {
                inlay_hints = { enabled = true },
                settings = {
                    -- @See:
                    -- https://neovim.discourse.group/t/pylsp-config-is-not-taken-into-account/1846
                    -- Like I mentioned on your issue,
                    -- you need to have a nested pylsp table under settings
                    -- (according to their documentation)
                    pylsp = {
                        configurationSources = {
                            'pycodestyle',
                        },
                        plugins = {
                            -- yapf = {
                            --     enabled = true,
                            -- },
                            pycodestyle = {
                                enabled = true,
                                ignore = {
                                    -- 'W391',
                                    'E111', -- E111 indentation is not a multiple of 4
                                    'E114', -- E114 indentation is not a multiple of 4 (comment)
                                    'E206', -- E266 too many leading '#' for block comment
                                    'W504', -- W504 line break after binary operator
                                    'E501', -- E501 line too long (80 > 79 characters)
                                    'W391', -- W391 blank line at end of file
                                    'E302', -- E302 expected 2 blank lines, found 1
                                    'E303', -- E303 too many blank lines (3)
                                    -- 'E261', -- E261 at least two spaces before inline comment
                                },
                            }
                        }
                    }
                }
            })

            vim.lsp.config("ts_ls", {
                on_attach = function(client, bufnr)
                    -- disable for android.bp, only borrow synatx of javascript
                    local filename = vim.api.nvim_buf_get_name(bufnr)
                    if filename:match('%.bp$') then
                        client.stop()
                        return false
                    end

                    -- Copy from nvim-lspconfig/lsp/ts_ls.lua
                    vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptSourceAction', function()
                        local source_actions = vim.tbl_filter(function(action)
                            return vim.startswith(action, 'source.')
                        end, client.server_capabilities.codeActionProvider.codeActionKinds)

                        vim.lsp.buf.code_action({
                            context = {
                                only = source_actions,
                                diagnostics = {},
                            },
                        })
                    end, {})
                end,
            })
            vim.lsp.config("tsgo", {
                settings = {
                    typescript = {
                        inlayHints = {
                            parameterNames = { enabled = "literals" },
                            parameterTypes = { enabled = true },
                            variableTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                            enumMemberValues = { enabled = true },
                        },
                    },
                },
            })

            vim.lsp.config('java_language_server', {
                -- borrow root marker from jdtls
                root_markers = vim.lsp.config["jdtls"].root_markers,
                trace = "verbose",
                -- capabilities = {
                --     workspace = {
                --         workspaceEdit = {
                --             documentChanges = true,
                --         },
                --     },
                --     textDocument = {
                --         definition = {
                --             dynamicRegistration = true,
                --             linkSupport = true
                --         }
                --     },
                --     documentLink = {
                --         dynamicRegistration = true,
                --     },
                -- },
                -- Dynamic settings handler
                on_attach = function(client)
                    local root = client.workspace_folders and client.workspace_folders[1].name
                    if not root then return end

                    local settings_file = root .. '/java_language_server.json'
                    vim.notify("Found settings " .. settings_file)
                    local f = io.open(settings_file, "r")

                    if f then
                        local content = f:read("*all")
                        f:close()

                        local ok, decoded = pcall(vim.fn.json_decode, content)
                        if ok and decoded then
                            -- Extend the client settings with the JSON content
                            vim.notify("Parse success")
                            client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, decoded)
                            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                        else
                            vim.notify("Parse fail")
                        end
                    end
                end,
                handlers = {
                    ['client/registerCapability'] = function(e, r, ct, cf)
                        -- Thanks to
                        -- https://github.com/cdnspix/dotfiles/blob/3bfcfcd446f571fa0bb717f87749b7225c9d4d4f/private_dot_config/nvim/lsp/java_language_server.lua#L7
                        local registration = {
                            registrations = { r },
                        }
                        return vim.lsp.handlers['client/registerCapability'](e, registration, ct, cf)
                    end,
                    -- ["textDocument/definition"] = function(err, result, ctx, config)
                    --     local original_handler = vim.lsp.handlers["textDocument/definition"]
                    --     if not result or vim.tbl_isempty(result) then
                    --         original_handler(err, result, ctx, config)
                    --         return
                    --     end
                    --
                    --     local locations = vim.islist(result) and result or { result }
                    --     vim.print(locations)
                    --
                    --     for _, location in ipairs(locations) do
                    --         local uri = location.uri or location.targetUri
                    --         if uri:match("^jar:file:") then
                    --             local zip_path, internal_path = uri:match("jar:file://(.+)!/(.+)")
                    --
                    --             if zip_path and internal_path then
                    --                 local bufnr_name = "zipfile://" .. zip_path .. "::" .. internal_path
                    --
                    --                 if location.uri then location.uri = bufnr_name end
                    --                 if location.targetUri then location.targetUri = bufnr_name end
                    --             end
                    --         end
                    --     end
                    --     original_handler(err, result, ctx, config)
                    -- end
                }
            })
        end,
    },
    {
        'p00f/clangd_extensions.nvim',
        event = "LspAttach",
        ft = {'c', 'cpp'},
        cmd = {
            'ClangdTypeHierarchy'
        }
    },
    {
        'mfussenegger/nvim-jdtls',
        enabled = true,
        version = false, -- set this if you want to always pull the latest change
        ft = { "java" }, -- THIS IS KEY, if not this, everything will broken
        -- UPDATE: this will cause jump to class not work as expect, but other function will do work
        -- See: https://github.com/mfussenegger/nvim-jdtls/issues/639#issuecomment-3079720936
        dependencies = {
            'mfussenegger/nvim-dap',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            "neovim/nvim-lspconfig",
        },
        -- opts = {
        --     cmd = {}, -- leave to config staged
        --     root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw', '.root'}, { upward = true })[1]),
        -- },
        config = function ()
            -- See: https://zhuanlan.zhihu.com/p/574746992
            -- And: https://github.com/redhat-developer/vscode-java/wiki/JDK-Requirements#java.configuration.runtimes
            ---@diagnostic disable-next-line: unused-function
            local function get_runtime_dir()
                local runtime = {
                    {
                        name = 'JavaSE-11',
                        path = '/usr/lib/jvm/java-11-openjdk-amd64/',
                    },
                    {
                        name = 'JavaSE-1.8',
                        path = '/usr/lib/jvm/java-1.8.0-openjdk-amd64/',
                    },
                    {
                        name = 'JavaSE-17',
                        path = '/usr/lib/jvm/java-1.17.0-openjdk-amd64/',
                    },
                    {
                        name = 'JavaSE-21',
                        path = '/usr/lib/jvm/java-21-openjdk-amd64/',
                    },
                }
                return runtime
            end
            local env = {
                ---@diagnostic disable-next-line: undefined-field
                HOME = vim.uv.os_homedir(),
                XDG_CACHE_HOME = os.getenv 'XDG_CACHE_HOME',
                JDTLS_JVM_ARGS = os.getenv 'JDTLS_JVM_ARGS',
            }

            local cache_dir = ( env.XDG_CACHE_HOME and env.XDG_CACHE_HOME or env.HOME .. '/.cache' ) .. '/jdtls'

            -- We using mason-lspconfig, not using it according to readme
            -- local jdtls = require('jdtls')
            local mason_root = require('mason.settings').current.install_root_dir
            local root_markers = {'javaroot', '.repo', 'gradlew', 'settings.gradle.kts'}
            local root_dir = require('jdtls.setup').find_root(root_markers)
            local cache_dirname = 'common'
            if root_dir then
                cache_dirname = root_dir:gsub('/', '_'):gsub('\\', '_')
            end
            local executable = 'jdtls'

            if vim.fn.executable(executable) ~= 1 then
                return
            end

            vim.api.nvim_create_user_command('JdtWorkspaceDir',
                function()
                    vim.print(cache_dir .. '/workspace/' .. cache_dirname)
                end,
                {
                    desc = 'Print the workspace directory path'
                }
            )


            local opts = {
                -- cmd = require('lspconfig').jdtls.document_config.default_config.cmd,
                cmd = {
                    -- require('lspconfig').jdtls.document_config.default_config.cmd[1],
                    'jdtls',
                    '--jvm-arg=-Dlog.level=ALL',
                    '-configuration',
                    cache_dir .. '/config',
                    '-data',
                    cache_dir .. '/workspace/' .. cache_dirname
                    -- cache_dir .. '/workspace/' .. vim.fn.fnamemodify(root_dir, ":p:h:t"),
                },
                -- See: https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#configuration-verbose
                -- See: https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Language-Server-Settings-&-Capabilities
                root_dir = root_dir,
                init_options = {
                    bundles = {
                        vim.fn.glob(
                            mason_root .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
                            true
                        ),
                    },
                    settings = {
                        configuration = {
                            runtimes = get_runtime_dir(),
                        },
                        java = {
                            contentProvider = { preferred = 'fernflower' },
                            inlayhints = {
                                parameterNames = { enabled = true },
                            },
                            -- autobuild = { enabled = true },
                            import = {
                                gradle = {
                                    -- See: https://www.reddit.com/r/neovim/comments/1m3v9kk/jdtls_keeps_regenerating_my_classpath_for_a/
                                    -- do not let jdtls generate .classpath, manually generate it
                                    enabled = false,
                                    -- jvmArguments = "-Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=7890 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=7890",
                                    -- wrapper = {
                                    --     enabled = false,
                                    -- }
                                },
                            },
                            jdt = {
                                ls = {
                                    androidSupport = true,
                                },
                            },
                            references = {
                                includeAccessors = true,
                                includeDecompiledSources = true,
                            },
                        },
                    },
                },
            }
                -- DO NOT SET SETTINGS, UNLESS YOU KNOW EVERYTHING IT WILL OVERWRITE DEFAULT ONE
                -- settings = {
                --     java = {
                        -- configuration = {
                        --     runtimes = get_runtime_dir(),
                        -- },
                        -- import = {
                        --     gradle = {
                        --         -- See: https://www.reddit.com/r/neovim/comments/1m3v9kk/jdtls_keeps_regenerating_my_classpath_for_a/
                        --         -- do not let jdtls generate .classpath, manually generate it
                        --         enabled = false,
                        --     },
                        -- },
                        -- jdt = {
                        --     ls = {
                        --         -- See:
                        --         -- https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/3284#issuecomment-2577158493
                        --         androidSupport = {
                        --             enabled = true, -- Enable Android support
                        --         },
                        --     },
                        -- },
                --     },
                -- },
            local dap = require('dap')
            dap.configurations.java = {
                {
                    type = 'java';
                    request = 'attach';
                    name = "Debug (Attach) - Remote";
                    hostName = "127.0.0.1";
                    port = 5005;
                    -- for multi project, using this
                    -- projectName = "settings_info",
                    -- Also See: https://source.android.com/docs/core/tests/debug/gdb?hl=zh-cn#app-startup
                    -- Also See: https://codeberg.org/mfussenegger/nvim-dap/wiki/Java
                },
            }

            vim.api.nvim_create_autocmd("Filetype", {
				pattern = "java",
				callback = function()
                    local current_file = vim.fn.expand("%:p")
                    -- Exclude paths containing /tmp/kotlinlangserver
                    if string.match(current_file, "/tmp/kotlinlangserver") then
                        return
                    end
                    require("jdtls").start_or_attach(opts)
				end,
			})
            -- vim.inspect(opts)
            -- jdtls.start_or_attach(opts)
        end
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    -- -------------------------------------------
    -- 5.9 DAP Plug
    -- -------------------------------------------
    {
        'mfussenegger/nvim-dap',
        config = function ()
            local dap = require("dap")
            local repl = require("dap.repl")
            repl.commands = vim.tbl_extend("force", repl.commands, {
                -- Add a new alias for the existing .exit command
                exit = {'exit', '.exit', '.bye'},
                -- Add your own commands; run `.echo hello world` to invoke
                -- this function with the text "hello world"
                custom_commands = {
                    ['.echo'] = function(text)
                        dap.repl.append(text)
                    end,
                    -- Hook up a new command to an existing dap function
                    ['.restart'] = dap.restart,
                },
            })

            dap.adapters.gdb = {
                id = 'gdb',
                type = 'executable',
                command = 'gdb',
                args = { '--quiet', '--interpreter=dap' },
            }

            local gdb = {
                name = 'Run native GDB DAP',
                type = 'gdb',
                request = 'launch',
                -- This requires special handling of 'run_last', see
                -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
                program = function()
                    local path = vim.fn.input({
                        prompt = 'Path to executable: ',
                        default = vim.fn.getcwd() .. '/',
                        completion = 'file',
                    })

                    return (path and path ~= '') and path or dap.ABORT
                end,
            }
            dap.configurations.c = { gdb }
            dap.configurations.cpp = { gdb }

        end
    },
    {
        'jay-babu/mason-nvim-dap.nvim',
        event = 'VeryLazy',
        dependencies = {
            'williamboman/mason.nvim',
            'mfussenegger/nvim-dap',
        },
        opts = {
            handlers = {
                function(config)
                    -- all sources with no handler get passed here
                    -- Keep original functionality
                    require('mason-nvim-dap').default_setup(config)
                end,

                -- See: https://github.com/jay-babu/mason-nvim-dap.nvim/tree/main/lua/mason-nvim-dap/mappings/adapters
                -- mason not implementation it
                -- javadbg = nil,
                javadbg = function (_)
                    -- leava it to nvim-jdtls to setup
                end,
                cppdbg = function (config) -- cpptools in mason
                    config.configurations = vim.list_extend(config.configurations, {
                        {
                            name = 'Attach to gdb-multiarch :1234',
                            type = 'cppdbg',
                            request = 'launch',
                            MIMode = 'gdb',
                            miDebuggerServerAddress = 'localhost:1234',
                            miDebuggerPath = vim.fn.exepath('gdb-multiarch'),
                            cwd = '${workspaceFolder}',
                            program = function()
                                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                            end,
                        },
                    })
                    config.adapters.options = { initialize_timeout_sec = 180 }
                    require('mason-nvim-dap').default_setup(config)
                end,
            }
        },
    },
    -- -------------------------------------------
    -- 5.8 Linter
    -- -------------------------------------------
    {
        'mhartington/formatter.nvim',
        dependencies = {
            'williamboman/mason.nvim',
        },
        event = 'VeryLazy',
        opts = function(_,_)
            return {
                logging = true,
                log_level = vim.log.levels.WARN,
                filetype = {
                    python = {
                        require("formatter.filetypes.python").autopep8,
                    },
                    -- Use the special "*" filetype for defining formatter configurations on
                    -- any filetype
                    ["*"] = {
                        -- "formatter.filetypes.any" defines default configurations for any
                        -- filetype
                        require("formatter.filetypes.any").remove_trailing_whitespace,
                        -- Remove trailing whitespace without 'sed'
                        -- require("formatter.filetypes.any").substitute_trailing_whitespace,
                    }
                }
            }
        end,
    },
    -- {
    --     "cappyzawa/trim.nvim",
    --     opts = {
    --         trim_last_line = false,
    --         trim_first_line = false,
    --
    --         trim_on_write = true,
    --     },
    --     config = function(_, opts)
    --         require("trim").setup(opts)
    --     end
    -- },
    -- -------------------------------------------
    -- 5.9 DAP & LSP UI
    -- -------------------------------------------
    {
        "rcarriga/nvim-dap-ui",
        cmd = { 'DapUiToggle' },
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        },
        opts = {
            controls = {
                element = "repl",
                enabled = true,
                icons = {
                    disconnect = "D",
                    pause = "S",
                    play = "C",
                    run_last = "R",
                    step_back = "←",
                    step_into = "↓",
                    step_out = "↑",
                    step_over = "→",
                    terminate = "X"
                }
            },
            icons = {
                collapsed = "*",
                current_frame = ">",
                expanded = "-"
            },
        },
        config = function (_, opts)
            require("dapui").setup(opts)
            vim.api.nvim_create_user_command('DapUiToggle', function() require('dapui').toggle() end, { nargs = 0 })
        end,
    },
    {
        'Weissle/persistent-breakpoints.nvim',
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        cmd = { "PBToggleBreakpoint" },
        keys = {
            {
                "<F1>", "<cmd>PBToggleBreakpoint<CR>",
                mode = "n", desc = "Toggle breakpoint", noremap = true, silent = true
            },
        },
        opts = {
            load_breakpoints_event = { "BufReadPost" },
        },
    },
    {
        "danymat/neogen",
        cmd = {
            "Neogen"
        },
        dependencies = {
            -- 'hrsh7th/vim-vsnip',
            'L3MON4D3/LuaSnip',
        },
        opts = {
            -- snippet_engine = "vsnip"
            snippet_engine = "luasnip"
        },
        -- Uncomment next line if you want to follow only stable versions
        -- version = "*"
    },
    {

        'nvimdev/lspsaga.nvim',
        -- Note: this also have barbecue.nvim feature something like
        -- nvim › init.lua › 󰅨 require("lazy").setup ›  [25]
        dependencies = {
            'nvim-treesitter/nvim-treesitter', -- optional
            -- 'nvim-tree/nvim-web-devicons'     -- optional
        },
        enabled = false,
        opts = {
            ui = {
                code_action = '*',
                devicon = false,
            },
            code_action = {
                keys = {
                    quit = { 'q', '<ESC>', '<C-c>' },
                    exec = '<CR>',
                }
            },
            lightbulb = {
                enable = true,
                sign = false,
                virtual_text = true,
                -- debounce = 50,
            },
            rename = {
                keys = {
                    quit = { '<ESC>', '<C-c>' },
                    exec = '<CR>',
                }
            },
            symbol_in_winbar = {
                enable = false,
                separator = ' > '
            },
            finder = {
                max_height = 0.6,
                keys = {
                    vsplit = {'v','s'},
                    quit = { '<ESC>', '<C-c>','q' },
                    tabe = {'<enter>','t'}
                }
            },
            definition = {
                width = 0.6,
                height = 0.5,
                save_pos = false,
                keys = {
                    quit = { 'q', '<ESC>', '<C-c>' },
                    edit = { '<C-w>o', '<enter>','<C-]>' },
                    vsplit = { '<C-w>v', '<space>' },
                    split = '<C-w>i',
                    tabe = '<C-w>t',
                    tabnew = '<C-w>n',
                },
            },
        },
        config = function(_, opts)
            require('lspsaga').setup(opts)

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('LspsagaKeymaps', {}),
                callback = function(args)
                    -- local client = vim.lsp.get_client_by_id(args.data.client_id)

                    local map = vim.keymap.set
                    local bufnr = args.buf

                    map('n', 'go', '<cmd>Lspsaga show_line_diagnostics<cr>', { silent = true, noremap = true, buffer = bufnr })
                    map('n', 'Q', '<cmd>Lspsaga finder tyd+ref+imp+def<cr>', { silent = true, noremap = true, buffer = bufnr })
                    map('n', '<C-q>', '<cmd>Lspsaga code_action<cr>', { silent = true, noremap = true, buffer = bufnr })
                end,
            })
        end,
    },
    {
        'stevearc/aerial.nvim',
        event = "VeryLazy",
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            -- "nvim-tree/nvim-web-devicons"
        },
    },
    -- {
    --     'liuchengxu/vista.vim',
    --     config = function ()
    --         vim.g.vista_echo_cursor_strategy = 'scroll'
    --         vim.cmd [[ let g:vista#renderer#enable_icon = 0 ]]
    --     end,
    --     keys = {
    --         { "<leader>av", "<cmd>Vista!!<cr>", desc = "Open Vista bar" },
    --     }
    -- },
    {
        'ldelossa/litee.nvim',
        lazy = true,
        main = 'litee.lib',
        opts = {
            notify = { enabled = false },
            panel = {
                orientation = "right",
                panel_size = 30,
            },
        },
    },
    {
        'ldelossa/litee-calltree.nvim',
        dependencies = 'ldelossa/litee.nvim',
        event = "LspAttach",
        main = 'litee.calltree',
        opts = {
            on_open = "panel",
            map_resize_keys = false,
        },
    },
    -- -------------------------------------------
    -- 5.10 AI
    -- -------------------------------------------
    -- {
    --     "yetone/avante.nvim",
    --     event = "VeryLazy",
    --     lazy = false,
    --     enabled = false,
    --     version = false, -- set this if you want to always pull the latest change
    --     opts = {
    --         provider = "ollama",
    --         vendors = {
    --             ollama = {
    --                 __inherited_from = "openai",
    --                 api_key_name = "",
    --                 -- endpoint = "http://80/v1",
    --                 model = "qwen2.5-coder",
    --             },
    --         },
    --     },
    --     -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    --     build = "make",
    --     -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    --     dependencies = {
    --         "stevearc/dressing.nvim",
    --         "nvim-lua/plenary.nvim",
    --         "MunifTanjim/nui.nvim",
    --         --- The below dependencies are optional,
    --         "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    --         {
    --             -- Make sure to set this up properly if you have lazy=true
    --             'MeanderingProgrammer/render-markdown.nvim',
    --             opts = {
    --                 file_types = { "markdown", "Avante" },
    --             },
    --             ft = { "markdown", "Avante" },
    --         },
    --     },
    -- },


    -- -------------------------------------------
    --- @diagnostic disable-next-line: missing-fields
}, {
        install = {
            -- install missing plugins on startup. This doesn't increase startup time.
            missing = true,
            -- try to load one of these colorschemes when starting an installation during startup
            colorscheme = { "habamax" },
        },
        defaults = {
            -- lazy = true
        },
        ui = {
            icons = {
                cmd = "cmd:",
                config = "cf: ",
                event = "ev: ",
                ft = "ft: ",
                init = "init: ",
                import = "import: ",
                keys = "keys: ",
                lazy = "lazy ",
                loaded = "i",
                not_loaded = "n",
                plugin = "plug: ",
                runtime = "r ",
                require = "req: ",
                source = "src:  ",
                start = "",
                task = "t",
                list = {
                    "-",
                    "-",
                    "=",
                    "=",
                },
            }
        }
    }) --End Lazy.nvim Quote
-- ===========================================

-- 6. KeyMap Zone
-- ===========================================
-- local wk = require('which-key')
function PE.WkCheck()
    -- return require('which-key')
    local status, maywk = pcall(require, 'which-key')
    if status then
        return maywk
    else
        -- Fallback to a dummy table with a no-op register function
        return {
            register = function(...) end
        }
    end
end
local wk = PE.WkCheck()
---@diagnostic disable-next-line: redefined-local
local section = function ()
    -- -------------------------------------------
    -- 6.1 Basic I / N Mode
    -- -------------------------------------------

    -- Emacs-like Keymap
    vim.keymap.set('!','<C-a>','<home>')
    vim.keymap.set('!','<C-e>','<end>')
    vim.keymap.set('n','ZA','<cmd>confirm quitall<CR>', { desc = "Quit All" })
    vim.keymap.set('n','ZX','<cmd>confirm quit<CR>', { desc = "Quit This" })

    -- better up/down
    vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

    -- Move to window using the <meta>+<shift>+hjkl keys
    -- vim.keymap.set("n", "<M-S-H>", "<C-W>h", { desc = "Go to left window", remap = true })
    -- vim.keymap.set("n", "<M-S-J>", "<C-W>j", { desc = "Go to lower window", remap = true })
    -- vim.keymap.set("n", "<M-S-K>", "<C-W>k", { desc = "Go to upper window", remap = true })
    -- vim.keymap.set("n", "<M-S-L>", "<C-W>l", { desc = "Go to right window", remap = true })

    -- vim.keymap.set("n","<M-S-V>","<cmd>wincmd v<CR>",{ desc = "Vertical split", remap = true })
    -- vim.keymap.set("n","<M-S-C>","<cmd>wincmd c<CR>",{ desc = "Close current pane", remap = true })
    vim.keymap.set( 'n',  '<M-S-C>', ':vsplit<cr>',    { silent = true } )
    vim.keymap.set( 'n',  '<M-S-X>', ':confirm q<cr>', { silent = true } )

    vim.keymap.set( 'n',  '<M-S-E>', ':tabn<cr>' )
    vim.keymap.set( 'n',  '<M-S-W>', ':tab new<cr>' )
    vim.keymap.set( 'n',  '<M-S-Q>', ':tabp<cr>' )

    -- Switch Buffer using <meta>+<shift>+pn
    vim.keymap.set("n", "<M-S-N>", "<cmd>bn<CR>", { desc = "Go to right window", remap = true })
    vim.keymap.set("n", "<M-S-P>", "<cmd>bp<CR>", { desc = "Go to right window", remap = true })

    -- Switch Tabe using [t or ]t
    -- See: https://github.com/neovim/neovim/commit/bb7604eddafb31cd38261a220243762ee013273a
    -- Also Check: https://github.com/neovim/neovim/blame/master/runtime/doc/vim_diff.txt
    -- to see update of nvim default-mapping
    -- become default mapping in 0.11
    if vim.fn.has('nvim-0.11') == 0 then
        vim.keymap.set("n", "]t", "<cmd>tabn<CR>", { desc = "Go to Next Tab", remap = true })
        vim.keymap.set("n", "[t", "<cmd>tabp<CR>", { desc = "Go to Previous Tab", remap = true })
    end

    -- Move Lines
    vim.keymap.set("n", "<M-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
    vim.keymap.set("n", "<M-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
    vim.keymap.set("i", "<M-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
    vim.keymap.set("i", "<M-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })

    -- let mini.move handle it, which support
    -- charwise with v, linewise with V, and blockwise with CTRL-V
    -- vim.keymap.set("v", "<M-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
    -- vim.keymap.set("v", "<M-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

    vim.keymap.set('x', 'p', 'P', { noremap = true })
    vim.keymap.set('x', 'P', 'p', { noremap = true })

    -- When exit cmdline, clean input so that will not go into cmdwin(<c-f> or q:c)
    vim.keymap.set('c', '<C-c>', [[getcmdtype() == ':' ? '<C-u><C-c>' : '<C-c>']], { noremap = true, expr = true })

    -- Jump Section
    vim.keymap.set(
        "n", "gp",
        '`[' .. 'v' .. '`]',
        { desc = "Go to Previous Paste", noremap = true }
    )

    vim.keymap.set('n', ']d', function()
        vim.diagnostic.jump({ count = vim.v.count1, float = true })
    end, { desc = 'Jump to the next diagnostic in the current buffer' })

    vim.keymap.set('n', '[d', function()
        vim.diagnostic.jump({ count = -vim.v.count1, float = true })
    end, { desc = 'Jump to the previous diagnostic in the current buffer' })

    -- terminal
    vim.keymap.set('t', '<M-q>', '<C-\\><C-n>', { noremap = true, silent = true })

    vim.api.nvim_create_autocmd('TermOpen', {
        pattern = '*',
        callback = function()
            local buf = vim.api.nvim_get_current_buf()

            -- Buffer-local normal mode mapping to re-enter insert mode
            vim.keymap.set('n', '<M-q>', 'i', {
                buffer = buf,
                noremap = true,
                silent = true
            })
        end
    })


    -- Lsp
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { desc = 'Go to Declaration' })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to Declaration' })
    -- Format entire document (Normal mode)
    -- Recommand using `gq` (vim native) to call formatexpr or formatprg
    vim.keymap.set({'n', 'v'}, '<leader>f', vim.lsp.buf.format, { desc = 'Format entire document' })
    -- Format selected range (Visual mode)
    -- vim.keymap.set('v', '<leader>F', function()
    --     local start_row = vim.api.nvim_buf_get_mark(0, '<')[1]
    --     local end_row = vim.api.nvim_buf_get_mark(0, '>')[1]
    --     vim.lsp.buf.format({
    --         range = {
    --             ['start'] = { start_row, 0 },
    --             ['end'] = { end_row, 0 },
    --         },
    --     })
    -- end, { desc = 'Format selected range' })


    vim.keymap.set('x', '&', function()
        -- Save current search register
        local prev_search = vim.fn.getreg('/')

        local saved_register = vim.fn.getreg('v')
        vim.cmd('noau normal! "vy')
        local visual_selection = vim.fn.getreg('v')
        vim.fn.setreg('v', saved_register)

        local escaped_pattern = vim.fn.escape(visual_selection, '\\/.*$^~[]')

        local new_pattern = escaped_pattern
        if prev_search and prev_search ~= "" then
            new_pattern = prev_search .. '\\|' .. escaped_pattern
        end

        vim.fn.setreg('/', new_pattern)
        vim.fn.histadd('search', new_pattern)
        vim.cmd('set hls')
    end, { desc = 'Search selection and combine with previous' })

    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('LspCustomKeyMaps', {}),
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            local bufnr = args.buf

            vim.keymap.set('n', '<F2>', vim.lsp.buf.rename,
                { silent = true, noremap = true, buffer = bufnr, desc = 'Rename' }
            )

            vim.keymap.set('n', 'gk', vim.lsp.buf.code_action,
                { silent = true, noremap = true, buffer = bufnr, desc = 'Code Action' }
            )
            vim.keymap.set('x', 'gk', vim.lsp.buf.code_action,
                { silent = true, noremap = true, buffer = bufnr, desc = 'Range Code Action' }
            )

            vim.keymap.set("n", "gd", '<c-]>',
                -- vim.lsp.buf.definition will cause error when meet swapfile
                { silent = true, noremap = true, buffer = bufnr, desc = 'Goto Definition' }
            )
            vim.keymap.set("n", "gr", vim.lsp.buf.references,
                { silent = true, noremap = true, buffer = bufnr, nowait = true, desc = 'Goto Reference' }
            )

            if client and client.name == 'clangd' then
                vim.keymap.set('n', '<m-h>', '<cmd>LspClangdSwitchSourceHeader<cr>', { silent = true, noremap = true, buffer = bufnr })
            end

            -- Thanks to: https://github.com/sangoX35X/dotfiles/blob/7aa159668f476f4428422353f48a21fc26797dc4/nvim/lua/plugin/lsp.lua#L126
            if client and client:supports_method('textDocument/typeHierarchy', bufnr) then
                vim.api.nvim_create_user_command('LspTypeHierarchy',
                    function(opts)
                        local direction = opts.args or 'subtypes'
                        if direction == 'subtypes' or direction == 'supertypes' then
                            vim.lsp.buf.typehierarchy(direction)
                        else
                            vim.notify('LspTypeHierarchy: argument must be "subtypes" or "supertypes"', vim.log.levels.ERROR)
                        end
                    end,
                    {
                        nargs = '?',
                        complete = function()
                            return { 'subtypes', 'supertypes' }
                        end,
                        desc = 'Show type hierarchy (subtypes|supertypes)'
                    }
                )
            end
        end,
    })

    -- -------------------------------------------
    -- 6.2 Leader Keymap
    -- -------------------------------------------
    vim.keymap.set('n', '<leader>rce' , '<cmd>tabe $MYVIMRC<CR>' , { desc = 'Edit MYVIMRC' } )
    vim.keymap.set('n', '<leader>``' , '<cmd>nohlsearch<CR>' , { desc = 'Close Highlight' } )
    -- vim.keymap.set('n', '<leader><leader>ga' , '<cmd>nohlsearch<CR>' , { desc = 'Close Highlight' } )

    vim.keymap.set("n", "<leader>wp",
        function() PE.ToggleOpts("wrap") end,
        { desc = "Toggle Word Wrap" })

    vim.keymap.set('n', '<leader>ro', function()
        vim.opt.modifiable = true
        vim.opt.buftype = ''

        -- Toggle readonly using vim.o (gets/sets the actual boolean value)
        vim.o.readonly = not vim.o.readonly

        if vim.o.readonly then
            print("Read-only mode enabled")
        else
            print("Read-only mode disabled")
        end
    end, { silent = true, desc = "Toggle readonly and set modifiable" })


    -- Also see @Line-Number
    vim.keymap.set("n", "<leader>nu",
        function() PE.ToggleOpts("number") end,
        { desc = "Toggle Line Numbers" })
    vim.keymap.set("n", "<leader>nr",
        function() PE.ToggleOpts("relativenumber") end,
        { desc = "Toggle Relative Numbers" })

    -- vim.keymap.set('v','tt','<cmd>s/\\s\\+$//e<cr>',{ desc = 'Clean tail spaces'})
    vim.cmd [[ vnoremap tt :s/\s\+$//e<CR> ]]

    wk.add({
        { "<leader>t", group = "Tabe Options" },
    })
    vim.keymap.set("n", "<leader>tb", '<cmd>tab ball<cr>',
        { desc = "Tab Ball buffers" })

    -- vim.keymap.set("n", "<leader>o/",'/', { noremap = true, desc = "Origin VIM /" })
    -- vim.keymap.set("v", "<leader>y",'"+y', { noremap = true, desc = "Copy to clipboard(Reg\")" })



    -- Function to toggle diagnostics
    function PE.ToggleDiagnostics()
        local enabled = not vim.diagnostic.is_enabled()
        if enabled then
            vim.diagnostic.enable(false)
        else
            vim.diagnostic.enable()
        end
    end
    vim.keymap.set('n', '<leader>`d', PE.ToggleDiagnostics, { noremap = true, silent = true , desc = "Toggle diagnostic" })

    vim.api.nvim_create_user_command('PEMouseON', function() vim.o.mouse = 'a' end, {})
    vim.api.nvim_create_user_command('PEMouseOFF', function() vim.o.mouse = '' end, {})

    vim.api.nvim_create_user_command('IgnoreWhitespaceToggle', function()
        local current_diffopt = vim.o.diffopt
        local has_iwhite = string.find(current_diffopt, 'iwhite') ~= nil

        if has_iwhite then
            -- Remove iwhite from diffopt
            vim.o.diffopt = current_diffopt:gsub(',?iwhite', '')
            vim.notify("Whitespace ignoring disabled")
        else
            -- Add iwhite to diffopt
            if current_diffopt == '' then
                vim.o.diffopt = 'iwhite'
            else
                vim.o.diffopt = current_diffopt .. ',iwhite'
            end
            vim.notify("Whitespace ignoring enabled")
            vim.cmd [[ edit % ]]
        end
    end, {})
    vim.keymap.set('n', '<leader>tw', '<cmd>IgnoreWhitespaceToggle<CR>')

    function PE.ToggleInlayHint()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        vim.notify("Now inlayhint is " ..  tostring(vim.lsp.inlay_hint.is_enabled()))
    end

    vim.api.nvim_create_user_command('InlayHintToggle', PE.ToggleInlayHint, {});
    vim.api.nvim_create_user_command('ToggleInlayHint', PE.ToggleInlayHint, {});

    -- vim.keymap.set('n', '<leader>q', [[:vimgrep /<C-r>// %<CR>]], { desc = "vimgrep @/" })
    vim.keymap.set('n', '<leader>q', function()
        local search_term = vim.fn.getreg('/')
        local cmd = string.format("vimgrep /%s/j %%", search_term)
        vim.fn.histadd("cmd", cmd)
        vim.cmd(cmd)
        vim.cmd("copen")
    end, { desc = "vimgrep @/ (no jump, add to history)" })

end ; section()

-- 7. Function Zone
-- ===========================================


function PE.ToggleOpts(option, silent, values)
    local echo = function(str)
        return vim.api.nvim_echo(
            { {str , "Question"} }, -- {chunks}: A list of [text, hl_group]
            false,                -- {history}:if true, add to |message-history|.
            {}  -- {opts}: Optional parameters.
        )
    end
    if values then
        if vim.opt_local[option]:get() == values[1] then
            vim.opt_local[option] = values[2]
        else
            vim.opt_local[option] = values[1]
        end
        return echo("Set " .. option .. " to " .. vim.opt_local[option]:get())
    end
    vim.opt_local[option] = not vim.opt_local[option]:get()
    if not silent then
        if vim.opt_local[option]:get() then
            echo("Enabled " .. option)
        else
            echo("Disabled " .. option)
        end
    end
end


function PE.man()
    require("telescope.builtin").man_pages({
        sections={"ALL"},
        attach_mappings = function(_, map)
            map(
                {'i'},
                '<Enter>',
                function(...)
                    return require("telescope.actions").select_tab(...)
                end
            )
            return true
        end,
    })
    -- vim.cmd [[ wincmd w]]
    -- vim.cmd [[ wincmd x]]
end

function PE.PrintTbl(tb)
    local key = ""
    function RecuPrint(table , level)
        level = level or 1
        local indent = ""
        for _ = 1, level do
            indent = indent.."  "
        end

        if key ~= "" then
            print(indent..key.." ".."=".." ".."{")
        else
            print(indent .. "{")
        end

        key = ""
        for k,v in pairs(table) do
            if type(v) == "table" then
                key = k
                RecuPrint(v, level + 1)
            else
                local content = string.format("%s%s = %s", indent .. "  ",tostring(k), tostring(v))
                print(content)
            end
        end
        print(indent .. "}")
    end
    return RecuPrint(tb)
end


vim.cmd('command! PCD :cd %:p:h')

local function yank_windows(text)
    vim.fn.setreg("*", text)
end

local function yank_unix(text)
    local escape = vim.fn.system("yank", text)

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln(escape)
    else
        -- vim.fn.chan({escape}, "/dev/tty", "b")
        vim.fn.chansend(vim.v.stderr, escape)
    end
end

PE.yank = vim.fn.has("win32") == 1 and yank_windows or yank_unix

function PE.CurrentFile()
    print(vim.api.nvim_buf_get_name(0))
    PE.yank(vim.api.nvim_buf_get_name(0))
end
vim.cmd('command! PFile lua PE.CurrentFile()')

-- Create a mapping
vim.api.nvim_set_keymap('', '<Leader>y', 'y:<C-U>lua PE.yank(vim.fn.getreg("@0"))<CR>',
    { noremap = false, silent = true, desc = "yank to 'yank'" })
-- vim.keymap.set("v", "<leader>y",'"+y', { noremap = true, desc = "Copy to clipboard(Reg\")" })
vim.keymap.set("x", "<space>",'y:<C-U>lua PE.yank(vim.fn.getreg("@0"))<CR>', { silent = true, noremap = true, desc = "yank to 'yank'" })


function PE.ToggleQuickfix()
    local wininfos = vim.fn.getwininfo()
    local has_quickfix = vim.tbl_contains(
        vim.tbl_map(function(wininfo) return wininfo.quickfix end, wininfos),
        1
    )

    if not has_quickfix then
        vim.cmd('botright copen')
    else
        vim.cmd('cclose')
    end
end
vim.keymap.set('n', '<leader>cc', PE.ToggleQuickfix, { desc = 'Toggle quickfix window' })
vim.keymap.set('n', '<m-s-t>', PE.ToggleQuickfix, { desc = 'Toggle quickfix window' })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.keymap.set(
            "n", "<C-o>",
            function()
                local items, idx = unpack(vim.fn.getjumplist())

                if idx == 0 then
                    vim.notify("No previous jump position", vim.log.levels.WARN)
                    return
                end

                local prev_item = items[idx]

                if prev_item.bufnr ~= vim.api.nvim_get_current_buf() then
                    vim.notify("Jump blocked: Target is outside Quickfix", vim.log.levels.INFO)
                    return
                end

                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>", true, false, true), "n", false)
            end,
            { buffer = true, silent = true, desc = "Jump back only within Quickfix" }
        )
    end,
})

-- 7.1 Vim Function Zone(I just tired)
-- ===========================================
vim.cmd [[
    function! s:DiffWithSaved()
        let filetype=&ft
        diffthis
        vnew | r # | normal! 1Gdd
        diffthis
        exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
    endfunction
    com! DiffSaved call s:DiffWithSaved()
]]

vim.cmd [[ command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | new | pu | 1,2d_ | let @@ = s:reg ]]

-- workaround that if we <leader>rce type too fast
-- vim: ft=lua
