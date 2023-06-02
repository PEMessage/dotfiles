-- +++++++++++++++++++++++++++++++++++++++++++
-- File: .vimrc
-- Author: PEMessage
-- Description: This is my VIM8+/NeoVIM configuration
-- Last Modified:  2023-05-29 Mon 03:01 PM
-- +++++++++++++++++++++++++++++++++++++++++++

-- 1. LazyNvim Auto Install
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

    vim.keymap.set('i', 'jj', '<C-[>')

-- 3. Gernal Setting 
-- ===========================================
-- -------------------------------------------
-- 3.1 Basic Setting Zone
-- -------------------------------------------
    vim.o.nocompatible = true     -- 禁用 vi 兼容模式
    vim.o.helplang= "cn"      -- 设置中文帮助手册
    vim.o.wrap = false          -- 关闭自动换行
    vim.o.ruler = true            -- 显示光标位置
    vim.o.ffs = 'unix,dos,mac' -- 文件换行符，默认使用 unix 换行符
-- -------------------------------------------
-- 3.3 Search Zone
-- -------------------------------------------
    vim.osmartcase = true   -- 智能搜索大小写判断，默认忽略大小写，除非搜索内容包含大写字母
    vim.oincsearch = true   -- 查找输入时动态增量显示查找结果
    vim.ohlsearch  = true   -- 高亮搜索内容

-- -------------------------------------------
-- 3.4 Tab and Indent Setting
-- -------------------------------------------
    vim.o.tabstop = 4                       -- Tab 长度，默认为8
    vim.o.smarttab = true                       -- 根据文件中其他地方的缩进空格个数来确定一个tab是多少个空格
    vim.o.expandtab = true                      -- 展开Tab

    vim.o.shiftwidth = 4                -- 缩进长度，设置为4
    vim.o.autoindent = true                      -- 自动缩进

    vim.o.backspace = 'eol,start,indent'      -- 类似所有编辑器的删除键



-- 5. LazyNvim Auto Install
-- ===========================================
require("lazy").setup({ --Start Quote
-- -------------------------------------------

-- -------------------------------------------
-- 5.1 Style Plugin
-- -------------------------------------------
{
    'olimorris/onedarkpro.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd("colorscheme onedark")
    end,
},
{
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    }
},
-- -------------------------------------------
-- 5.2 Editing Plugin
-- -------------------------------------------
-- -------------------------------------------
-- 5.1 Leagcy Plugin
-- -------------------------------------------
{
    "mg979/vim-visual-multi",
    init = function()
        vim.g.VM_maps = {
            ['Find Under']         = '<C-d>',	
            ['Find Subword Under'] = '<C-d>'
        }
    end,
},

-- -------------------------------------------
}) --End Lazy.nvim Quote
-- ===========================================









