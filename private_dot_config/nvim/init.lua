
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
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
local LazyUtil = require("lazy.core.util")

vim.keymap.set('i', 'jj', '<C-[>')


-- 3. Gernal Setting
-- ===========================================




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
    vim.o.diffopt = "internal,algorithm:patience"
-- -------------------------------------------
-- 3.3 Search Zone
-- -------------------------------------------
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
-- -------------------------------------------
-- 3.5 Windows Setting
-- -------------------------------------------
    vim.o.completeopt = 'menu,menuone,noselect,noinsert' -- Better Complete
    vim.o.number      = true -- Print line number
    vim.o.splitright  = true -- Put new windows right of current

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



-- 5. LazyNvim Auto Install
-- ===========================================
require("lazy").setup({
-- -------------------------------------------
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
        defaults = {
            ["g"] = { name = "+goto" },
            ["]"] = { name = "+next" },
            ["["] = { name = "+prev" },
            ["<leader>n"] = { name = "+Line Nuber" } -- @Line-Number
        }
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.register(opts.defaults)

    end,
},

{ 'projekt0n/github-nvim-theme' },
{ 'catppuccin/nvim' },
{
    'uloco/bluloco.nvim',
    lazy = false,
    priority = 1000,
    dependencies = { 'rktjmp/lush.nvim' },
    config = function()
        -- your optional config goes here, see below.
        require("bluloco").setup({
            style = "auto",               -- "auto" | "dark" | "light"
            transparent = false,
            italics = false,
            terminal = vim.fn.has("gui_running") == 1, -- bluoco colors are enabled in gui terminals per default.
            guicursor   = true,
        })

        vim.opt.termguicolors = true
        vim.cmd('colorscheme bluloco')

    end,
},
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
    config = function(_,opts)
        require('onedark').setup {
            style = 'deep',
            colors = {
                pe_gray = "#7c8dab",    -- define a new color
                pe_blue = "#499cff",    -- define a new color
            },
            highlights = {
                Comment = {fg = '$pe_gray'},
                ['@comment'] = {fg = '$pe_gray'},
                ['@lsp.type.comment'] = {fg = '$pe_gray'},
            },

            code_style = {
                comments = 'none',
                keywords = 'none',
                functions = 'none',
                strings = 'none',
                variables = 'none'
            },
        }
        require('onedark').load()
    end,
},
-- -------------------------------------------
-- 5.1 Style Plugin
-- -------------------------------------------
{
    -- active indent guide and indent text objects
    -- indent animation
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    enabled = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function(_,opts)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify" },
            callback = function()
                vim.b.miniindentscope_disable = true
            end,
        })
        require('mini.indentscope').setup({
            -- draw = { animation = require('mini.indentscope').gen_animation.none() },
            options = { try_as_border = true },
            symbol = "│",

        })
        vim.cmd [[highlight MiniIndentscopeSymbol guifg=#419cff gui=nocombine]]
    end
},
{
    "lukas-reineke/indent-blankline.nvim",
    -- The indent that always exist one
    enabled = true,
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
    config = function(_,opts)
        --
        -- use Inspect/InspectTree to check highlight
        -- See: help hl-IblIndent
        -- Default: takes the values from |hl-Whitespace| when not defined ~
        -- So this set must be set before setup()
        vim.cmd [[highlight IblIndent guifg=#455574 gui=nocombine]]
        require("ibl").setup({

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

        })

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
    'yamatsum/nvim-cursorline',
    config = function ()
        require('nvim-cursorline').setup {
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
    end
},
{
    'nvim-lualine/lualine.nvim',
    enabled = true,
    dependencies = {
        -- 'nvim-tree/nvim-web-devicons',
        -- opt = true
    },
    config = function(_,opts)
        require('lualine').setup({
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
        })
    end
},
{
    'akinsho/toggleterm.nvim',
    opts = {
        open_mapping = [[<M-S-i>]],
        -- direction = 'float',
        -- float_opts = {
        --     border = 'curved',
        -- }
    }
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
{
    'numToStr/Comment.nvim',
    event = "VeryLazy",
    config = function(_,opts)
        require('Comment').setup()
    end

},
{
    'kylechui/nvim-surround',
    event = "VeryLazy",
    config = function(_,opts)
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
},
{
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    enabled = true,
    event = "VeryLazy",
    config = function(_,opts)
        local hop = require('hop')
        hop.setup()
        -- you can configure Hop the way you like here; see :h hop-config
        -- hop.setup({
        --     create_hl_autocmd = false,
        -- })
        vim.keymap.set('', '<space>', function()
            hop.hint_char1()
        end, {remap=true, desc='Hop to char'})

        vim.keymap.set('', '<leader>hp', function()
            hop.hint_patterns()
        end, {remap=true, desc='Hop Pattern'})
        -- vim.api.nvim_command('highlight default link HopPreview HopNextKey' )
    end
},
{
    'folke/flash.nvim',
    event = "VeryLazy",
    enabled = false,
    opts = {},

    keys = {
        { "<space>", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
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
-- 5.3 Leagcy Plugin
-- -------------------------------------------
{
    'yianwillis/vimcdoc'
},
{
    'thinca/vim-quickrun',
    keys = {
        { "<leader>rr", mode = { "n"}, '<cmd>QuickRun<CR>', desc = "QuickRun" },
    },
},
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
    'easymotion/vim-easymotion',
    event = 'VeryLazy',
    enabled = true,
    init = function()
        vim.g.EasyMotion_smartcase        = 1
        vim.g.EasyMotion_do_mapping       = 0
        vim.g.EasyMotion_enter_jump_first = 1
        vim.g.EasyMotion_space_jump_first = 1
        vim.g.EasyMotion_use_upper        = 1
        vim.keymap.set(
            'n',
            '/','<Plug>(easymotion-sn)',
            {   desc = 'Search using easymotion',
                remap = true,
            }

        )
        -- DEPRECATE:
        -- vim.keymap.set(
        --     'n',
        --     '<leader>/','/',
        --     {   desc = 'Search using origin VIM /',
        --         remap = true,
        --     }
        --
        -- )
    end,
},
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
    config = function (_,opts)
        require('gitsigns').setup(opts)
        vim.keymap.set( 'n',  '<leader>`1', '<cmd>Gitsigns toggle_current_line_blame<cr>' ,
            { silent = true, desc = "Toggle line blame"  } )
    end
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
        indent = { enable = { 'python'  } },
        ensure_installed = {
            'json',
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
    config = function(_,opts)
        require("nvim-treesitter.configs").setup(opts)
        vim.keymap.set('n','<leader>ts','<cmd>TSBufToggle highlight<CR>', { desc = 'Toggle Treesitter Highlight' })
    end

},
{
    "nvim-treesitter/nvim-treesitter-context"
},

-- -------------------------------------------
-- 5.5 Telescope Setting
-- -------------------------------------------
{
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
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
        },
        { "<leader>tm", "<cmd>Telescope man_pages<cr>", desc = "Telescope Man Pages" },
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
            wk.register({
                ["<leader>f"] = { name = "Fuzzy Find (Telescope)" },
            })
        end
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
                { name = 'buffer' },
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'vsnip'}
            }),
            formatting = {
                format = function(entry, vim_item)
                    vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
                    return vim_item
                end
            },

        }
    end,
    config = function(_,opts)
        local cmp = require('cmp')
        cmp.setup(opts)
        -- cmp.setup.cmdline(':', {
        --     mapping = cmp.mapping.preset.cmdline(),
        --     -- view = {
        --     --     entries = {name = 'wildmenu', separator = '|' }
        --     -- },
        --     sources = cmp.config.sources({
        --         { name = 'path' }
        --     }, {
        --         { name = 'cmdline' }
        --     })
        -- })

        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),

            sources = {
                { name = 'buffer' }
            }
        })

    end

},
-- -------------------------------------------
-- 5.8 LSP Plug
-- -------------------------------------------
{

    "williamboman/mason.nvim",
    cmd = "Mason",

    config = function(_, opts)
        require("mason").setup(opts)
    end,
},
{
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
        'williamboman/mason.nvim',
    },
    opts = {
        ensure_installed = {
            -- 'pylsp',
            'lua_ls',
            -- 'gopls',
            -- 'clangd',
            -- 'ccls'

        },
        automatic_installation = true,
    },
    config = function(_,opts)
        require("mason-lspconfig").setup(opts)
    end,

},
{
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
    },
    config = function(_,opts)
        -- --------------------------------
        -- mason-lspconfig Config Zone
        -- --------------------------------
        local lspconfig = require('lspconfig')
        require("mason-lspconfig").setup_handlers({
            function (server_name)
                require("lspconfig")[server_name].setup{
                    autostart = false
                }
            end,
            -- Next, you can provide targeted overrides for specific servers.
            ["lua_ls"] = function ()
                lspconfig.lua_ls.setup({
                    autostart = true,
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                                neededFileStatus = {
                                    ['codestyle-check'] = 'None!',
                                    ["unused-local"] = 'None!',
                                    ["empty-block"] = "None!",
                                }
                            }
                        }
                    }
                })

            end,
            ["pylsp"] = function ()
                lspconfig.pylsp.setup({
                    autostart = true,
                    settings = {
                        -- @See:
                        -- https://neovim.discourse.group/t/pylsp-config-is-not-taken-into-account/1846
                        -- Like I mentioned on your issue,
                        -- you need to have a nested pylsp table under settings
                        -- (according to their documentation)
                        pylsp = {
                            plugins = {
                                pycodestyle = {
                                    enabled = true,
                                    ignore = {
                                        -- 'W391',
                                        'E111', -- E111 indentation is not a multiple of 4
                                        'E114', -- E114 indentation is not a multiple of 4 (comment)
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
            end,
            -- ["java_language_server"] = function ()
            --     lspconfig.java_language_server.setup({
            --         autostart = true,
            --         cmd = { "java-language-server" },
            --     })
            -- end,
            ["clangd"] = function () lspconfig.clangd.setup({ autostart = true }) end,
            ["gopls"] = function () lspconfig.gopls.setup({ autostart = true }) end,
            -- ["jdtls"] = function () end, -- Leave it to nvim-jdtls
            ["jdtls"] = function ()
                local mason_root = require('mason.settings').current.install_root_dir
                lspconfig.jdtls.setup({
                    autostart = true,
                    init_options = {
                        bundles = {
                            vim.fn.glob(mason_root .. 'packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'),
                        }
                    }
                })
            end,

        })


        -- --------------------------------
        -- lspconfig Config Zone
        -- --------------------------------
        -- vim.diagnostic.disable()
        -- require'lspconfig'.ccls.setup{
        --     -- filetypes = { "c", "cpp", "objc", "objcpp", "asm" },
        -- }
        -- vim.api.nvim_create_autocmd('LspAttach', {
        --     group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        --     callback = function(ev)
        --         -- Enable completion triggered by <c-x><c-o>
        --         -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        --
        --         -- Buffer local mappings.
        --         -- See `:help vim.lsp.*` for documentation on any of the below functions
        --         local local_opt = { buffer = ev.buf }
        --         vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, local_opt)
        --         vim.keymap.set('n', 'gd', vim.lsp.buf.definition, local_opt)
        --         vim.keymap.set('n', 'K', vim.lsp.buf.hover, local_opt)
        --         vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, local_opt)
        --         vim.keymap.set({ 'n', 'v' }, 'gla', vim.lsp.buf.code_action, local_opt)
        --         vim.keymap.set('n', 'gr', vim.lsp.buf.references, local_opt)
        --     end,
        -- })

    end,

},
-- { 'bfredl/nvim-luadev' },
-- {
--     'mfussenegger/nvim-jdtls',
--     dependencies = {
--         'mfussenegger/nvim-dap',
--         'williamboman/mason.nvim',
--         "neovim/nvim-lspconfig",
--         -- 'williamboman/mason-lspconfig.nvim',
--     },
--     opts = {
--         root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw', '.root'}, { upward = true })[1]),
--     },
--     config = function (_, opts)
--         require('jdtls').start_or_attach(opts)
--     end
-- },
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
            javadbg = function (config)
                -- local mason_root = require('mason.settings').current.install_root_dir
                -- local bundles = {
                --     vim.fn.glob(
                --         mason_root .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
                --         1
                --     ),
                -- }
                --
                -- config.adapters = {
                --     {
                --         type = "java",
                --         request = "attach",
                --         name = "Debug (Attach) - Remote",
                --         hostName = "127.0.0.1",
                --         port = 5005,
                --     },
                -- }
                require('mason-nvim-dap').default_setup(config)
            end
        }
    },
    config = function(_,opts)
        require("mason-nvim-dap").setup(opts)
    end,

},
-- -------------------------------------------
-- 5.9 DAP & LSP UI
-- -------------------------------------------
{
    "rcarriga/nvim-dap-ui",
    event = 'VeryLazy',
    cmd = { 'DapUiToggle' },
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio"
    },
    config = function ()
        require("dapui").setup()
        vim.api.nvim_create_user_command('DapUiToggle', function() require('dapui').toggle() end, { nargs = 0 })
    end,
},
-- {
--     "jay-babu/mason-nvim-dap.nvim",
--     dependencies = {
--         "mfussenegger/nvim-dap",
--         'williamboman/mason.nvim',
--     },
--     opts = {
--         ensure_installed = {
--             "delev",
--             -- 'ccls'
--         },
--         handlers = {},
--     },
--     config = function (_,opts)
--         require("mason-nvim-dap").setup(opts)
--     end
-- },
-- {
--     "mfussenegger/nvim-dap",
--     dependencies = {
--         'williamboman/mason.nvim',
--     },
-- },
-- {
--     "leoluz/nvim-dap-go",
--     config = function ()
--         require('dap-go').setup()
--     end
-- },
-- {
--     "rcarriga/nvim-dap-ui",
--     dependencies = {"mfussenegger/nvim-dap"},
--     config = function ()
--         require("dapui").setup()
--     end,
-- },
{

    'nvimdev/lspsaga.nvim',
    -- Note: this also have barbecue.nvim feature something like
    -- nvim › init.lua › 󰅨 require("lazy").setup ›  [25]
    enabled = true,
    event = "VeryLazy",
    config = function()
        require('lspsaga').setup({
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

        })
        -- local map = vim.api.nvim_buf_set_keymap
        -- map(0, "n", "<F2>", "<cmd>Lspsaga rename<cr>", {silent = true, noremap = true})
        -- map(0, "n", "gk", "<cmd>Lspsaga code_action<cr>", {silent = true, noremap = true})
        -- map(0, "x", "gk", ":<c-u>Lspsaga range_code_action<cr>", {silent = true, noremap = true})
        -- map(0, "n", "gd", "<cmd>Lspsaga  peek_definition<cr>", {silent = true,noremap = true})
        -- map(0, "n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", {silent = true, noremap = true})
        -- map(0, "n", "K",  "<cmd>Lspsaga hover_doc<cr>", {silent = true, noremap = true})
        --
        local map = vim.keymap.set
        map( "n", "<F2>", "<cmd>Lspsaga rename<cr>", {silent = true, noremap = true})
        map( "n", "gk", "<cmd>Lspsaga code_action<cr>", {silent = true, noremap = true})
        map( "x", "gk", ":<c-u>Lspsaga range_code_action<cr>", {silent = true, noremap = true})
        map( "n", "gd", "<cmd>Lspsaga  peek_definition<cr>", {silent = true,noremap = true})
        map( "n", "go", "<cmd>Lspsaga show_line_diagnostics<cr>", {silent = true, noremap = true})
        map( "n", "Q", "<cmd>Lspsaga finder tyd+ref+imp+def<cr>", {silent = true, noremap = true})
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        -- 'nvim-tree/nvim-web-devicons'     -- optional
    },
},
{
    'liuchengxu/vista.vim',
    config = function ()
        vim.g.vista_echo_cursor_strategy = 'scroll'
        vim.cmd [[ let g:vista#renderer#enable_icon = 0 ]]
    end,
    keys = {
        { "<leader>av", "<cmd>Vista!!<cr>", desc = "Open Vista bar" },
    }
},
-- {
--     'roobert/search-replace.nvim',
-- },

-- -------------------------------------------
},{ -- Lazy.nvim Options
-- -------------------------------------------
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
--
--

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
    vim.keymap.set( 'n',  '<M-S-C>', ':vsplit<cr>' )
    vim.keymap.set( 'n',  '<M-S-X>', ':confirm q<cr>' )

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

    -- Jump Section
    vim.keymap.set(
        "n", "gp",
        '`[' .. 'v' .. '`]',
        { desc = "Go to Previous Paste", noremap = true }
    )

    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to Next diagnostic' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to Pervious diagnostic' })

