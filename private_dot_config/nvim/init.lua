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

vim.keymap.set('i', 'jj', '<C-[>')


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
    -- -------------------------------------------
    -- 3.5 Windows Setting
    -- -------------------------------------------
    vim.o.completeopt = 'menu,menuone,noselect,noinsert' -- Better Complete
    vim.o.number      = true -- Print line number
    vim.o.splitright  = true -- Put new windows right of current
    vim.o.pumheight = 10

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
            delay = 2000,
            plugins = {
                spelling = {
                    enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                    suggestions = 5, -- how many suggestions should be shown in the list?
                },
            },
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        config = function(_, opts)
            local wk = require("which-key")
            local defaults = {
                { "<leader>n", group = "Line Nuber" },
                { "[", group = "prev" },
                { "]", group = "next" },
                { "g", group = "goto" },

            }
            wk.setup(opts)
            wk.add(defaults)
        end,
    },

    { 'projekt0n/github-nvim-theme' },
    { 'catppuccin/nvim' },
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
    {
        "Alexis12119/nightly.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "nightly"
        end,
    },

    {
        'navarasu/onedark.nvim',
        lazy = false,
        priority = 900,
        opts = {
            style = 'deep',
            colors = {
                pe_gray = "#7c8dab",    -- define a new color
                pe_blue = "#499cff",    -- define a new color
                bg0 = "#1f2329",
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
    -- -------------------------------------------
    -- 5.1 Style Plugin
    -- -------------------------------------------
    {
        -- active indent guide and indent text objects
        -- indent animation
        "nvim-mini/mini.indentscope",
        version = false, -- wait till new 0.7.0 release to put it back on semver
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
        --     vim.cmd [[highlight IndentBlanklineChar guifg=#455574 gui=nocombine]]
        -- end
        --
        -- Version 3
        opts = function(_, _)
            -- use Inspect/InspectTree to check highlight
            -- See: help hl-IblIndent
            -- Default: takes the values from |hl-Whitespace| when not defined ~
            -- So this set must be set before setup()
            vim.cmd [[highlight IblIndent guifg=#455574 gui=nocombine]]
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
    {
        'yamatsum/nvim-cursorline',
        opts = {
            cursorline = {
                enable = true,
                timeout = 1000,
                number = false,
            },
            cursorword = {
                enable = true,
                min_length = 3,
                hl = { underline = true },
            }
        }
    },
    {
        'nvim-lualine/lualine.nvim',
        enabled = true,
        dependencies = {
            -- 'nvim-tree/nvim-web-devicons',
            -- opt = true
        },
        opts = {
            options = {
                theme = 'auto',
                icons_enabled = false,
                component_separators = { left = '|', right = '|' },
                section_separators = { left = '', right = '' },
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename','searchcount'},
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
        }
    },
    {
        'akinsho/toggleterm.nvim',
        opts = {
            open_mapping = [[<M-S-u>]],
            direction = 'float',
            float_opts = {
                -- border = 'curved',
            }
        }
    },
    {
        'fei6409/log-highlight.nvim',
        ft = 'log',
        opts = {}
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
        "Zeioth/compiler.nvim",
        dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
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
        commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
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
        'kylechui/nvim-surround',
        event = "VeryLazy",
        opts = {},
    },
    {
        'phaazon/hop.nvim',
        branch = 'v2', -- optional but strongly recommended
        enabled = true,
        event = "VeryLazy",
        opts = {},
        keys = {
            { '<space>', "<cmd>lua require('hop').hint_char1()<CR>", mode = 'n', desc = 'Hop to char', remap = true },
            { '<leader>hp', "<cmd>lua require('hop').hint_patterns()<CR>", desc = 'Hop Pattern', remap = true },
        },
    },
    {
        'folke/flash.nvim',
        event = "VeryLazy",
        enabled = false,
        opts = {},
        keys = {
            { "<space>", mode = { "n", "x", "o" }, "<cmd>lua require('flash').jump()<CR>" , desc = "Flash" },
            -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
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
        'yianwillis/vimcdoc'
    },
    {
        'tpope/vim-sleuth',
        cmd = {'Sleuth'},
        lazy = true,
        init = function()
            vim.cmd [[ command UnSleuth setlocal et sw=4 ts=4 ]]
        end,
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
        'PEMessage/vim-text-process',
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
    { 'junegunn/vim-easy-align', event = 'VeryLazy' },
    { 'tpope/vim-repeat', event = 'VeryLazy' },

    {
        'lewis6991/gitsigns.nvim',
        opts = {
            -- current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
                delay = 800,
                ignore_whitespace = false,
                virt_text_priority = 100,
            },

        },
        keys = {
            {
                '<leader>`1', '<cmd>Gitsigns toggle_current_line_blame<cr>', mode = 'n',
                desc = 'Toggle line blame', silent = true
            },
            {
                '[c', '<cmd>Gitsigns prev_hunk<cr>', mode = 'n',
                desc = 'Previous git changed line', silent = true
            },
            {
                ']c', '<cmd>Gitsigns next_hunk<cr>', mode = 'n',
                desc = 'Next git changed line', silent = true
            },
            {
                '<leader>u', '<cmd>Gitsigns reset_hunk<cr>', mode = 'n',
                desc = 'Reset git hunk', silent = true
            },
        },
    },
    {
        "julienvincent/hunk.nvim",
        dependencies = { 'MunifTanjim/nui.nvim' },
        cmd = { "DiffEditor" },
    },
    {
        "christoomey/vim-tmux-navigator",
        -- Do not use very lazy prevent not init
        -- event = 'VeryLazy',
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
            vim.keymap.set( {'n','i','v','t'},  '<M-S-h>', '<cmd>TmuxNavigateLeft<cr>' , { silent = true, desc = "Navigate Left"  } )
            vim.keymap.set( {'n','i','v','t'},  '<M-S-j>', '<cmd>TmuxNavigateDown<cr>' , { silent = true, desc = "Navigate Down"  } )
            vim.keymap.set( {'n','i','v','t'},  '<M-S-k>', '<cmd>TmuxNavigateUp<cr>'   , { silent = true, desc = "Navigate Up"    } )
            vim.keymap.set( {'n','i','v','t'},  '<M-S-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true, desc = "Navigate Right" } )


            -- vim.keymap.set( 'n',  '<leader>`pon', ':set mouse=a<CR>', { silent = true, desc = "Mouse on" } )
            -- vim.keymap.set( 'n',  '<leader>`pof', ':set mouse=<CR>', { silent = true, desc = "Mouse off" } )

            -- 注册命令
            vim.cmd([[
                command! -nargs=0 PEMouseON lua PE.MouseSet("a")
                command! -nargs=0 PEMouseOFF lua PE.MouseSet("")
                ]])

        end
    },
    -- -------------------------------------------
    -- 5.4 Treesitter (HEAVY Zone after)
    -- -------------------------------------------
    {
        "nvim-treesitter/nvim-treesitter",
        -- version = false, -- last release is way too old and doesn't work on Windows
        -- enabled = false,
        -- dependencies = {
        --     'hiphish/rainbow-delimiters.nvim',
        -- },
        enabled = true,
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        main = 'nvim-treesitter.configs',
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
                'css',
                'vim',
                'lua',
                'c',
                'cpp',
                'make',
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
        keys = {
            { '<leader>ts', '<cmd>TSBufToggle highlight<CR>', mode = 'n', desc = 'Toggle Treesitter Highlight' },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            enable = false,
            max_lines = 3
        }
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
            vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
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
        'nvim-telescope/telescope-fzf-native.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        event = 'VimEnter',
        build = 'make',
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
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            telescope.load_extension("fzf")
        end
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
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        enabled = true,
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope",
        -- See : help LazyKeysSpec
        keys = {
            {
                "<C-p>",
                function()
                    require('telescope.builtin').buffers(
                        require('telescope.themes').get_dropdown{
                            -- previewer = false,
                            sort_lastused = true,
                            path_display = {
                                shorten = { len = 2, exclude = {1, 2, -3, -2, -1} }
                            },
                            layout_config = {
                                width = 0.8,
                            },
                            attach_mappings = function (_,map)
                                map( {'i','n'}, '<C-p>',
                                    function(...)
                                        return require("telescope.actions").close(...)
                                    end
                                )
                                return true
                            end,
                        }
                    )
                end,
                desc = "Buffers"
            },{
                "<C-r>",
                function()
                    require('telescope.builtin').oldfiles(
                        require('telescope.themes').get_dropdown({
                            previewer = false,
                            attach_mappings = function (_,map)
                                map( {'i','n'}, '<C-r>',
                                    function(...)
                                        return require("telescope.actions").close(...)
                                    end
                                )
                                return true
                            end,
                        })
                    )
                end,
                desc = "MRU"
            }, {
                "<C-e>",
                function()
                    require('telescope.builtin').find_files({
                        previewer = false,
                        path_display = {
                            shorten = { len = 3, exclude = {1, 2, -3, -2, -1} }
                        }
                    })
                end,
                desc = "Telescope Find Files"
            },
            { "<leader>tm", "<cmd>Telescope man_pages<cr>", desc = "Telescope Man Pages" },
            { "<leader>td", "<cmd>Telescope lsp_definitions<cr>", desc = "Telescope LSP Define" },
            { "<leader>th", "<cmd>Telescope help_tags<cr>", desc = "Telescope Help Pages" },
            { "<leader>tf", "<cmd>Telescope find_files<cr>", desc = "Telescope Find Files" },
            { "<leader>tg", "<cmd>Telescope live_grep<cr>", desc = "Telescope Live Grep" },
            { "<leader>tt", "<cmd>Telescope<cr>", desc = "Telescope All" },
        },
        opts = {
            defaults = {

                mappings = {
                    i = {
                        ["<c-t>"] = function(...)
                            return require("trouble.providers.telescope").open_with_trouble(...)
                        end,
                        ["<a-t>"] = function(...)
                            return require("trouble.providers.telescope").open_selected_with_trouble(...)
                        end,
                        --
                        -- Scoll Down result
                        --
                        ["<C-j>"] = function(...)
                            return require("telescope.actions").move_selection_next(...)
                        end,
                        ["<C-k>"] = function(...)
                            return require("telescope.actions").move_selection_previous(...)
                        end,
                        ["<C-d>"] = function(...)
                            local action_set = require("telescope.actions.set")
                            action_set.shift_selection(..., 3)
                        end,
                        ["<C-u>"] = function(...)
                            local action_set = require("telescope.actions.set")
                            action_set.shift_selection(..., -3)
                        end,
                        ["<C-l>"] = function(...)
                            return require("telescope.actions").select_default(...)
                        end,

                        --
                        -- History like command mode
                        --
                        ["<C-Down>"] = function(...)
                            return require("telescope.actions").cycle_history_next(...)
                        end,
                        ["<C-Up>"] = function(...)
                            return require("telescope.actions").cycle_history_prev(...)
                        end,
                        ["<C-f>"] = function(...)
                            return require("telescope.actions").preview_scrolling_down(...)
                        end,
                        ["<C-b>"] = function(...)
                            return require("telescope.actions").preview_scrolling_up(...)
                        end,
                    },
                    n = {
                        ["<C-j>"] = function(...)
                            return require("telescope.actions").move_selection_next(...)
                        end,
                        ["<C-k>"] = function(...)
                            return require("telescope.actions").move_selection_previous(...)
                        end,
                        ["<C-d>"] = function(...)
                            local action_set = require("telescope.actions.set")
                            action_set.shift_selection(..., 3)
                        end,
                        ["<C-u>"] = function(...)
                            local action_set = require("telescope.actions.set")
                            action_set.shift_selection(..., -3)
                        end,
                        ["q"] = function(...)
                            return require("telescope.actions").close(...)
                        end,
                        ["<C-C>"] = function(...)
                            return require("telescope.actions").close(...)
                        end,
                        ["<ESC>"] = function(...)
                            return require("telescope.actions").close(...)
                        end,
                    },
                },
            },
            pickers = {
                colorscheme = {
                    enable_preview = true
                },
                -- buffers = {
                --     mappings = {
                --         i = {
                --             ["<C-p>"] = function(...)
                --                 return require("telescope.actions").close(...)
                --             end,
                --         },
                --     },
                -- },
            },
            init = function()
                local wk = require('which-key')
                wk.add({
                    { "<leader>n", group = "LineNumber Options" },
                })
            end,
        },
    },

    -- -------------------------------------------
    -- 5.7 nvim-cmp plug
    -- -------------------------------------------
    {
        "hrsh7th/nvim-cmp",
        version = false, -- last release is way too old
        event = "InsertEnter",
        dependencies = {
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'rafamadriz/friendly-snippets',
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip',
            -- 'saadparwaiz1/cmp_luasnip',
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

            return {
                -- view = {
                --     entries = {
                --         {name = 'native'}
                --     }
                -- },
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
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

                    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    -- ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    -- ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<C-y>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
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
                        elseif vim.fn["vsnip#available"](1) == 1 then
                            feedkey("<Plug>(vsnip-expand-or-jump)", "")
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function()
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                            feedkey("<Plug>(vsnip-jump-prev)", "")
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = 'lazydev' },
                    { name = 'buffer' },
                    { name = 'path' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'nvim_lsp' },
                    { name = 'vsnip'}
                }),
                formatting = {
                    format = function(_, vim_item)
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
                        return vim_item
                    end
                },

            }
        end,
    },
    {
        "j-hui/fidget.nvim",
        event = 'VeryLazy',
        opts = {
            -- options
        },
    },
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
                -- "github:PEMessage/mason-registry", -- custom mason registries, not used since 1.50.0 jdtls merged
                "github:mason-org/mason-registry",
            },
        },
    },
    {
        'williamboman/mason-lspconfig.nvim',
        event = 'VimEnter',
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
                "ts_ls",
                -- "kotlin_lsp", -- See: https://github.com/desugar-64/kotlin-lsp-workspace-generator for android
                -- "jdtls" -- leave it to nvim-jdtls
            }
        },
        config = function(_,opts)
            -- vim.lsp.config('lua_ls', {
            --     on_init = function(client)
            --         if client.workspace_folders then
            --             local path = client.workspace_folders[1].name
            --             ---@diagnostic disable-next-line: undefined-field
            --             if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc')) then
            --                 return
            --             end
            --         end
            --
            --         client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            --             runtime = {
            --                 -- Tell the language server which version of Lua you're using
            --                 -- (most likely LuaJIT in the case of Neovim)
            --                 version = 'LuaJIT'
            --             },
            --             -- Make the server aware of Neovim runtime files
            --             workspace = {
            --                 checkThirdParty = false,
            --                 library = {
            --                     vim.env.VIMRUNTIME
            --                     -- Depending on the usage, you might want to add additional paths here.
            --                     -- "${3rd}/luv/library"
            --                     -- "${3rd}/busted/library",
            --                 }
            --                 -- or pull in all of 'runtimepath'.
            --                 -- NOTE: this is a lot slower and will cause issues when working on your own configuration
            --                 -- (see https://github.com/neovim/nvim-lspconfig/issues/3189)
            --                 -- library = vim.api.nvim_get_runtime_file("", true)
            --             }
            --         })
            --     end,
            --     settings = {
            --         Lua = {
            --             diagnostics = {
            --                 neededFileStatus = {
            --                     ['codestyle-check'] = 'None!',
            --                     ["unused-local"] = 'None!',
            --                     ["empty-block"] = "None!",
            --                 }
            --             }
            --         }
            --     }
            -- })
            vim.lsp.config("*", {
                inlay_hints = { enabled = true },
            })
            -- Thanks to:
            -- https://github.com/derekzyl/nvim/blob/6537239beda2b54925bd7640cf384d086c7dc4ea/lua/inlay_hint.lua#L56C1-L67C7
            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                    },
                },
            })
            vim.lsp.config("kotlin_lsp", {
                inlay_hints = { enabled = true },
                root_markers = {
                    'workspace.json', -- Used to integrate your own build system
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
            require("mason-lspconfig").setup(opts)
        end,

    },
    {
        'p00f/clangd_extensions.nvim',
        event = "LspAttach",
        ft = {'c', 'cpp'},
        cmds = {
            'ClangdTypeHierarchy'
        }
    },
    {
        'mfussenegger/nvim-jdtls',
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
            if root_dir then
                root_dir = root_dir:gsub('/', '_'):gsub('\\', '_')
            end
            local executable = 'jdtls'

            if vim.fn.executable(executable) ~= 1 then
                return
            end

            vim.api.nvim_create_user_command('JdtWorkspaceDir',
                function()
                    vim.print(cache_dir .. '/workspace/' .. root_dir)
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
                    cache_dir .. '/workspace/' .. root_dir
                    -- cache_dir .. '/workspace/' .. vim.fn.fnamemodify(root_dir, ":p:h:t"),
                },
                -- See: https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#configuration-verbose
                -- See: https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Language-Server-Settings-&-Capabilities
                root_dir = require("jdtls.setup").find_root(root_markers),
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

        'nvimdev/lspsaga.nvim',
        -- Note: this also have barbecue.nvim feature something like
        -- nvim › init.lua › 󰅨 require("lazy").setup ›  [25]
        dependencies = {
            'nvim-treesitter/nvim-treesitter', -- optional
            -- 'nvim-tree/nvim-web-devicons'     -- optional
        },
        enabled = true,
        event = "LspAttach",
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
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        enabled = false,
        version = false, -- set this if you want to always pull the latest change
        opts = {
            provider = "ollama",
            vendors = {
                ollama = {
                    __inherited_from = "openai",
                    api_key_name = "",
                    -- endpoint = "http://80/v1",
                    model = "qwen2.5-coder",
                },
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },


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
                cmd = ":",
                config = "c",
                event = "e",
                ft = "ft ",
                init = "init ",
                import = "import ",
                keys = "k ",
                lazy = "lazy ",
                loaded = "i",
                not_loaded = "n",
                plugin = "p ",
                runtime = "r ",
                require = "r ",
                source = "s ",
                start = "s",
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
    vim.keymap.set("n", "]t", "<cmd>tabn<CR>", { desc = "Go to Next Tab", remap = true })
    vim.keymap.set("n", "[t", "<cmd>tabp<CR>", { desc = "Go to Previous Tab", remap = true })

    -- Move Lines
    vim.keymap.set("n", "<M-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
    vim.keymap.set("n", "<M-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
    vim.keymap.set("i", "<M-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
    vim.keymap.set("i", "<M-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
    vim.keymap.set("v", "<M-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
    vim.keymap.set("v", "<M-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

    vim.keymap.set('x', 'p', 'P', { noremap = true })
    vim.keymap.set('x', 'P', 'p', { noremap = true })

    -- Jump Section
    vim.keymap.set(
        "n", "gp",
        '`[' .. 'v' .. '`]',
        { desc = "Go to Previous Paste", noremap = true }
    )

    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Go to previous diagnostic' })
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count =  1, float = true }) end, { desc = 'Go to next diagnostic' })

    -- Lsp
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { desc = 'Go to Declaration' })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to Declaration' })
    -- Format entire document (Normal mode)
    vim.keymap.set('n', '<leader>F', vim.lsp.buf.format, { desc = 'Format entire document' })
    -- Format selected range (Visual mode)
    vim.keymap.set('v', '<leader>F', function()
        local start_row = vim.api.nvim_buf_get_mark(0, '<')[1]
        local end_row = vim.api.nvim_buf_get_mark(0, '>')[1]
        vim.lsp.buf.format({
            range = {
                ['start'] = { start_row, 0 },
                ['end'] = { end_row, 0 },
            },
        })
    end, { desc = 'Format selected range' })

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

            vim.keymap.set("n", "gd", vim.lsp.buf.definition,
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

    vim.keymap.set("n", "<leader>wp",
        function() PE.ToggleOpts("wrap") end,
        { desc = "Toggle Word Wrap" })


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
    -- Hide by default
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

function PE.CurrentFile()
    print( vim.api.nvim_buf_get_name(0))
end
vim.cmd('command! PFile lua PE.CurrentFile()')

vim.cmd('command! PCD :cd %:p:h')

function PE.yank(text)
    local escape = vim.fn.system("yank", text)

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln(escape)
    else
        -- vim.fn.chan({escape}, "/dev/tty", "b")
        vim.fn.chansend(vim.v.stderr, escape)
    end
end

-- Create a mapping
vim.api.nvim_set_keymap('', '<Leader>y', 'y:<C-U>lua PE.yank(vim.fn.getreg("@0"))<CR>',
    { noremap = false, silent = true, desc = "yank to 'yank'" })
-- vim.keymap.set("v", "<leader>y",'"+y', { noremap = true, desc = "Copy to clipboard(Reg\")" })
vim.keymap.set("x", "<space>",'y:<C-U>lua PE.yank(vim.fn.getreg("@0"))<CR>', { silent = true, noremap = true, desc = "yank to 'yank'" })


function PE.MouseSet(arg)
    vim.o.mouse = arg
end


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

vim.cmd [[
    function! VisualSelection(direction) range
        let l:saved_reg = @"
        execute "normal! gvy"

        let l:pattern = escape(@", '\\/.*$^~[]')
        let l:pattern = substitute(l:pattern, "\n$", "", "")

        if a:direction == 'b'
            execute "normal ?" . l:pattern . "\<CR>"
        elseif a:direction == 'gv'
            call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
        elseif a:direction == 'replace'
            call CmdLine("%s" . '/'. l:pattern . '/')
        elseif a:direction == 'f'
            execute "normal /" . l:pattern . "\<CR>"
        elseif a:direction == 'fa'
            let l:tmp = @/
            let l:pattern = l:tmp . "\\|" . l:pattern
            echo l:pattern
            execute "normal /" . l:pattern . "\<CR>"
        endif

        let @/ = l:pattern
        let @" = l:saved_reg
        " set hls
    endfunction

]]
vim.keymap.set('v', '&', ':<C-u>call VisualSelection(\'fa\')<CR>:set hls<CR>', { silent = true })
