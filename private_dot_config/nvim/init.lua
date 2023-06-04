-- +++++++++++++++++++++++++++++++++++++++++++
-- File: init.lua
-- Author: PEMessage
-- Description: This is my VIM8+/NeoVIM configuration
-- Last Modified:  2023-05-29 Mon 03:01 PM
-- +++++++++++++++++++++++++++++++++++++++++++

-- 1. Global Options
-- ===========================================
    PE = {}  -- Global Options Var
    

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
    vim.o.nocompatible = true     -- 禁用 vi 兼容模式
    vim.o.helplang     = "cn"      -- 设置中文帮助手册
    vim.o.wrap         = false          -- 关闭自动换行
    vim.o.ruler        = true            -- 显示光标位置
    vim.o.ffs          = 'unix,dos,mac' -- 文件换行符，默认使用 unix 换行符
    vim.o.mouse        = 'a'
-- -------------------------------------------
-- 3.3 Search Zone
-- -------------------------------------------
    vim.o.smartcase = true   -- 智能搜索大小写判断，默认忽略大小写，除非搜索内容包含大写字母
    vim.o.incsearch = true   -- 查找输入时动态增量显示查找结果
    vim.o.hlsearch  = true   -- 高亮搜索内容

-- -------------------------------------------
-- 3.4 Tab and Indent Setting
-- -------------------------------------------
    vim.o.tabstop     = 5                          -- Tab 长度，默认为8
    vim.o.smarttab    = true                       -- 根据文件中其他地方的缩进空格个数来确定一个tab是多少个空格
    vim.o.expandtab   = true                       -- 展开Tab

    vim.o.shiftwidth  = 4                          -- 缩进长度，设置为4
    vim.o.autoindent  = true                       -- 自动缩进
    vim.o.smartindent = true                       -- Insert indents automatically

    vim.o.backspace   = 'eol,start,indent'         -- 类似所有编辑器的删除键
-- -------------------------------------------
-- 3.5 Windows Setting
-- -------------------------------------------
    vim.o.completeopt = 'menu,menuone,noselect' -- Better Complete
    vim.o.number      = true -- Print line number
    vim.o.splitright  = true -- Put new windows right of current

    vim.api.nvim_create_autocmd( { 'FileType' },{
        pattern       = { 'help','man' },
        command       = 'wincmd L'
    })
-- -------------------------------------------
-- 3.6 Stateline Setting
-- -------------------------------------------
    vim.o.laststatus  = 2  -- 总是显示状态栏
    vim.o.showtabline = 2  -- 总是显示标签栏
    vim.o.splitright = true      -- 水平切割窗口时，默认在右边显示新窗口