-- -------------------------------------------
-- 6.2 Leader Keymap
-- -------------------------------------------
    vim.keymap.set('n', '<leader>rce' , '<cmd>tabe $MYVIMRC<CR>' , { desc = 'Edit MYVIMRC' } )
    vim.keymap.set('n', '<leader>``' , '<cmd>nohlsearch<CR>' , { desc = 'Close Highlight' } )

    vim.keymap.set("n", "<leader>wp",
        function() PE.ToggleOpts("wrap") end,
        { desc = "Toggle Word Wrap" })


    -- Also see @Line-Number
    wk.register({
        ["<leader>n"] = { name = "+LineNumber Options" }
    })
    vim.keymap.set("n", "<leader>nu",
        function() PE.ToggleOpts("number") end,
        { desc = "Toggle Line Numbers" })
    vim.keymap.set("n", "<leader>nr",
        function() PE.ToggleOpts("relativenumber") end,
        { desc = "Toggle Relative Numbers" })

    -- vim.keymap.set('v','tt','<cmd>s/\\s\\+$//e<cr>',{ desc = 'Clean tail spaces'})
    vim.cmd [[ vnoremap tt :s/\s\+$//e<CR> ]]

    wk.register({
        ["<leader>t"] = { name = "+Tabe Options" }
    })
    vim.keymap.set("n", "<leader>tb", '<cmd>tab ball<cr>',
        { desc = "Tab Ball buffers" })

    -- vim.keymap.set("n", "<leader>o/",'/', { noremap = true, desc = "Origin VIM /" })
    vim.keymap.set("v", "<leader>y",'"+y', { noremap = true, desc = "Copy to clipboard(Reg\")" })
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
        for i = 1, level do
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


function PE.MouseSet(arg)
    vim.o.mouse = arg
end

vim.cmd [[ command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | new | pu | 1,2d_ | let @@ = s:reg ]] 