-- 5. LazyNvim Auto Install
-- ===========================================
require("lazy").setup({ --Start Quote
-- -------------------------------------------

-- -------------------------------------------
-- 5.1 Style Plugin
-- -------------------------------------------
--{
--    'olimorris/onedarkpro.nvim',
--    lazy = false,
--    priority = 1000,
--    config = function(_,opts)
--        require("onedarkpro").setup()
--       -- vim.cmd("colorscheme onedark")
--    end,
--},
{
    'navarasu/onedark.nvim',
    config = function(_,opts)
        require('onedark').setup {
            style = 'deep',
            colors = {
                new_gray = "#7c8dab",    -- define a new color
            },
            highlights = {
                 Comment = {fg = '$new_gray'},
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

{
    'mhinz/vim-startify',
    event = 'VimEnter',
    config = function()
        local pokemon = require('pokemon')
        pokemon.setup({
            number = 'random',
            size = 'auto',
        })
        vim.g.startify_custom_header = pokemon.header()
    end,
    dependencies = { { 'ColaMint/pokemon.nvim' } }
},

{
    "folke/which-key.nvim",
    event = "VeryLazy",
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
{
    'nvim-lualine/lualine.nvim',
    dependencies = { 
        'nvim-tree/nvim-web-devicons', 
        opt = true
    },
    config = function(_,opts) 
        require('lualine').setup({
            options = {
                theme = 'auto',
                icons_enabled = false,
                component_separators = { left = '|', right = '|' },
                section_separators = { left = '', right = '' },
            },
        })
    end
},
{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = { 
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    },
    keys = {
        {
            "<M-b>",
            function()
                require("neo-tree.command").execute({
                    toggle = true, dir = vim.loop.cwd()
                })
            end,
            desc = "Explorer NeoTree (cwd)",
        },
        {
            "<leader>b",
            function()
                require("neo-tree.command").execute({
                    toggle = true, dir = vim.loop.cwd()
                })
            end,
            desc = "Explorer NeoTree (cwd)",
        },
    },
    opts = {
        window = {
            mappings = {
                ["<space>"] = 'none',
            },
        },
        git_status = {
            window = {
                position = "float",
                mappings = {
                    ["A"]  = "git_add_all",
                    ["gu"] = "git_unstage_file",
                    ["ga"] = "git_add_file",
                    ["gr"] = "git_revert_file",
                    ["gc"] = "git_commit",
                    ["gp"] = "git_push",
                    ["gg"] = "git_commit_and_push",
                }
            }
        }

    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,

    config = function(_,opts)
        vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
        require("neo-tree").setup(opts)
    end,
},
-- -------------------------------------------
-- 5.2 Mini.nvim Plugin
-- -------------------------------------------
{ 
    'echasnovski/mini.pairs',
    event = "VeryLazy",
    version = false,
    config = function(_,opts)
        require('mini.pairs').setup()
    end,
},



{
    -- active indent guide and indent text objects
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
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
    event = { "BufReadPost", "BufNewFile" },

    config = function(_,opts)
        require("indent_blankline").setup({
            char = '┆',
            filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
        })
        vim.cmd [[highlight IndentBlanklineChar guifg=#455574 gui=nocombine]]
    end
},

-- -------------------------------------------
-- 5.3 Telescope Setting
-- -------------------------------------------
{
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    dependencies = { 'nvim-lua/plenary.nvim' },

    -- ------ --
    -- Keymap --
    -- ------ --
    keys = {
        { "<leader><leader>", "<cmd>Telescope <cr>", desc = "Telescope All" },
        { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search " },

        { "<leader>fok", "<cmd>Telescope keymaps<cr>", desc = "(O)ption (K)ey Maps" },
        { "<leader>foc", "<cmd>Telescope help_tags<cr>", desc = "(O)ption (C)olor Highlight" },
        { "<leader>fot", "<cmd>Telescope colorscheme<cr>", desc = "(O)ption (T)heme"},

        { "<leader>fb", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "(B)uffer" },
        { "<leader>fm", "<cmd>Telescope man_pages<cr>", desc = "(M)an Pages" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "(H)elp Pages" },

        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "MRU" },

    },
    -- ------ -- 
    -- Option -- 
    -- ------ -- 
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
                    ["<Down>"] = function(...)
                        return require("telescope.actions").cycle_history_next(...)
                    end,
                    ["<Up>"] = function(...)
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
    },
    init = function()
        local wk = require('which-key')
        wk.register({
		["<leader>f"] = { name = "Fuzzy Find (Telescope)" }
	})
    end
},

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
-- {
--     "ggandor/leap.nvim",
--     keys = {
--         { "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
--         { "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
--         { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
--     },
--     config = function(_, opts)
--         local leap = require("leap")
--         for k, v in pairs(opts) do
--             leap.opts[k] = v
--         end
--         leap.add_default_mappings(true)
--         vim.keymap.del({ "x", "o" }, "x")
--         vim.keymap.del({ "x", "o" }, "X")
--     end,
-- },
{
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
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
    end
},




-- -------------------------------------------
-- 5.3 Leagcy Plugin
-- -------------------------------------------
{
    "mg979/vim-visual-multi",
    event = 'VeryLazy',
    init  = function()
    vim.g.M_default_mappings = 0
    vim.g.VM_mouse_mappings  = 1
        vim.g.VM_maps = {
            ['Find Under']          = '<C-d>',	
            ['Find Subword Under']  = '<C-d>',
            -- Arrow Key
            ["Add Cursor Up"]       = '<M-C-Up>',
            ["Add Cursor Down"]     = '<M-C-Down>',
            -- Mouse
            ["Mouse Cursor"]        = '<C-LeftMouse>',
            -- Multi-Mode
            ["Align"]               = '<C-A>',
            ["Enlarge"]             = "+",
            ["Shrink"]             = "-",
        }
    end,
},
{
    'easymotion/vim-easymotion',
    event = 'VeryLazy',
    init = function()
        vim.g.EasyMotion_smartcase = 1
        vim.g.EasyMotion_do_mapping = 0
        vim.g.EasyMotion_enter_jump_first = 1
        vim.g.EasyMotion_space_jump_first = 1
        vim.g.EasyMotion_use_upper = 1
        vim.keymap.set(
        'n',
        '/','<Plug>(easymotion-sn)',
        { remap = true }

        )
    end,
},
{ 'junegunn/vim-easy-align' },
{ "tpope/vim-repeat", event = "VeryLazy" },

 
-- -------------------------------------------
}) --End Lazy.nvim Quote
-- ===========================================

 

-- 6. KeyMap Zone
-- ===========================================

-- -------------------------------------------
-- 6.1 Basic I / N Mode
-- -------------------------------------------

    
    -- better up/down
    vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

    -- Move to window using the <meta>+<shift>+hjkl keys
    vim.keymap.set("n", "<M-S-H>", "<C-W>h", { desc = "Go to left window", remap = true })
    vim.keymap.set("n", "<M-S-J>", "<C-W>j", { desc = "Go to lower window", remap = true })
    vim.keymap.set("n", "<M-S-K>", "<C-W>k", { desc = "Go to upper window", remap = true })
    vim.keymap.set("n", "<M-S-L>", "<C-W>l", { desc = "Go to right window", remap = true })

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

    -- gp: Visual last paste
    -- vim.keymap.set("n", "gp",
    --  '`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]',
    -- { desc = "Go to Previous Paste", noremap = true })
    vim.keymap.set("n", "gp",
     '`[' .. 'v' .. '`]',
    { desc = "Go to Previous Paste", noremap = true })

-- -------------------------------------------
-- 6.2 Leader Keymap
-- -------------------------------------------
    vim.keymap.set('n', '<leader>``' , '<cmd>nohlsearch<CR>' , { desc = ' Close Highlight ' } )

    vim.keymap.set("n", "<leader>wp",
        function() PE.ToggleOpts("wrap") end,
        { desc = "Toggle Word Wrap" })

       
    -- Also see @Line-Number
    vim.keymap.set("n", "<leader>nu",
        function() PE.ToggleOpts("number") end,
        { desc = "Toggle Line Numbers" })
    vim.keymap.set("n", "<leader>nr",
        function() PE.ToggleOpts("number") end,
        { desc = "Toggle Relative Numbers" })

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


-- local pehop = require('pehop')
-- local hopp = require('hop-search')
-- pehop.setup()
-- vim.keymap.set('', '<leader>tt', function()
--     pehop.hint_pe()
-- end, {remap=true, desc='Hop to char'})
--
-- vim.keymap.set('', '<leader>tr', function()
--     hopp.echo()
-- end, {remap=true, desc='Hop to char'})

-- end, {remap=true, desc='Hop to char'})


