" This should be pretty early before linebreak syntax
set nocompatible
let g:startify_custom_header = [
\
\ '   ██████╗ ███████╗███╗   ███╗███████╗███████╗███████╗ █████╗  ██████╗ ███████╗ ',
\ '   ██╔══██╗██╔════╝████╗ ████║██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝ ██╔════╝ ',
\ '   ██████╔╝█████╗  ██╔████╔██║█████╗  ███████╗███████╗███████║██║  ███╗█████╗   ',
\ '   ██╔═══╝ ██╔══╝  ██║╚██╔╝██║██╔══╝  ╚════██║╚════██║██╔══██║██║   ██║██╔══╝   ',
\ '   ██║     ███████╗██║ ╚═╝ ██║███████╗███████║███████║██║  ██║╚██████╔╝███████╗ ',
\ '   ╚═╝     ╚══════╝╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ',
\ ]
" +++++++++++++++++++++++++++++++++++++++++++
" File: .vimrc
" Author: PEMessage
" Description: This is my VIM8+/NeoVIM configuration
" Last Modified:  2024-03-12 19:39
" +++++++++++++++++++++++++++++++++++++++++++
"
" ------------------------------------------------------------------
" Naming Convention
"   global       : g:pe_<snake_case>   e.g. g:pe_cache_dir
"   script-local : s:<snake_case>      e.g. s:thisfile
"   environment  : $PE_<UPPER_CASE>    e.g. $PE_PLUG_GROUP
"   func/command : PE<CamelCase>       e.g. PEGrep / PEDate
" ------------------------------------------------------------------
"



" 0. Configure List
" ===========================================

    " Plug-Mirror
    let s:vim_plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    " let s:vim_plug_url = 'https://gitee.com/yaozhijin/vim-plug/raw/master/plug.vim'

    " let g:plug_url_format='https://git::@hub.fastgit.xyz/%s.git'
    " let g:plug_url_format='https://ghproxy.com/https://github.com/%s.git'

    " TrueColor
    " set termguicolors
    set nocompatible
    " See: https://stackoverflow.com/questions/62702766/termguicolors-in-vim-makes-everything-black-and-white
    if !has('gui_running') && &term =~ '\%(screen-256color\|tmux-256color\)'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
    set termguicolors

    " set viminfo='20,<50,s10,h


    " Comment Color
    let s:comment_color = {"gui": "#00af87", "cterm": "246", "cterm16": "7"}
    let g:pe_complete_sys=""

    let g:lightline = {
                \ 'colorscheme': 'selenized_black',
                \ 'active': {
                    \   'left': [ [ 'mode', 'paste' ],
                    \             [ 'gitbranch', 'readonly', 'filename', 'modified', 'searchcount' ] ]
                    \ },
                \ }
                " \ 'component_function': {
                "    \ },
                "    \   'gitbranch': 'FugitiveHead',
                "    \   'searchcount': 'SearchIndex'
    nnoremap <leader>tt :call lightline#toggle()<CR>
    let g:which_key_map = {}

                    " \   'gitbranch': 'FugitiveHead',
                    " \   'searchcount': 'SearchIndex'

    let s:thisfile = expand('<sfile>')
    let s:thisdir = fnamemodify(s:thisfile, ':h')
    let s:lockvim = s:thisdir . '/lock.vim'

" 1. Select plug we want
" ===========================================
    " Plug levels: none(pure vim, no plugins) / lite(basic+colorscheme) / full(all)
    " Default none; use :PlugInit [level] inside vim to install on demand
    let g:pe_plug_levels = {
                \ 'none': [],
                \ 'lite': ['basic', 'colorscheme'],
                \ 'full': ['*'],
                \ }

    " Cache dir and level-persistence file (PlugInit writes the level here)
    let g:pe_cache_dir = expand('~/.cache/vim')
    if !isdirectory(g:pe_cache_dir)
        call mkdir(g:pe_cache_dir, "p")
    endif
    let g:pe_plug_level_file = g:pe_cache_dir . '/plug_level'

    function! s:ReadPlugLevel() abort
        if exists('$PE_PLUG_GROUP') && has_key(g:pe_plug_levels, tolower($PE_PLUG_GROUP))
            return tolower($PE_PLUG_GROUP)
        endif
        if filereadable(g:pe_plug_level_file)
            let l:lv = trim(get(readfile(g:pe_plug_level_file), 0, ''))
            if has_key(g:pe_plug_levels, l:lv)
                return l:lv
            endif
        endif
        return 'none'
    endfunction

    let g:pe_plug_level = s:ReadPlugLevel()
    let g:pe_plug_group = copy(g:pe_plug_levels[g:pe_plug_level])

    function! PSelect(group) abort
        for pattern in g:pe_plug_group
            if pattern ==# '*' || a:group ==# '*'
                return 1
            endif
            if a:group ==# pattern
                return 1
            endif
        endfor
        return 0
    endfunction

" 2. Auto Install ViM-Plug & PlugInit
" ===========================================

    " Ensure vim-plug is installed; returns 1=just installed / 0=already present / -1=failed
    function! s:EnsurePlug() abort
        if has('nvim')
            let g:pe_runtime_path = stdpath('data') . '/site'
        else
            exe 'set rtp+=' . expand('~/.config/vim')
            let g:pe_runtime_path = expand('~/.config/vim')
        endif
        if !empty(glob(g:pe_runtime_path . '/autoload/plug.vim'))
            return 0
        endif
        echo 'Installing vim-plug ...'
        silent execute '!curl -fLo '.g:pe_runtime_path.'/autoload/plug.vim --create-dirs '.s:vim_plug_url
        if empty(glob(g:pe_runtime_path . '/autoload/plug.vim'))
            echohl ErrorMsg | echo 'vim-plug download failed' | echohl None
            return -1
        endif
        return 1
    endfunction

    " Validate and persist the level; returns 1 on success, 0 otherwise
    function! s:PlugInitPrepare(level) abort
        let l:level = (a:level == '') ? g:pe_plug_level : tolower(a:level)
        if !has_key(g:pe_plug_levels, l:level)
            echohl WarningMsg
            echo 'Unknown plug level "' . l:level . '". Available: ' . join(sort(keys(g:pe_plug_levels)), ', ')
            echohl None
            return 0
        endif
        let g:pe_plug_level = l:level
        let g:pe_plug_group = copy(g:pe_plug_levels[l:level])
        let $PE_PLUG_GROUP = l:level
        call writefile([l:level], g:pe_plug_level_file)
        let g:pe_plug_need_install = (l:level !=# 'none')
        return 1
    endfunction

    function! s:PlugLevelList(A, L, P) abort
        return filter(sort(keys(g:pe_plug_levels)), 'v:val =~ "^" . a:A')
    endfunction

    " :PlugInit [none|lite|full]  install and enable plugins for the level
    "   Prefer restoring pinned versions from lockfile (PlugSnapshotLoad);
    "   :PlugInit! forces a fresh install.
    command! -bang -nargs=? -complete=customlist,<SID>PlugLevelList PlugInit
                \ if s:PlugInitPrepare(<q-args>)
                \ |   execute 'source' s:thisfile
                \ |   if get(g:, 'pe_plug_need_install', 0) && exists(':PlugInstall')
                \ |       if !<bang>0 && filereadable(s:lockvim)
                \ |           echo 'Restoring plugins from lockfile: ' . s:lockvim
                \ |           execute 'source' s:lockvim
                \ |       else
                \ |           echo 'Installing plugins (no lockfile / forced) ...'
                \ |           execute 'PlugInstall'
                \ |       endif
                \ |       execute 'source' s:thisfile
                \ |       echo 'Plug level "' . g:pe_plug_level . '" ready.'
                \ |   endif
                \ | endif

    " At startup, if plugins are enabled, ensure vim-plug exists and reload
    if PSelect('*')
        if s:EnsurePlug() > 0
            execute 'source' s:thisfile
        endif
    endif



" 3. Some General Setting
" ===========================================


" -------------------------------------------
" 3.1 Basic Setting Zone
" -------------------------------------------
    filetype plugin indent on
    set nrformats-=octal

    set nocompatible     " 禁用 vi 兼容模式
    " set viminfo=%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.viminfo
    "             | |    |   |   |    | |  + viminfo file path
    "             | |    |   |   |    | + file marks 0-9,A-Z 0=NOT stored
    "             | |    |   |   |    + disable 'hlsearch' loading viminfo
    "             | |    |   |   + command-line history saved
    "             | |    |   + search history saved
    "             | |    + files marks saved
    "             | + lines saved each register (new name for ", vi6.2)
    "             + save/restore buffer list
    set viminfo='600,<50,s10,h
    set helplang=cn      " 设置中文帮助手册
    set nowrap           " 关闭自动换行
    set ruler            " 显示光标位置
    set ffs=unix,dos,mac " 文件换行符，默认使用 unix 换行符
    set updatetime=700
    set linebreak
    set wildmenu

    if has('patch-9.1.1771')
        set wildmode=noselect:lastused,full
    else
        set wildmode=longest,longest:full " bash like
    endif


    " See: https://github.com/vim/vim/commit/3908ef5017a6b4425727013588f72cc7343199b9
    if has('patch-8.2.4325')
        set wildoptions=pum
    endif
    if has('patch-9.1.1576')
        autocmd CmdlineChanged [:] call wildtrigger()
    endif
    " set nomore

    " Quick Snippet
    " Snippet: put =execute('map')  将built in pager 内容放置到当前buffer
    " Snippet: w !sudo tee % > /dev/null
    "   :w    – Write a file (actually buffer).
    "   !sudo – Call shell with sudo command.
    "   tee   – The output of write (vim :w) command redirected using tee.
    "   %     – The % is nothing but current file name.
    "           In this example, it is /etc/apache2/conf.d/mediawiki.conf.
    "           In other words tee command is run as root and it takes standard input (or the buffer)
    "           and write it to a file represented by %. However,
    "           this will prompt to reload file again (hit L to load changes in vim itself):


" -------------------------------------------
" 3.2 Coding Zone
" -------------------------------------------
    if has('multi_byte')
        " 内部工作编码
        set encoding=utf-8

        " 文件默认编码
        set fileencoding=utf-8

        " 打开文件时自动尝试下面顺序的编码
        set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1,utf-16,sjis
    endif

    if has('folding')
        " 允许代码折叠
        set foldenable

        " 代码折叠默认使用缩进
        set fdm=indent

        " 默认打开所有缩进
        set foldlevel=99
    endif

    if has('syntax')
        syntax enable
        syntax on
    endif


    if has('mouse')
        set mouse+=a
        if !has('nvim')
            set ttymouse=sgr
        endif
        vnoremap RightMouse "+y
    endif

    set diffopt+=iwhite
    if has('patch-8.1.0360')
        set diffopt+=internal,algorithm:patience,iwhite
    endif
    if has('patch-9.1.1243')
        set diffopt+=linematch:60
    endif

    " if has('patch-8.1.1270')
    "     set shortmess-=S
    " endif

    " zf to fold, zo to open, zd to delete
    set foldmethod=manual




" -------------------------------------------
" 3.3 Search Zone
" -------------------------------------------
    set ignorecase  " smartcase depend this options
    set smartcase   " 智能搜索大小写判断，默认忽略大小写，除非搜索内容包含大写字母
    if has('reltime')
        set incsearch
    endif
    set hlsearch    " 高亮搜索内容
    set gp=rg\ -n



" -------------------------------------------
" 3.4 Tab and Indent Setting
" -------------------------------------------
    set tabstop=4                  " Tab 长度，默认为8
    set smarttab                   " 根据文件中其他地方的缩进空格个数来确定一个tab是多少个空格
    set expandtab                  " 展开Tab

    set shiftwidth=4               " 缩进长度，设置为4
    set autoindent                 " 自动缩进
    set cindent                    " C语言更好的缩进

    filetype plugin indent on
    set cinkeys-=0#
    set indentkeys-=0#

    set conceallevel=2
    set concealcursor=inc
    " Disable json filetype conceal
    " (hide special char for better read)
    " But I dont need this
    let g:vim_json_conceal = 0



    set backspace=eol,start,indent " 类似所有编辑器的删除键

    if has('autocmd')
        filetype plugin indent on  " 允许 Vim 自带脚本根据文件类型自动设置缩进等
    endif

    " Tab Line Setting Zone
    set hidden

" -------------------------------------------
" 3.5 Window Setting
" -------------------------------------------
    augroup vimrc_help
        autocmd!
        autocmd FileType help wincmd L
        autocmd FileType man wincmd L
        " Bug: using Vista!! close panel to help page will cause errormsg
        " autocmd BufEnter *.* if &buftype == 'help' | wincmd L | endif
        " Fix: ignore v:errmsg
        autocmd BufEnter *.* if &buftype == 'help' | silent! wincmd L | endif
    augroup END


	runtime ftplugin/man.vim
    runtime macros/matchit.vim
    if has('patch-9.1.1591')
        packadd! editorconfig
    endif

    " augroup previewWindowPosition
    "     au!
    "     autocmd BufWinEnter * call PreviewWindowPosition()
    " augroup END
    " function! PreviewWindowPosition()
    "     if &previewwindow
    "         wincmd L
    "     endif
    " endfunction
    " hi

    " See https://vim.fandom.com/wiki/Make_views_automatic
    execute "set viewdir=" . g:pe_cache_dir . '/view'
    set viewoptions-=options
    let g:skipview_files = [
                \ '[EXAMPLE PLUGIN BUFFER]'
                \ ]
    function! MakeViewCheck()
        if has('quickfix') && &buftype =~ 'nofile'
            " Buffer is marked as not a file
            return 0
        endif
        if empty(glob(expand('%:p')))
            " File does not exist on disk
            return 0
        endif
        if len($TEMP) && expand('%:p:h') == $TEMP
            " We're in a temp dir
            return 0
        endif
        if len($TMP) && expand('%:p:h') == $TMP
            " Also in temp dir
            return 0
        endif
        if index(g:skipview_files, expand('%')) >= 0
            " File is in skip list
            return 0
        endif
        return 1
    endfunction
    " augroup vimrcAutoView
    "     autocmd!
    "     " Autosave & Load Views.
    "     autocmd BufWritePost,BufLeave,WinLeave ?* if MakeViewCheck() | mkview | endif
    "     autocmd BufWinEnter ?* if MakeViewCheck() | silent loadview | endif
    " augroup end
    " autocmd BufWinLeave ?* mkview
    " autocmd BufWinEnter ?* silent loadview
    "
    " See: source $VIMRUNTIME/defaults.vim for more
    " Put these in an autocmd group, so that you can revert them with:
    " ":augroup vimStartup | exe 'au!' | augroup END"




    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    augroup vimStartup
        au!
        autocmd BufReadPost *
                    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                    \ |   exe "normal! g`\""
                    \ | endif
    augroup END


" -------------------------------------------
" 3.6 Meta Setting
" -------------------------------------------
    if $TMUX != ''
        set ttimeoutlen=30
        let g:pe_tmux_pane_id = system("tmux display-message -p '#{pane_id}'")
        let g:pe_tmux_window_id = system("tmux display-message -p '#{window_id}'")
    elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
        set ttimeoutlen=80
        let g:pe_tmux_pane_id = ''
        let g:pe_tmux_window_id = ''
    endif
    " 终端下允许 ALT，详见：http://www.skywind.me/blog/archives/2021
    " 记得设置 ttimeout （见 init-basic.vim） 和 ttimeoutlen （上面）
    " Plug ‘vim-fixkey’ 更好的解决了这个问题
    "----------------------------------------------------------------------
    " if has('nvim') == 0 && has('gui_running') == 0
    "     function! s:metacode(key)
    "         exec "set <M-".a:key.">=\e".a:key
    "     endfunc
    "     function! s:set_key(key, keyCode)
    "         if get(g:, 'altmeta_skip_meta', 0) == 0
    "             execute "set " . a:key . "=" . a:keyCode
    "         endif
    "     endfunc

    "     for i in range(10)
    "         call s:metacode(nr2char(char2nr('0') + i))
    "     endfor
    "     for i in range(26)
    "         call s:metacode(nr2char(char2nr('a') + i))
    "         call s:metacode(nr2char(char2nr('A') + i))
    "     endfor
    "     for c in [',', '.', '/', ';', '{', '}']
    "         call s:metacode(c)
    "     endfor
    "     for c in ['?', ':', '-', '_', '+', '=', "'"]
    "         call s:metacode(c)
    "     endfor
    "     for c in ['`']
    "         call s:metacode(c)
    "     endfor
    " endif
" -------------------------------------------
" 3.7 VIM Style Setting
" -------------------------------------------
    set laststatus=2            " 总是显示状态栏
    set showtabline=2           " 总是显示标签栏
    set splitright              " 水平切割窗口时，默认在右边显示新窗口

    set statusline=                                 " 清空状态了
    set statusline+=\ %F                            " 文件名
    set statusline+=\ [%1*%M%*%n%R%H]               " buffer 编号和状态
    set statusline+=%=                              " 向右对齐
    set statusline+=%{!getcwd()}
    set statusline+=\ %y                            " 文件类型
    nnoremap <silent> <leader>wd :echo getcwd()<CR>

    " 最右边显示文件编码和行号等信息，并且固定在一个 group 中，优先占位
    set statusline+=\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %v:%l/%L%)

" -------------------------------------------
" 3.8 Basic Tag setting
" -------------------------------------------
    " See: https://www.zhihu.com/question/35808196/answer/130915301
    " './' 的意思是，vim解析时，碰到 "./" 会被替换成当前编辑文件的文件夹
    " 注意第一个 tags后面有一个分号，代表 “向上搜索”
    " 第二个tags才是代表在 “当前文件夹”
    " Also:
    "   能新split出一个窗口来再跳转到定义，
    "   比会把当前窗口切换走了的 <C-]> 好用。
    "   use <C-W>]
    "       <C-W>}
    " set tags=./.tags;,.tags
    set tags=./tags;,tags,./.tags;,.tags



" 4. Keybending list
" ===========================================

"  Mark A
"  " Difference Map | Norm | Ins | Cmd | Vis | Sel | Opr | Term | Lang |
"  "                +------+-----+-----+-----+-----+-----+------+------+
"  " [nore]map      | yes  |  -  |  -  | yes | yes | yes |  -   |  -   |
"  " n[nore]map     | yes  |  -  |  -  |  -  |  -  |  -  |  -   |  -   |
"  " [nore]map!     |  -   | yes | yes |  -  |  -  |  -  |  -   |  -   |
"  " i[nore]map     |  -   | yes |  -  |  -  |  -  |  -  |  -   |  -   |
"  " c[nore]map     |  -   |  -  | yes |  -  |  -  |  -  |  -   |  -   |
"  " v[nore]map     |  -   |  -  |  -  | yes | yes |  -  |  -   |  -   |
"  " x[nore]map     |  -   |  -  |  -  | yes |  -  |  -  |  -   |  -   |
"  " s[nore]map     |  -   |  -  |  -  |  -  | yes |  -  |  -   |  -   |
"  " o[nore]map     |  -   |  -  |  -  |  -  |  -  | yes |  -   |  -   |
"  " t[nore]map     |  -   |  -  |  -  |  -  |  -  |  -  | yes  |  -   |
"  " l[nore]map     |  -   | yes | yes |  -  |  -  |  -  |  -   | yes  |
"

" -------------------------------------------
" 4.1 Basic Setting Zone ( Input Mode  )
" -------------------------------------------
    " inoremap jj <ESC>
    nnoremap <silent> j gj
    nnoremap <silent> k gk
    nnoremap <C-c> <ESC>
    nnoremap ZA :confirm qall<CR>

    " nnoremap _ 4kzz
    " nnoremap + 5jzz

    "Emacs Like ShortCut
    noremap! <C-A> <home>
    noremap! <C-E> <end>
    noremap! <C-_> <C-K> " 插入 digraph（见 :h digraph），快速输入日文或符号等
    " inoremap <m-f> <S-Right>
    " inoremap <m-b> <S-Left>


    "    CTRL-H 同 `<BS>` 一样功能，我们都是直接用 `<BS>` 没人CTRL-H的，直接覆盖掉
    "    CTRL-J 同回车（有两个码 0x0d 或 0x0a），C-J是0x0d，硬回车是0x0a，没人按这个，覆盖。
    "    CTRL-K 输入 digraph，比如可以用来输入欧洲文字，不需要，实在需要可以把这个功能挪给 INSERT模式下的 CTRL-B （空闲），或者 <c-x><c-k> ，完全可以覆盖。
    "    CTRL-L 重绘，很少用，自己可以把他挪到 <leader>r 之类的键去多干净，覆盖。
    " nnoremap <silent><M-S-H> :wincmd h<CR>
    " nnoremap <silent><M-S-L> :wincmd l<CR>
    " nnoremap <silent><M-S-J> :wincmd j<CR>
    " nnoremap <silent><M-S-K> :wincmd k<CR>

" -------------------------------------------
" 4.2 wincmd/buffer/tab keymap
" -------------------------------------------
    " Switch window
    tnoremap <silent><M-S-H> <C-W>:wincmd h<CR>
    tnoremap <silent><M-S-L> <C-W>:wincmd l<CR>
    tnoremap <silent><M-S-J> <C-W>:wincmd j<CR>
    tnoremap <silent><M-S-K> <C-W>:wincmd k<CR>

    " Switch buffer
    nnoremap <silent><M-S-N> :bnext<CR>
    nnoremap <silent><M-S-P> :bprev<CR>

    " Switch Tab
    " nnoremap <silent><C-S-TAB> :tabp<CR>
    " inoremap <silent><C-S-TAB> <C-o>:tabp<CR>
    " nnoremap <silent><C-TAB>   :tabn<CR>
    " inoremap <silent><C-TAB>   <C-o>:tabn<CR>
    " nnoremap gq :exit<CR>

" -------------------------------------------
" 4.3 Mouse mapping
" -------------------------------------------
    " nnoremap <MiddleMouse>     :tabclose<CR>
    vnoremap <RightMouse>            "+y
    inoremap <RightMouse>       <C-o>"+p


" -------------------------------------------
" 4.4 Extend mapping and command
" -------------------------------------------
    nnoremap <leader>rcc  :w<CR> :source %<CR> " Re:Configuration

    function! PERCEdit()
        let full_path = expand(s:thisfile)

        let win_ids = win_findbuf(bufnr(full_path))
        if !empty(win_ids)
            " Jump to the first window that shows this buffer
            call win_gotoid(win_ids[0])
        else
            " Open in a new tab
            execute 'tabedit ' .  fnameescape(full_path)
        endif
    endfunction

    nnoremap <leader>rce  :call PERCEdit()<CR>

    let g:which_key_map['`'] = {
                \ 'name': '+search-highlight'
                \}
    nnoremap <leader>``   :nohlsearch<CR>:match none<CR>
    nnoremap <leader>`1   :set! virtualedit=onemore<CR>
    nnoremap <leader>ig  :set ignorecase!<CR>
    nnoremap <leader>wp  :set nowrap!<CR>
    nnoremap <leader>cl  :set cursorline!<CR>

    let g:which_key_map['n'] = {
                \ 'name': '+line-number'
                \}
        nnoremap <leader>nu  :set number!<CR>
                            set number
        nnoremap <leader>nr :set relativenumber!<CR>
    nnoremap <leader>tb  :tab ball<CR>
    " nnoremap <leader>gp  `[v`]
    nnoremap gp  `[v`]

    command! PCD execute 'cd ' . expand('%:p:h')
    " command! PCD execute 'cd' . expand('%:p:h')

    " Credit: deepseek-v3
    function! Tcd(target)
        let current_dir = getcwd()
        while current_dir != '/'
            if filereadable(current_dir . '/' . a:target) || isdirectory(current_dir . '/' . a:target)
                execute 'cd ' . fnameescape(current_dir)
                return 0
            elseif fnamemodify(current_dir, ':t') == a:target
                execute 'cd ' . fnameescape(current_dir)
                return 0
            endif
            let current_dir = fnamemodify(current_dir, ':h')
        endwhile
        echo 'No parent directory containing ' . a:target . ' found; staying in ' . getcwd()
        return 1
    endfunction
    command! -nargs=1 Tcd call Tcd(<q-args>)
    command! Rcd call Tcd('.repo')

    command! PFile echo  expand('%:p') |  call Yank(expand('%:p'))
    " See: https://www.cyberciti.biz/faq/vim-vi-text-editor-save-file-without-root-permission/
    command Psudow :execute ':silent w !sudo tee % > /dev/null' | :edit!
    nnoremap <silent><leader>ro :set readonly!<CR>:set modifiable<CR>

    " vnoremap <cr> iwoiwo

" -------------------------------------------
" 4.5 Extend mapping on cmap and vmap
" -------------------------------------------
    " 1. There is no such thing as "search mode": / and ? are like :,
    "    they start command-line mode so you need a command-line mode mapping.
    " 2. It is an expression mapping because we want the right-hand
    "    side of the mapping to be context-specific.
    " 3. We want <Tab> to do <C-g> and <S-Tab> to do <C-t> only when command-line mode was started with / or ?.
    "    In other scenarios, we want them to keep their default meaning.
    " 4. <Tab> can't be used directly in the right-hand side of a command-line mode mapping
    "    so we use :help 'wildcharm' as a workaround.
    " See: https://www.reddit.com/r/vim/comments/hyxo4u/usefulness_of_ctrlg_and_ctrlt_while_searching/
    set wildcharm=<C-z>
    " cnoremap <Tab> <C-F>A<C-N>
    cnoremap <expr> <Tab>   getcmdtype() =~ '[\/?]' ? "<C-g>" : "<C-z>"
    cnoremap <expr> <S-Tab> getcmdtype() =~ '[\/?]' ? "<C-t>" : "<S-Tab>"
    " CTRL-E See wildmenu for more
    cnoremap <expr> <C-c>   pumvisible() ? "<C-y>" : "<C-c>"

    vnoremap tt :s/\s\+$//e<CR>:set nohls<CR>
    " See: v_p v_P swap function between these
    " Also See: https://superuser.com/a/1759793/1659524
    if has('patch-8.2.4881')
        xnoremap p P
        xnoremap P p
    else
        xnoremap P p
        xnoremap p "_d[p
    endif

    xnoremap x "_d


    " Visual mode pressing * or # searches for the current selection
    " Super useful! From an idea by Michael Naumann
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
        elseif a:direction == 'fs'
            let @/= l:pattern

        elseif a:direction == 'fa'
            let l:tmp = @/
            let l:pattern = l:tmp . "\\|" . l:pattern
            echo l:pattern
            execute "normal /" . l:pattern . "\<CR>"
        elseif a:direction == 'fsa'
            let l:tmp = @/
            let l:pattern = l:tmp . "\\|" . l:pattern
            echo l:pattern
            let @/= l:pattern

        endif

        let @/ = l:pattern
        let @" = l:saved_reg
        " set hls
    endfunction
    vnoremap <silent> * :<C-u>call VisualSelection('fs')<CR>:set hls<CR>
    vnoremap <silent> & :<C-u>call VisualSelection('fsa')<CR>:set hls<CR>
    vnoremap <silent> # :<C-u>call VisualSelection('b')<CR>:set hls<CR>
" 5. Netrw Setting
" ===========================================

" -------------------------------------------
" 5.1 Basic netrw setting
" -------------------------------------------
    let g:netrw_banner = 0                      " 设置是否显示横幅
    " if argv(0) ==# '.'
    "     let g:netrw_browse_split = 0
    " else
    "     let g:netrw_browse_split = 0
    " endif
    " let g:netrw_browse_split = 4

    " let g:netrw_preview = 1                     " 指针保留于Netrw
    " let g:netrw_winsize = 25                    " %25的窗口大小
    let g:netrw_liststyle = 1                   " 设置目录列表的样式：树形
    let g:netrw_sort_sequence = '[\/]$,*'
    let g:netrw_hide = 1
    let g:netrw_keepj = ''

    autocmd FileType netrw call s:RemoveNetrwMap()
    function! s:RemoveNetrwMap()
        " if hasmapto('<Plug>NetrwRefresh')
        if &filetype ==# 'netrw'
        " Unmap Netrw Keybind
            " unmap <buffer> <C-I>
            " unmap <buffer> <C-O>
            " unmap -
            " unmap <buffer> cd

        " map Netrw Keybind
            " Forward dir
            " nmap <buffer> <C-I> U
            " Backword dir
            " nmap <buffer> <C-O> u
            " ctrl-l for left pannel

        " New Map
            " Back to parent dir
            nmap <buffer> <silent> <nowait> H       <Plug>NetrwBrowseUpDir
            nmap <buffer> <silent> <nowait> H       <Plug>NetrwBrowseUpDir
            nmap <buffer> <silent> <nowait> h       <Plug>NetrwBrowseUpDir
            nmap <buffer> . gh
            " nmap <buffer> <C-0> echo b
            " Enter next dir
            nmap <buffer> L       <enter>
            nmap <buffer> l       <enter>
            nmap <buffer> <leader>b :wincmd c<CR>
        endif
    endfunction

    " nnoremap <silent><leader>b  :Explore<CR>


    function! s:MapCmdWin()
        " by remap it to clear origin mapping, to avoid some wild behavior
        nnoremap <buffer> <C-c> <C-c>
        nnoremap <buffer> <enter> <enter>
    endfunction
    autocmd CmdwinEnter * call s:MapCmdWin()

" -------------------------------------------
" 5.2 Buffer mapping
" -------------------------------------------

    " command! PEWrite execute 'w !sudo tee % <bar> edit! '
    " cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
    function! PEWrite()
        " Credit: https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
        execute 'silent! w !sudo tee % > /dev/null' |
            edit!
    endfunction
    command! PEWrite :call PEWrite()
    command! PWrite :call PEWrite()
    command! ConvertUTF :w ++enc=utf-8 % | e %

    " command! PWrite call SudoSaveFile()
    " function! SudoSaveFile() abort
    "     execute (has('gui_running') ? '' : 'silent') 'write !env SUDO_EDITOR=tee sudo -e % >/dev/null'
    "     let &modified = v:shell_error
    " endfunction



" 6. VIM Plug-in Zone (Part1)
" ===========================================
" -------------------------------------------
" 6.0 Start of plug
" -------------------------------------------
if PSelect('*')
    call plug#begin(pe_runtime_path . '/plugged')
    " helper
    function! Cond(cond, ...)
        let opts = get(a:000, 0, {})
        return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
    endfunction

    " if filereadable(s:lockvim)
    "     execute 'source' s:lockvim
    " endif

    command! -bang -nargs=? PlugSnapshotSave call s:PlugSnapshotSave(<bang>0, <q-args>)
    function! s:PlugSnapshotSave(bang, fname)
        let l:default = s:lockvim
        let l:target = (a:fname == '') ? l:default : a:fname
        let l:cmd = 'PlugSnapshot' . (a:bang ? '!' : '')
        execute l:cmd fnameescape(l:target)
        echo "Snapshot saved to " . l:target
    endfunction

    command! -bang -nargs=? PlugSnapshotLoad call s:PlugSnapshotLoad(<bang>0, <q-args>)
    function! s:PlugSnapshotLoad(bang, fname)
        let l:default = s:lockvim
        let l:target = (a:fname == '') ? l:default : a:fname
        let l:cmd = 'source' . (a:bang ? '!' : '')
        execute l:cmd fnameescape(l:target)
        " echo "Snapshot saved to " . l:target
    endfunction


" -------------------------------------------
" 6.1 Basic Function
" -------------------------------------------
    " Some little tweak
    " Plug 'drmikehenry/vim-fixkey'
    Plug 'junegunn/vim-plug'
    " NOTE: !!!fixkey will casuse vim blink(flick) at startup!!!!
    Plug 'PEMessage/vim-fixkey'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
            noremap <silent> <C-e> :FZF<CR>
    if (0)
        Plug 'vim-fuzzbox/fuzzbox.vim'
            noremap <silent> <C-p> :FuzzyBuffer<CR>
            noremap <silent> <C-r> :FuzzyMru<CR>
            let g:fuzzbox_window_layout = { 'mru': { 'preview': 0 } }
            " Windows terminal work wire for M-f and M-b, don't know why it
            " doesn't work for vim9script plugin, has to add \x80FJ \x80FK
            let g:fuzzbox_keymaps = {
                        \ 'menu_up': ["\<c-p>", "\<Up>"],
                        \ 'menu_down': ["\<c-n>", "\<Down>"],
                        \ 'menu_select': ["\<CR>"],
                        \ 'preview_up': ["\<c-i>"],
                        \ 'preview_down': ["\<c-f>"],
                        \ 'preview_up_half_page': ["\<c-u>"],
                        \ 'preview_down_half_page': ["\<c-d>"],
                        \ 'cursor_begining': ["\<c-a>"],
                        \ 'cursor_end': ["\<c-e>"],
                        \ 'cursor_word_left': ["\<C-Left>", "\<S-Left>", "\<M-b>", "\<C-h>", "\x80FJ"],
                        \ 'cursor_word_right': ["\<C-Right>", "\<S-Right>", "\<M-f>", "\<C-l>", "\x80FK"],
                        \ 'backspace': ["\<bs>"],
                        \ 'delete_word': ["\<C-w>"],
                        \ 'delete_all': ["\<c-k>"],
                        \ 'delete_prefix': [],
                        \ 'exit': ["\<Esc>", "\<c-c>", "\<c-[>"],
                        \ }
        " Plug 'girishji/scope.vim'
        "     " let g:using_plugin_scope = 1
    else
            " Note: complict with cmdwin (q/ or CTRL-F in command mode)
            " noremap <silent> <C-f> :Marks<CR>
            noremap <silent> <C-r> :History<CR>
            noremap <leader>ft :BTags<CR>
            command VMaps call fzf#vim#maps('x')
            let g:fzf_preview_window = []
        " Plug 'Yggdroot/LeaderF'
        "     let g:Lf_ShortcutF = ''
        "     let g:Lf_ShortcutF = ''
        " Plug 'linrongbin16/fzfx.vim'
        " Plug 'tacahiroy/ctrlp-funky'

        Plug 'ctrlpvim/ctrlp.vim'
            " NOTE: !!! will cause mru error !!! not use it
            " if has('python3') || has('python' )
            "     Plug 'FelikZ/ctrlp-py-matcher'
            "     let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
            " endif
            let g:ctrlp_map = ''
            let g:ctrlp_root_markers = ['.root', 'repo', '.git']
            let g:ctrlp_max_depth = 3
            let g:ctrlp_mruf_max = 250
            let g:ctrlp_mruf_relative = 1
            let g:ctrlp_prompt_mappings = {
                        \ 'ToggleType(1)':        ['<c-up>'],
                        \ 'ToggleType(-1)':       ['<c-down>'],
                        \}
            " nnoremap <c-f> :CtrlPBufTag<Cr>

            " noremap <silent> <C-r> :CtrlPMRU<CR>
            noremap <silent> <C-p> :CtrlPBuffer<CR>
            " noremap <silent> <C-t> :CtrlPBufTagAll<CR>
            " nnoremap <Leader>fu :CtrlPFunky<Cr>
            " nnoremap <leader>cm :\<C-U>FzfxCommands<CR>
            " nnoremap <C-S-p> :\<C-U>FzfxCommands<CR>


            " nnoremap <leader>fbr :\<C-U>FzfxBranches<CR>

            " nnoremap <leader>fg :\<C-U>FzfxLiveGrep<CR>
            " nnoremap <leader>ff :\<C-U>FzfxFiles<CR>
            " nnoremap <space>fw :\<C-U>FzfxLiveGrep<CR>
            " if has('autocmd')
            "     autocmd filetype fzf
            " else
            " augroup PE_FZF_GROUP
            "     autocmd!
            "     autocmd filetype fzf tnoremap  <buffer> <C-o> <enter>
            " augroup END
            " JUST USE <C-M> AS ENTER
    endif

    Plug 'mhinz/vim-grepper'
        let g:grepper = {}
        let g:grepper.tools = ['rg', 'rgi', 'git']
        let g:grepper.rg = {
                    \ 'grepprg':    'rg --vimgrep',
                    \ 'grepformat': '%f:%l:%c:%m,%f'
                    \ }
        let g:grepper.rgi = {
                    \ 'grepprg':    'rg -i --vimgrep',
                    \ 'grepformat': '%f:%l:%c:%m,%f'
                    \ }
        noremap <C-k> viw<plug>(GrepperOperator)
        let g:grepper.operator = {}
        let g:grepper.operator.prompt = 1
        vnoremap <C-k> <plug>(GrepperOperator)
    Plug 'duane9/nvim-rg'

    Plug 'lambdalisue/vim-fern'
        nnoremap <silent><leader>b  :Fern . -drawer<CR>
    Plug 'wsdjeg/vim-fetch'

    Plug 'justinmk/vim-dirvish'
    Plug 'roginfarrer/vim-dirvish-dovish', {'branch': 'main'}

    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
        let g:M_default_mappings = 0
        let g:VM_mouse_mappings  = 0
        let g:VM_maps = {}
        " Basic
        let g:VM_maps['Find Under']          = '<C-h>'
        let g:VM_maps['Find Subword Under']  = '<C-h>'
        let g:VM_maps["Exit"]                = '<C-c>'   " quit VM
        " Arrow key
        let g:VM_maps["Add Cursor Up"]       = '<C-Up>'
        let g:VM_maps["Add Cursor Down"]     = '<C-Down>'

        " Mouse
        let g:VM_maps["Mouse Cursor"]        = '<C-LeftMouse>'
        " Multi-Mode
        let g:VM_maps["Align"]               = '<C-a>'
        let g:VM_maps["Enlarge"]             = "="
        let g:VM_maps["Shrink"]              = "-"
        " Move
        let g:VM_maps["Find Next"]           = ']'
        let g:VM_maps["Find Prev"]           = '['
        let g:VM_maps["Remove Region"]       = 'Q'
        let g:VM_maps["Skip Region"]         = 'q'

    Plug 'easymotion/vim-easymotion'
        let g:EasyMotion_smartcase = 1
        let g:EasyMotion_enter_jump_first= 1
        let g:EasyMotion_space_jump_first = 1
        let g:EasyMotion_use_upper = 1

    "     nmap / <Plug>(easymotion-sn)
    "     nnoremap <leader>/ /
        map <space> <Plug>(easymotion-s2)


        " See: https://www.reddit.com/r/vim/comments/lhohqd/remap_after_searching/
        " https://github.com/romainl/vim-cool
        " cnoremap <expr> <silent> <cr> getcmdtype() =~ '[?/]' ? "\<cr>:noh\<cr>" : "\<cr>"
        " nunmap ds
        " <leader>yr
    " Plug 'vim-scripts/YankRing.vim'
    "     " let vimd_path =
    "     " if !isdirectory(vimd_path)
    "     "     call mkdir(vimd_path, "p")
    "     " endif
    "     let g:yankring_history_dir = pe_cache_dir
    "     " nnoremap <silent> <leader>yy :YRShow<CR>
    "     nnoremap <silent> <C-y> :YRShow<CR>
    "     inoremap <silent> <C-y> <ESC>:YRShow<CR>
    "     " Swap p and P (do not copy delete item in visual)
    "     " See: v_P and v_p
    "     let g:yankring_paste_v_akey = 'P'   " uppercase
    "     let g:yankring_paste_v_bkey = 'p'   " lowercase
    "     " function! YRRunAfterMaps()
    "     "     vnoremap p  <C-U>YRPaste 'P', 'v'<CR>
    "     "     vnoremap P  <C-U>YRPaste 'p', 'v'<CR>
    "     " endfunction


    "     let g:yankring_replace_n_pkey = ''
    "     let yankring_min_element_length = 2
    "     let g:yankring_paste_using_g = 0
    Plug 'junegunn/vim-peekaboo'
    Plug 'ojroques/vim-oscyank', {'branch': 'main'}
        vmap <leader>c <Plug>OSCYankVisual
    " Plug 'dylanaraps/fff.vim'
    "     nnoremap f :F<CR>
    " Plug 'preservim/nerdtree'
    "     nnoremap <leader>n :NERDTreeFocus<CR>
    " if (v:version >= 901)
    "     Plug 'girishji/vimsuggest'
    " endif

    Plug 'inkarkat/vim-ingo-library'
    Plug 'inkarkat/vim-mark'
        let g:mw_no_mappings = 1
        let g:mwAutoLoadMarks = 1
        nmap <Leader>mt <Plug>MarkToggle
        nmap <Leader>M <Plug>MarkToggle
        xmap <Leader>m <Plug>MarkSet
        nmap n <Plug>MarkSearchAnyOrDefaultNext
        nmap N <Plug>MarkSearchAnyOrDefaultPrev
        nmap <Leader>m <Plug>MarkSet

    " NOTICE: THIS will casue termdebug report error
    " TODO: fix it
    Plug 'PEMessage/vim-strip-trailing-whitespace'


" -------------------------------------------
" 6.2 Textobj
" -------------------------------------------

if PSelect('textobj')
    Plug 'kana/vim-submode'
        let g:submode_timeout = 0
        " let g:submode_keep_leaving_key = 0
        let g:submode_always_show_submode = 1
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    Plug 'saihoooooooo/vim-textobj-space'
    Plug 'kana/vim-textobj-syntax'
    Plug 'rhysd/vim-textobj-anyblock'
    Plug 'kana/vim-textobj-line'
    Plug 'thinca/vim-textobj-between'
    Plug 'skywind3000/vim-textobj-parameter'
        Plug 'kana/vim-textobj-function'
        Plug 'bps/vim-textobj-python'
    Plug 'PEMessage/vim-text-process'
        let g:textproc_inline_script = {
            \'format_json': 'python3 -m json.tool',
            \'format_c': 'clang-format -style="{IndentWidth: 4, AccessModifierOffset: 0, IndentAccessModifiers: true}"',
            \'format_py': 'python3 -m autopep8 -',
            \'spliter_before': 'bash -c ''sed "s@^$1@===================\n@g"'' -- ',
            \'md_cleancode': 'perl -e ''my $var = do { local $/; <> }; ; $var =~ s/```[^`]*```/```\n```/g  ; print $var''',
            \'change_attri': 'bash -c ''sed -E "/<project/ {s@$1=\"(\S*)\"@$1=\"$2\"@g}"'' -- ',
            \'sort_inline': 'bash -c ''tr "$1" "\n" | sort | join_line "$1" '' -- ',
            \}
        " if exists('g:ovr_textproc_inline_script')
        "     extend(g:textproc_inline_script, g:ovr_textproc_inline_script)
        " endif

        " Test: example
        " let g:textproc_inline_script['jq'] = 'jq'
        " let g:textproc_inline_script['z_bashtest'] = 'bash -c "echo 123"'

    Plug 'terryma/vim-expand-region'
        let g:expand_region_text_objects = {
              \ 'iw'  :0,
              \ 'iy'  :0,
              \ 'iW'  :0,
              \ 'i"'  :0,
              \ 'a"'  :0,
              \ 'i''' :0,
              \ 'a''' :0,
              \ 'i]'  :0,
              \ 'a]'  :0,
              \ 'i)'  :0,
              \ 'a)'  :0,
              \ 'i}'  :1,
              \ 'a}'  :1,
              \ 'iB'  :0,
              \ 'il'  :0,
              \ 'iF'  :0,
              \ }
        map <CR> <Plug>(expand_region_expand)
        map <BS> <Plug>(expand_region_shrink)

          " \ 'iJ'  :0, " origin order is just under iw

                " \ 'i"'  :1,
                " \ 'i''' :1,
                " \ 'i]'  :1,
                " \ 'iB'  :1,
          " \ 'ib'  :0,
          " \ 'ab'  :0,
          " \ 'ii'  :0,
          " \ 'ai'  :0,
endif


" -------------------------------------------
" 6.3.1 Style PlugIn -- colorscheme
" -------------------------------------------
if PSelect('colorscheme')
    Plug 'joshdick/onedark.vim'
    " let g:onedark_color_overrides = {
    "             \ "QuickFixLine": {"gui": "#2F343F", "cterm": "235", "cterm16": "0" },
    "             \}
    " Strongly recommended: easy configuration of maktaba plugins.
    " Plug 'google/vim-maktaba'
    " Plug 'google/vim-glaive'
    " Plug 'google/vim-syncopate'

    if (has("autocmd"))
        " +---------------------------------------------+
        " |  Color Name  |         RGB        |   Hex   |
        " |--------------+--------------------+---------|
        " | Black        | rgb(40, 44, 52)    | #282c34 |
        " |--------------+--------------------+---------|
        " | White        | rgb(171, 178, 191) | #abb2bf |
        " |--------------+--------------------+---------|
        " | Light Red    | rgb(224, 108, 117) | #e06c75 |
        " |--------------+--------------------+---------|
        " | Dark Red     | rgb(190, 80, 70)   | #be5046 |
        " |--------------+--------------------+---------|
        " | Green        | rgb(152, 195, 121) | #98c379 |
        " |--------------+--------------------+---------|
        " | Light Yellow | rgb(229, 192, 123) | #e5c07b |
        " |--------------+--------------------+---------|
        " | Dark Yellow  | rgb(209, 154, 102) | #d19a66 |
        " |--------------+--------------------+---------|
        " | Blue         | rgb(97, 175, 239)  | #61afef |
        " |--------------+--------------------+---------|
        " | Magenta      | rgb(198, 120, 221) | #c678dd |
        " |--------------+--------------------+---------|
        " | Cyan         | rgb(86, 182, 194)  | #56b6c2 |
        " |--------------+--------------------+---------|
        " | Gutter Grey  | rgb(76, 82, 99)    | #4b5263 |
        " |--------------+--------------------+---------|
        " | Comment Grey | rgb(92, 99, 112)   | #5c6370 |
        " +---------------------------------------------+
        augroup colorextend
            autocmd!
            " Override the `Identifier` background color in GUI mode
            autocmd ColorScheme onedark call onedark#extend_highlight("Search", { "gui" : "underline,bold,italic,standout",  "bg": { "gui": "#444959" } , "fg" : {"gui":"#ffde87" }})
            autocmd ColorScheme onedark call onedark#extend_highlight("IncSearch", { "gui" : "underline,bold,italic,standout",  "bg": { "gui": "#ffde87" } , "fg" : {"gui":"#444959" }})
            autocmd ColorScheme onedark call onedark#extend_highlight("QuickFixLine", { "gui" : "underline",  "bg": { "gui": "NONE" } , "fg" : {"gui":"yellow" }})
            autocmd ColorScheme onedark highlight QuickFixLineScope gui=underline guifg=#e5c07b guibg=#444959

        augroup END

    Plug 'itchyny/vim-cursorword'
    Plug 'Yggdroot/indentLine'
        let g:indentLine_fileTypeExclude = ['man']
        " Do not change concealcursor
        let g:indentLine_concealcursor='in'
        let g:indentLine_conceallevel=1
    endif
endif

" -------------------------------------------
" 6.3.2 Style PlugIn -- starify
" -------------------------------------------
if PSelect('starify')
    Plug 'mhinz/vim-startify'
        nnoremap <leader>st :tab new<CR>:Startify<CR>
        " Most Recent File MRF
        nnoremap <leader>sb :Startify<CR>
        " Most Recent File MRF
        let g:startify_session_dir = pe_cache_dir . "/session"
        " Plug 'ap/vim-buftabline'
        let g:startify_enable_unsafe = 1
        let g:startify_files_number = 8
        let g:startify_change_to_dir = 0 " do not auto change dir
endif

" -------------------------------------------
" 6.3.3 Style PlugIn -- extrastyle
" -------------------------------------------
if PSelect('extrastyle')
    Plug 'itchyny/lightline.vim'
    " Plug 'google/vim-searchindex' , Cond( stridx(&shortmess, 'S')  != -1)
    " let g:searchindex_enabled = stridx(&shortmess, 'S') != -1  || has('patch-8.1.1270') != 1
    Plug 'google/vim-searchindex'
    Plug 'embear/vim-localvimrc'
        let g:localvimrc_sandbox = 0
        let g:localvimrc_ask = 1
        let g:localvimrc_persistent = 2 " Store and restore all decisions
        let g:localvimrc_event  = [ 'VimEnter' ]
        if has('unix')
            let g:localvimrc_persistence_file = pe_cache_dir . '/localvimrc_persistent'
        endif

    Plug 'edkolev/tmuxline.vim' , { 'on' : [ 'TmuxlineSnapshot', 'Tmuxline' ] }

endif


" -------------------------------------------
" 6.3.4 Style PlugIn -- highlight
" -------------------------------------------
if PSelect('highlight')
    " Plug 'ARM9/arm-syntax-vim'
        " autocmd BufNewFile,BufRead *.s,*.S set filetype=arm " arm = armv6/7
    Plug 'rubberduck203/aosp-vim'
        autocmd BufNewFile,BufRead *.bp set filetype=json " arm = armv6/7
    " Plug 'fedorenchik/fasm.vim' " in Vim9, we have it as builtin
        autocmd BufNewFile,BufRead *.fasm set filetype=fasm
        " See quickrun-exec-format
    " Plug 'sheerun/vim-polyglot'
    Plug 'mtdl9/vim-log-highlighting'
    Plug 'udalov/kotlin-vim'
    if has('patch-8.2.4980')
        Plug 'bfrg/vim-cmake-help'
        autocmd FileType cmake nnoremap <buffer> K :CMakeHelpPopup <C-R><C-W><CR>
    endif
    " Plug 'gburca/vim-logcat'
    Plug 'chrisbra/Colorizer' , { 'on': 'ColorToggle' }
    Plug 'powerman/vim-plugin-AnsiEsc' , { 'on': 'AnsiEsc' }
        let g:no_cecutil_maps = 1

    " vi 1976
    " | \      more 1978
    " |  \     /
    " |   \   /
    " |     v
    " |   less 1983
    " v
    " vim 1991
    " Plug 'rkitover/vimpager'
    " File Manager


    " Plug 'kvngvikram/rightclick-macros'
    " Plug 'skywind3000/vim-quickui'
    augroup rainbow_auto
        autocmd!
        autocmd FileType make syn clear makeDefine
        " autocmd FileType make syn clear makeCommands
    augroup END

    Plug 'luochen1990/rainbow'
        let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
        let g:cursorword_delay = 600
        	let g:rainbow_conf = {
            \	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
            \	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
            \	'operators': '_,_',
            \	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
            \	'separately': {
            \		'*': 0,
            \		'vim': 0,
            \		'make': {
            \			'parentheses': ['start=/$\+(/ end=/)/', 'start=/\[/ end=/\]/'],
            \		},
            \		'nerdtree': 0,
            \	}
            \}
            " nnoremap <S-f1> :echo synIDattr(synID(line('.'), col('.'), 0), 'name')<cr>
            " nnoremap <S-f2> :echo ("hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            "             \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            "             \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">")<cr>
            " nnoremap <S-f3> :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<cr>
            nnoremap <S-f1> :exec 'syn list '.synIDattr(synID(line('.'), col('.'), 0), 'name')<cr>

    " Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
    " Plug 'liuchengxu/vim-which-key'
        " let g:mapleader = "\\"
        " let g:which_key_exit = ["\<Esc>", "\<C-[>", "\<C-c>"]
        " nnoremap <silent> <leader>      :<c-u>WhichKey '\'<CR>
    " Plug 'junegunn/rainbow_parentheses.vim'
endif

" -------------------------------------------
" 6.4 Locale
" -------------------------------------------
    Plug 'yianwillis/vimcdoc'
    Plug 'voldikss/vim-translator'
    " Plug 'brglng/vim-im-select'
    if has('win32')
        let g:im_select_default = '1033'
    endif

" -------------------------------------------
" 6.5 Tpope plugin
" -------------------------------------------
    " Plug 'junegunn/vim-easy-align'
    "     nmap ga <Plug>(EasyAlign)
    "     xmap ga <Plug>(EasyAlign)
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-eunuch'
    Plug 'preservim/nerdcommenter'
        let g:NERDSpaceDelims = 1
        let g:NERDCreateDefaultMappings = 0
        let g:NERDCompactSexyComs = 1
        " THANKS: https://github.com/sisrfeng/cfg_nvim/blob/09cc4926a0fef9291747a673b8c96eb9f03a5379/begin_PL_end.vim#L227
        let g:NERDCommentEmptyLines =  1 " Allow commenting and inverting empty lines (useful when commenting a region)
        let g:NERDTrimTrailingWhitespace =  1 " Enable trimming of trailing whitespace when uncommenting

        " THANKS: https://github.com/lmburns/dotfiles/blob/f7c1f3644337868afc7de8a547565242c409efb6/.vim/autoload/plugs/comment.vim#L12
        " nnoremap <silent>gcc :call nerdcommenter#Comment(0,"toggle")<CR>
        " xnoremap <silent><nowait> gc :call nerdcommenter#Comment(0, "Toggle")<CR>
        xnoremap <silent> gx :call nerdcommenter#Comment(0, "Sexy")<CR>
        nnoremap <leader>ca  :call nerdcommenter#SwitchToAlternativeDelimiters(1)<CR>
        let g:NERDCustomDelimiters = {
                    \ 'python': {'left': '#'},
                    \ 'lua':  {'left': '--', 'leftAlt': '', 'rightAlt': ''},
                    \ 'just': {'left': '#', 'leftAlt': '', 'rightAlt': ''}
                    \ }

    Plug 'vim-scripts/DoxygenToolkit.vim'
    " Using :verbose and :set together will (likely) tell you
    " the file and line number where the option was last set.
    " Can you do the following after opening a kotlin file?
    " verbose set commentstring?
        augroup VIMCOMMENT
            autocmd!
            autocmd FileType apache setlocal commentstring=#\ %s
            autocmd FileType python setlocal commentstring=#\ %s
            autocmd FileType cpp setlocal commentstring=//\ %s
            autocmd FileType c setlocal commentstring=//\ %s
        augroup END
    Plug 'tpope/vim-repeat'
        " Without this line, will map nmap <C-R> <Plug>(RepeatRedo) by default
        nmap <leader><C-R> <Plug>(RepeatRedo)
    Plug 'tpope/vim-fugitive'
        let g:fugitive_legacy_commands = 1
    " Plug 'tpope/vim-vinegar'
    Plug 'tpope/vim-rsi'
    Plug 'tpope/vim-sleuth' , { 'on': [ 'Sleuth' ] }
        command UnSleuth setlocal et sw=4 ts=4

" -------------------------------------------
" 6.6 Git plugin
" -------------------------------------------
    Plug 'airblade/vim-gitgutter'
        let g:gitgutter_map_keys = 0
        command! Gqf GitGutterQuickFix | copen
        nmap [c <Plug>(GitGutterPrevHunk)
        nmap ]c <Plug>(GitGutterNextHunk)
        nmap <leader>u :GitGutterUndoHunk<CR>
        nnoremap <expr> <leader>a &diff ? ':diffget<CR>' : ':GitGutterStageHunk<CR>'

    Plug 'will133/vim-dirdiff' , { 'on': [ 'DirDiff' ] }
        let g:DirDiffWindowSize = 7
    Plug 'samoshkin/vim-mergetool'
        let g:mergetool_layout = 'mr'
        let g:mergetool_prefer_revision = 'local'
        " :h copy-diffs
        " :'<,'>diffget  do(diff obtain)
        " :'<,'>diffput. dp(diff put)
    Plug 'PEMessage/vim-gf-user'
    Plug 'kana/vim-gf-diff'

    Plug 'HiPhish/info.vim'
    Plug 'cohama/agit.vim' , { 'on': [ 'Agit' ] }
        " J			    <Plug>(agit-scrolldown-stat)
        " K			    <Plug>(agit-scrollup-stat)
        " <C-j>			<Plug>(agit-scrolldown-diff)
        " <C-k>			<Plug>(agit-scrollup-diff)
        " u			    <PLug>(agit-reload)
        " yh			<Plug>(agit-yank-hash)
        " <C-g>			<Plug>(agit-print-commitmsg)
        " q			    <Plug>(agit-exit)
        " C			    <Plug>(agit-git-checkout)
        " cb			<Plug>(agit-git-checkout-b)
        " D			    <Plug>(agit-git-branch-d)
        " rs			<Plug>(agit-git-reset-soft)
        " rm			<Plug>(agit-git-reset)
        " rh			<Plug>(agit-git-reset-hard)
        " rb			<Plug>(agit-git-rebase)
        " ri			<Plug>(agit-git-rebase-i)
        " di			<Plug>(agit-diff)
        " dl			<Plug>(agit-diff-with-local)
        " nnoremap <leader>ag :Agit<CR>




" -------------------------------------------
" 6.7 Tmux and Terminal
" -------------------------------------------
    Plug 'NickLaMuro/vimux'
        " nmap <Leader>vl :VimuxRunLastCommand<CR>
        " nmap <Leader>vp :VimuxPromptCommand<CR>
        " nmap <Leader>vo :VimuxOpenRunner<CR>
    Plug 'gioele/vim-autoswap'
        let g:autoswap_detect_tmux = 1
    " Plug 'PEMessage/vim-fifoserver' ,  { 'on': [ 'FIFOStart' ] }
        " set title titlestring=
        " ALT + =: toggle terminal below.
        " ALT + SHIFT + h: move to the window on the left.
        " ALT + SHIFT + l: move to the window on the right.
        " ALT + SHIFT + j: move to the window below.
        " ALT + SHIFT + k: move to the window above.
        " ALT + SHIFT + n: move to the previous window.
        " ALT + -: paste register 0 to terminal.
        " ALT + q: switch to terminal normal mode.
        " Use drop to drop file to vim
        "
        " 另外从 vim 寄存器到 终端粘贴内容的操作因为 vim/nvim 不一样
        " vim 的终端粘贴是在终端 insert 模式下按 termkey + " + 寄存器 ，termkey 在这个脚本里是 <c-_>
    " Plug 'skywind3000/vim-terminal-help'
    "     tnoremap <C-[><C-[> <c-\><c-n>:bdelete! %<CR>
    "     let g:terminal_key = '<leader>='
        " let g:terminal_key = '<M-`>'
    if has('terminal')
        if (v:version > 800 || v:version == 800 && has("patch1647"))
            Plug 'chrisbra/vpager'
        endif
        Plug 'voldikss/vim-floaterm'
            if exists('&termwinkey')
                set termwinkey=<C-x>
            endif

            tnoremap <m-q> <c-\><c-n>
            tnoremap <M-S-x> <c-\><c-n>:wincmd c<CR>

            if has('textprop') && has('patch-8.2.0286')
                let g:floaterm_position = 'bottomright'
            else
                let g:floaterm_wintype = 'split'
                let g:floaterm_position = 'botright'
                let g:floaterm_height = 0.3
            endif

            function! TermKeyMap()
                nnoremap <buffer> <M-q> a
            endfunction

            function! FloatermKeyMap()
                " nnoremap <buffer> <m-q> i
                tnoremap <buffer><silent> <M-S-x> <c-\><c-n>:FloatermHide<CR>
            endfunction

            " See: https://github.com/jessepav/lacygoill-wiki-backup/blob/master/vim/autocmd.md?plain=1#L681
            " DEBUG: $ vim -Nu NONE +"autocmd TerminalOpen * echomsg 'buftype is: ' .. (&buftype == '' ? 'regular' : &buftype)"
            if exists("#TerminalOpen")
                autocmd TerminalOpen * call TermKeyMap()
            endif

            autocmd User FloatermOpen
                        \ call FloatermKeyMap()
                        \ | call TermKeyMap()
                        \ | if exists('&termwinkey')
                        \ | call setbufvar(bufnr('%'), '&termwinkey', '<c-x>')
                        \ | endif

            let g:floaterm_keymap_toggle = '<M-S-u>'
            let g:floaterm_opener = 'tabe'
    endif
    Plug 'christoomey/vim-tmux-navigator'
        let g:tmux_navigator_no_mappings = 1
        noremap  <silent><M-S-h> :TmuxNavigateLeft<cr>
        noremap  <silent><M-S-j> :TmuxNavigateDown<cr>
        noremap  <silent><M-S-k> :TmuxNavigateUp<cr>
        noremap  <silent><M-S-l> :TmuxNavigateRight<cr>


        inoremap  <silent><M-S-h> <C-o>:TmuxNavigateLeft<cr>
        inoremap  <silent><M-S-j> <C-o>:TmuxNavigateDown<cr>
        inoremap  <silent><M-S-k> <C-o>:TmuxNavigateUp<cr>
        inoremap  <silent><M-S-l> <C-o>:TmuxNavigateRight<cr>

        tnoremap  <silent><M-S-h> <cmd>TmuxNavigateLeft<cr>
        tnoremap  <silent><M-S-j> <cmd>TmuxNavigateDown<cr>
        tnoremap  <silent><M-S-k> <cmd>TmuxNavigateUp<cr>
        tnoremap  <silent><M-S-l> <cmd>TmuxNavigateRight<cr>

        cnoremap  <silent><M-S-h> <cmd>TmuxNavigateLeft<cr>
        cnoremap  <silent><M-S-j> <cmd>TmuxNavigateDown<cr>
        cnoremap  <silent><M-S-k> <cmd>TmuxNavigateUp<cr>
        cnoremap  <silent><M-S-l> <cmd>TmuxNavigateRight<cr>
        " Tmux Like
        nnoremap <silent><M-S-C> :vsplit<CR>
        nnoremap <silent><M-S-X> :confirm q<CR>

        nnoremap <silent><M-S-E> :tabn<CR>
        nnoremap <silent><M-S-W> :tab new<CR>
        nnoremap <silent><M-S-Q> :tabp<CR>

        command! -nargs=0 PEMouseON set mouse=a
        command! -nargs=0 PEMouseOFF set mouse=""

        " noremap  <C-h> :<C-U>TmuxNavigateLeft<cr>
        " noremap  <C-j> :<C-U>TmuxNavigateDown<cr>
        " noremap  <C-k> :<C-U>TmuxNavigateUp<cr>
        " noremap  <C-l> :<C-U>TmuxNavigateRight<cr>

" -------------------------------------------
" 6.8 Tag Plugin
" -------------------------------------------
    " GTAGS for jump
    " Changelog: compare to origin one
    "   1. Only add g:gutentags_gtags_extra_args for extra gtags flag
    " Debug:
    "   1. let g:gutentags_define_advanced_commands = 1 (already set)
    "   2. GutentagsToggleTrace
    "       Example update cmdline
    "       vim/plugged/vim-gutentags/plat/unix/update_gtags.sh -e gtags --incremental /abs/path/to/subcache
    "   3. :messages
    " Usage:
    "   1. GutentagsUpdate
    "   2. execute 'cs add ' .. b:gutentags_files['gtags_cscope']
    "   3. echo b:gutentags_root
    Plug 'PEMessage/vim-gutentags'
        " 1. Project Root option
        " ----------------------------------
            " Conflict with zzz .root mark
            " let g:gutentags_project_root = ['.root','.project']
            " Pls gen tag yourself to avoid any performance delay
            let g:gutentags_generate_on_new = 0
            let g:gutentags_generate_on_missing = 0
            let g:gutentags_generate_on_write = 0
            let g:gutentags_background_update = 0

            let g:gutentags_project_root = ['gtags']
            let g:gutentags_add_default_project_roots = 0
            let g:gutentags_add_ctrlp_root_markers = 0
            " Pls manully gen tags, using :GutentagsUpdate

        " 2. Cache dir
        " ----------------------------------
            " 所生成的数据文件的名称
            " let g:gutentags_ctags_tagfile = '.tags'
            " 同时开启 ctags 和 gtags 支持：
            let g:gutentags_modules = []
            if executable('ctags')
                " let g:gutentags_modules += [ 'ctags' ]
            endif
            if executable('gtags-cscope') && executable('gtags')
                let g:gutentags_modules += ['gtags_cscope']
            endif
            " 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
            let s:vim_tags = expand('~/.cache/tags')
            let g:gutentags_cache_dir = s:vim_tags
            if !isdirectory(s:vim_tags)
                silent! call mkdir(s:vim_tags, 'p')
            endif

        " 3. CTAGS/GTAGS Flags option
        " ----------------------------------
        " 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extra=+q，注意
            let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
            let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
            let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
            " 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
            let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
            " PEMessage branch only option
            let g:gutentags_gtags_extra_args = [ '--skip-unreadable' ]
            let g:gutentags_gtags_extra_args += [ '--skip-symlink' ]
            " 禁用 gutentags 自动加载 gtags 数据库的行为
            let g:gutentags_auto_add_gtags_cscope = 0
            let g:gutentags_auto_add_cscope = 0

        " 4. Debug extra command
        " ----------------------------------
            let g:gutentags_define_advanced_commands = 1
            let g:gutentags_debug = 1
        " See: https://stackoverflow.com/questions/3249275/multiple-commands-on-same-line
        " for <bar>
        command Csadd
                    \ execute 'set tags+=' . b:gutentags_files['ctags'] ',' <bar>
                    \ echo 'Add "' . b:gutentags_files['ctags'] . '" to tags'
        command Gsadd
                    \ execute 'cs add ' . b:gutentags_files['gtags_cscope'] <bar>
                    \ echo 'Add "' . b:gutentags_files['gtags_cscope'] . '" to cscsope db'
        " Gs"a"top a is for higher priority in wildmenu
        command Gsatop
                    \ echo 'Top is "' . b:gutentags_root . '"'
        command! CtagGen
            \ execute '!ctags  -R --output-format=e-ctags --fields=+niazS'
        set cscopetag
        set cscopeprg=gtags-cscope

        " 0 or s: Find this symbol
        " 1 or g: Find this definition
        " 2 or d: Find functions called by this function
        " 3 or c: Find functions calling this function
        " 4 or t: Find this text string
        " 6 or e: Find this egrep pattern
        " 7 or f: Find this file
        " 8 or i: Find files #including this file
        " 9 or a: Find places where this symbol is assigned a value
    " Changelog:
    "   only set cscopequickfix in native mode
    Plug 'PEMessage/gutentags_plus'
        let g:gutentags_plus_nomap = 1
        let g:gutentags_plus_height = 5
        let g:gutentags_plus_native = 0

        let g:which_key_map['g'] = {
                    \ 'name': '+gtag'
                    \}
        noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>
        " noremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>

        " search symbol under cursor
        " Caution: This will interface cgn, so dont use it
        " noremap <silent> gn         :GscopeFind g <C-R><C-W><cr>
        " search symbol under cursor, and preview
        noremap <silent> gy         :GscopeFind g <C-R><C-W><cr>:call QuickfixArrowPreview('j')<cr>
        " search symbol under cursor, and open
        noremap <silent> gh         :GscopeFind g <C-R><C-W><cr>:cnext<cr>
        " go back
        noremap <silent> gb         <C-o>

        noremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>
        noremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>

        noremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>
        noremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>

        noremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
        noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>

        noremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>

        " " Go Symbol
        " noremap <silent> gs :GscopeFind s <C-R><C-W><cr>
        " " Go Defintion
        " noremap <silent> gd :GscopeFind g <C-R><C-W><cr>

        " " Go Ref by this function
        " noremap <silent> gr :GscopeFind d <C-R><C-W><cr>
        " " Go Reference Being Called
        " noremap <silent> gk :GscopeFind c <C-R><C-W><cr>
        " " File
        " " noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
    " Plug 'preservim/tagbar'
    Plug 'liuchengxu/vista.vim' , { 'on': [ 'Vista' ] }
        let g:vista#renderer#enable_icon = 0
        let g:vista_echo_cursor_strategy = "scroll"
        " nnoremap <leader>at :TagbarToggle<CR>
        " nnoremap <leader>av :Vista!!<CR>
    Plug 'Shougo/vinarise.vim'

    " This will do "imap \ihs so !!! DONT USE IT !!!
    " Plug 'vim-scripts/a.vim'
    " Plug 'vim-scripts/taglist.vim'

    Plug 'skywind3000/asyncrun.vim'
    Plug 'thinca/vim-quickrun'
        let g:quickrun_config = {}
        " Thanks to:
        " https://github.com/koturn/vim-config/blob/29d0eb63f061427295fbe0591d2fe8cd7fb5225f/autoload/pluginconfig.vim#L22
        let g:quickrun_config['_'] = {
                    \   'runner': 'job',      
                    \   'outputter': 'error',
                    \   'outputter/error': 'quickfix',
                    \   'outputter/error/success': 'buffer',
                    \   'outputter/buffer/split': ':botright',
                    \   'outputter/buffer/close_on_empty': 1,
                    \   'hook/shebang/enable': !has('win32') && !has('win64')
                    \ }

        let g:quickrun_config['fasm'] = {
                    \     'command': 'fasm',
                    \     'exec': ['%c %s','chmod a+x %s:r', '%s:r'],
                    \     'tempfile': '%{tempname()}',
                    \ }
        nnoremap <leader>rr :QuickRun<CR>
        command! -nargs=* QGCC execute 'QuickRun q-gcc <args>'
        " $VIM_FILEPATH  - File name of current buffer with full path
        " $VIM_FILENAME  - File name of current buffer without path
        " $VIM_FILEDIR   - Full path of current buffer without the file name
        " $VIM_FILEEXT   - File extension of current buffer
        " $VIM_FILENOEXT - File name of current buffer without path and extension
        " $VIM_CWD       - Current directory
        " $VIM_RELDIR    - File path relativize to current directory
        " $VIM_RELNAME   - File name relativize to current directory
        " $VIM_ROOT      - Project root directory
        " $VIM_CWORD     - Current word under cursor
        " $VIM_CFILE     - Current filename under cursor
        " $VIM_GUI       - Is running under gui ?
        " $VIM_VERSION   - Value of v:version
        " $VIM_COLUMNS   - How many columns in vim's screen
        " $VIM_LINES     - How many lines in vim's screen
        " $VIM_SVRNAME   - Value of v:servername for +clientserver usage
        let g:asyncrun_open = 7
        " nnoremap <leader>ar :AsyncRun!
        " Compile current file
        " nnoremap <silent> <leader>aq1 :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
        " " Run it !
        " nnoremap <silent> <leader>aq2 :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
        " if has('win32') || has('win64')
        "     noremap <silent><leader>aqe :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>"
        "                 \ "\%CD\%\*.h" "\%CD\%\*.c*" <cr>
        " else
        "     noremap <silent><leader>aqe :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W>
        "                 \ --include='*.h' --include='*.c*' '<root>' <cr>
        " endif



" -------------------------------------------
" 6.9 Quickfix Plugin
" -------------------------------------------
    " Quickfix Config
    set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-,a-
    " override vim-expend-region keymap
    autocmd FileType qf nnoremap <buffer> <enter> <enter>zz

    " Basic keymap
    nnoremap ]q :copen<CR>:cnext<CR>
    nnoremap [q :copen<CR>:cprev<CR>

    " Quicktoggle
    function! ToggleQuickfix()
        if empty(filter(getwininfo(), 'v:val.quickfix'))
            botright copen
        else
            cclose
        endif
    endfunction
    command! Ctoggle call ToggleQuickfix()
    nnoremap <leader>cc  :call ToggleQuickfix()<CR>
    nnoremap <silent> <M-S-T> :call ToggleQuickfix()<CR>

    " Move cursor in quickfix preview
    function! QuickfixArrowPreview(direction)
        " Check if quickfix window is open
        let winnow = winnr()
        let winnr = winnr('$')
        let i = 1
        while i <= winnr
            if getwinvar(i, '&buftype') == 'quickfix'
                " Quickfix window is open, so just move the cursor to it
                execute i . 'wincmd w'
                execute 'normal ' . a:direction
                execute 'match QuickFixLineScope /\%'.line('.').'l/'
                execute 'PreviewQuickfix'
                execute winnow . 'wincmd w'
                return
            endif
            let i += 1
        endwhile
        copen   " Quickfix window is not open, so open it
    endfunction
    " Open a file, and jump back to quickfix
    autocmd FileType qf nnoremap <buffer> <space> <enter>zz
                \:execute 'match QuickFixLineScope /\%'.line('.').'l/'<CR>
                \:copen<CR>zz
    " Call the function! to setup the autocmd

    " Plug 'vim-scripts/cscope-quickfix'
    Plug 'skywind3000/vim-preview'
        autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
        autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>
        autocmd FileType qf nnoremap <silent><buffer> <MiddleMouse> :PreviewQuickfix<cr>





    " Gtag quickfix keymap
        noremap <silent> go :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
        nnoremap <S-F12> :call QuickfixArrowPreview('j')<CR>
        nnoremap <S-F11> :call QuickfixArrowPreview('k')<CR>

" -------------------------------------------
" 6.10 Complete Engine (APC)
" -------------------------------------------
    " Auto Popup
    " Plug 'skywind3000/vim-auto-popmenu'
    " Plug 'skywind3000/vim-dict'
        " " enable this plugin for filetypes, '*' for all files.
        " let g:apc_enable_ft = {'*':1}
        " let g:apc_trigger = "\<c-x>\<c-n>"
        " let g:apc_cr_confirm = 1
        " set cpt=.,k,w,b
        " " source for dictionary, current or other loaded buffers, see ':help cpt'
        " " don't select the first item.
        " set completeopt=menu,menuone,noselect
        " " suppress annoy messages.
        " set shortmess+=c
        " filetype plugin on
        " if has("autocmd") && exists("+omnifunc")
        " autocmd Filetype *
        "         \	if &omnifunc == "" |
        "         \		setlocal omnifunc=syntaxcomplete#Complete |
        "         \	endif
        " endif

" -------------------------------------------
" 6.11 Complete Engine (All)
" -------------------------------------------
    " |1. 整行                                                 i_CTRL-X_CTRL-L
    " |2. 当前文件内的关键字                                   i_CTRL-X_CTRL-N
    " |3. 'dictionary' 的关键字                                i_CTRL-X_CTRL-K
    " |4. 'thesaurus' 的关键字，同义词风格                     i_CTRL-X_CTRL-T
    " |5. 当前文件及其头文件内的关键字                         i_CTRL-X_CTRL-I
    " |6. 标签                                                 i_CTRL-X_CTRL-]
    " |7. 文件名                                               i_CTRL-X_CTRL-F
    " |8. 定义或宏                                             i_CTRL-X_CTRL-D
    " |9. Vim 命令                                             i_CTRL-X_CTRL-V
    " |10. 用户定义的补全                                      i_CTRL-X_CTRL-U
    " |11. 全能 (omni) 补全                                    i_CTRL-X_CTRL-O
    " |12. 拼写建议                                            i_CTRL-X_s
    " |13. 'complete' 的关键字                                 i_CTRL-N i_CTRL-P
    set pumheight=5

    " if v:version >= 9000
    "     let g:pe_complete_sys = 'vim'
    " elseif v:version >= 802 && ! has('win32')
    "     let g:pe_complete_sys = 'easy'
    " if has('win32') && v:version >= 800
    "     let g:pe_complete_sys = 'async'
    if v:version >= 802
        let g:pe_complete_sys = 'async'
    elseif has('patch-7.4.775')
        " Good enought for buffer
        let g:pe_complete_sys = 'apt'
    else
        let g:pe_complete_sys = 'apt'
    endif
    " let g:pe_complete_sys = 'apt'


" -------------------------------------------
" 6.11.1 Complete Engine (async)
" -------------------------------------------

    " Buggy buffer
    Plug 'prabirshrestha/async.vim' , Cond(g:pe_complete_sys == 'async')
    Plug 'prabirshrestha/asyncomplete.vim' , Cond(g:pe_complete_sys == 'async')
    Plug 'prabirshrestha/asyncomplete-buffer.vim' , Cond(g:pe_complete_sys == 'async')

        Plug 'wellle/tmux-complete.vim' , Cond(g:pe_complete_sys == 'async')
            let g:tmuxcomplete#asyncomplete_source_options = {
            \ 'name':      'tmuxcomplete',
            \ 'whitelist': ['*'],
            \ 'priority': 10,
            \ 'config': {
            \     'splitmode':      'words',
            \     'filter_prefix':   1,
            \     'show_incomplete': 1,
            \     'sort_candidates': 0,
            \     'scrollback':      0,
            \     'truncate':        0
            \     }
            \ }
        Plug 'rafamadriz/friendly-snippets' , Cond(g:pe_complete_sys == 'async')
        Plug 'prabirshrestha/asyncomplete-file.vim' , Cond(g:pe_complete_sys == 'async')

    Plug 'prabirshrestha/asyncomplete-lsp.vim'
    if g:pe_complete_sys == 'async'
        let g:asyncomplete_auto_popup = 1

        function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
        endfunction

        imap <silent><expr> <TAB>
                    \ pumvisible() ? "\<C-n>" :
                    \ vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' :
                    \ <SID>check_back_space() ? "\<TAB>" :
                    \ asyncomplete#force_refresh()
        " inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
        imap  <silent><expr> <S-Tab>
                    \ pumvisible() ? "\<C-p>" :
                    \ vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' :
                    \ "\<C-h>"
        " See wildmenu CTRL-E  - 结束补全，回到选择匹配之前的状态
        inoremap <expr> <C-c>  pumvisible() ? "\<C-y>\<C-c>" : "\<C-c>"

        inoremap <expr> <cr>   pumvisible() ? asyncomplete#close_popup() : "\<cr>"
        " imap <c-space> <Plug>(asyncomplete_force_refresh)

        if has('patch-8.0.1494')
            Plug 'hrsh7th/vim-vsnip'
            Plug 'hrsh7th/vim-vsnip-integ'
        endif
    endif

" -------------------------------------------
" 6.11.2 Complete Engine (easy)
" -------------------------------------------
    " Disable due to casully eatting some keyhit
    " Plug 'jayli/vim-easycomplete', Cond(g:pe_complete_sys == 'easy')
    "     Plug 'SirVer/ultisnips' , Cond(g:pe_complete_sys == 'easy' && has('python3'))

    "     let g:easycomplete_nerd_font = 0
    "     " See: https://github.com/jayli/vim-easycomplete/issues/131
    "     let g:easycomplete_lsp_checking = 0
" -------------------------------------------
" 6.11.3 Complete Engine (*mu*)
" -------------------------------------------

    " See: ins-completion for origin complete help
    Plug 'lifepillar/vim-mucomplete' , Cond(g:pe_complete_sys == 'mu')
    Plug 'skywind3000/vim-dict' , Cond(g:pe_complete_sys == 'mu')

    " Plug 'PEMessage/T.vim' , { 'on' : ['Trans'] }
    Plug 'PEMessage/T.vim'
        vnoremap <leader>t :<c-u>Trans<cr>
        command! -n=0 Trans call T#VisualSearch(visualmode())
    " Plug 'Konfekt/complete-common-words.vim' , Cond(g:pe_complete_sys == 'mu')
    " let g:common_words_dicts_dir = g:plug_home .. 'complete-common-words.vim/dicts'
    " set dictionary+=spell

    " Plug 'garbas/vim-snipmate' , Cond(g:pe_complete_sys == 'mu')
    " Plug 'MarcWeber/vim-addon-mw-utils' , Cond(g:pe_complete_sys == 'mu')

    if g:pe_complete_sys == 'mu'
        " 6.11.3.1 General Setting
        " -------------------------------------------
        set completeopt+=menuone
        set completeopt+=noselect
        set completeopt+=noinsert

        " See: https://github.com/lifepillar/vim-mucomplete/issues/153
        " Mucomplete is automatically inserting completions without trigger
        " set completeopt+=longest

        set completeopt-=preview

        set shortmess+=c   " Shut off completion messages
        set belloff+=ctrlg " Add only if Vim beeps during completion
        set cpt=.,w,b,u,U

        " 6.11.3.2 Better dict complete setting(disable file path)
        " -------------------------------------------
        " Credit:
        " https://stackoverflow.com/questions/1830221/how-to-remove-file-name-from-vim-dictionary-menu
        function! PEDictGrep( leader, file )
            try
                exe "vimgrep /^" . a:leader . ".*/j " . a:file
            catch /.*/
                echo "no matches"
            endtry
        endfunction

        " Slight modified one
        function! PEDictComp( findstart, base )
            if a:findstart
                let line = getline('.')
                let start = col('.') - 1
                while start > 0 && line[start - 1] =~ '[A-Za-z_]'
                    let start -= 1
                endwhile
                return start
            else
                silent call PEDictGrep( a:base, &dictionary )
                let matches = []
                for thismatch in getqflist()
                    let obj = {
                                \ 'word': thismatch.text,
                                \ 'menu': '[dict]',
                                \}
                    call add(matches, obj )

                endfor
                return matches
            endif
        endfunction
        set completefunc=PEDictComp
        " General Setting
        " let g:mucomplete#chains = {
        "             \ 'default' : ['path','user','incl'],
        "             \ }

        " 6.11.3.3 Sub Setting for neosnippet
        " -------------------------------------------
        Plug 'Shougo/neosnippet.vim' , Cond(g:pe_complete_sys == 'mu')
        Plug 'Shougo/neosnippet-snippets' , Cond(g:pe_complete_sys == 'mu')
        Plug 'honza/vim-snippets' , Cond(g:pe_complete_sys == 'mu')
        let g:neosnippet#enable_snipmate_compatibility = 1
        let g:mucomplete#enable_auto_at_startup = 1
        " Do not use conceal marker(hide some visiable text)
        let g:neosnippet#enable_conceal_markers = 1
        let g:neosnippet#expand_word_boundary = 1
        inoremap <silent> <expr> <plug><MyCR>
                    \ mucomplete#neosnippet#expand_snippet("\<cr>")
        imap <cr> <plug><MyCR>
        let g:mucomplete#chains = {
                    \ 'default' : ['path','nsnp','user','tags','incl'],
                    \ }
        " In order to trigger InsertLeave autocmd
        " inoremap <C-c> <ESC>
        " autocmd InsertLeave * NeoSnippetClearMarkers
        " snoremap <silent><ESC>  <ESC>:NeoSnippetClearMarkers<CR>

        " Another usage
        if exists('##ModeChanged')
            autocmd ModeChanged * NeoSnippetClearMarkers
        else
            autocmd InsertLeave * NeoSnippetClearMarkers
            snoremap <silent><ESC>  <ESC>:NeoSnippetClearMarkers<CR>
        endif

    endif


                    " \ 'default' : ['nsnp'],


" -------------------------------------------
" 6.11.4 Complete Engine (apt)
" -------------------------------------------
"  se
    Plug 'skywind3000/vim-auto-popmenu' , Cond(g:pe_complete_sys == 'apt')
    if g:pe_complete_sys == 'apt'
        let g:apc_enable_ft = {'text':1, '*':1, 'vim':1}
        set cpt=.,k,w,b
        set completeopt=menu,menuone,noselect
        set shortmess+=c
    endif

" -------------------------------------------
" 6.12 debug adapter
" -------------------------------------------
    Plug 'puremourning/vimspector'
        let g:vimspector_enable_mappings = 'HUMAN'
    Plug 'PEMessage/termdebug_ex.vim'
        let g:termdebug_config = {}
        let g:termdebug_config['command'] = "gdb-multiarch"
        let g:termdebug_config['evaluate_in_popup'] = v:true
        let g:termdebug_config['map_plus'] = v:true
        let g:termdebug_config['map_mins'] = v:true
        let g:termdebug_config['variables_window'] = v:true
        let g:termdebug_config['timeout'] = 6000 " 1000 ~ 10s, for large elf like linux kernel

    Plug 'PEMessage/subcmd.vim'
" -------------------------------------------
" 6.13 LSP
" -------------------------------------------
    Plug 'prabirshrestha/vim-lsp'
        let g:lsp_diagnostics_virtual_text_enabled = 0 " this will cause display random empty line when cursor move
        let g:lsp_diagnostics_echo_cursor = 1
        if has('patch-9.0.0167')
            let g:lsp_inlay_hints_enabled = 1
            " same as Comment
            highlight default link lspInlayHintsParameter  Comment
            highlight default link lspInlayHintsType  lspInlayHintsParameter
        endif

        " Thanks: https://github.com/prabirshrestha/vim-lsp/issues/1312#issuecomment-1125822917
        let g:lsp_diagnostics_enabled = 1 " turn on diagnostics by default
        let g:my_lsp_diagnostics_enabled = 1
        function s:LSPDiagnosticsToggle()
            if g:my_lsp_diagnostics_enabled == 1
                call lsp#disable_diagnostics_for_buffer()
                let g:my_lsp_diagnostics_enabled = 0
                echo "LSP Diagnostics : off"
            else
                call lsp#enable_diagnostics_for_buffer()
                let g:my_lsp_diagnostics_enabled = 1
                echo "LSP Diagnostics : on"
            endif
        endfunction

        command LSPDiagnosticsToggle call s:LSPDiagnosticsToggle()
        nnoremap `d :LSPDiagnosticsToggle<CR>

    Plug 'jiz4oh/vim-lspfuzzy'
    Plug 'mattn/vim-lsp-settings'
    Plug 'rhysd/vim-healthcheck'
    " Uncomment this to debug lsp.
    "   java: For jdtls, we must openjdk21
    "   java: jdtls must match gradle project verion,
    "         change vim-lsp-settings/installer/install-eclipse-jdt-ls.sh
    "         jdk17: 1.43.0 (December 19th, 2024) , 1.44 Bump minimum required Java Execution Environment from 17 to 21. See #3358, #3363.
    "  Also see: https://github.com/redhat-developer/vscode-java/wiki/JDK-Requirements#java.configuration.runtimes
    "
    "  Recommand way:
    "      using latest jdk for jdtls, and setup project jdk by
    "      File: gradle.properties
    "      org.gradle.java.home=/usr/lib/jvm/java-1.17.0-openjdk-amd64

    if $PE_DEBUG_LSP == '1'
        let g:lsp_log_verbose = 1
        let g:lsp_log_file = expand('~/vim-lsp.log')
    endif
    Plug 'hsanson/vim-android'
        " using GradleGenClassPathFile to gen .classpath
        " make sure that you could built it successfully
    let g:lsp_settings = {}
    let g:lsp_settings['pylsp'] = {
                \     'workspace_config': {
                \       'pylsp': {
                \         'configurationSources': ['flake8'],
                \         'plugins': {
                \           'autopep8': {'enabled': v:true},
                \           'yapf': {'enabled': v:false},
                \           'pycodestyle': {'indent_size': 4},
                \         }
                \       }
                \     }
                \   }
    " See: https://github.com/iamcco/vim-language-server/issues/39#issuecomment-1677120809
    " Add support to jump to runtimefiles
    let g:lsp_settings['vim-language-server'] = { 
                \   'disabled': 1,
                \   'initialization_options': {
                \     'indexes': {
                \       "runtimepath": v:true,
                \       "time": 100,
                \       "count": 3,
                \     },
                \     'suggest': {
                \       "fromVimruntime": v:true,
                \       "fromRuntimepath": v:true,
                \     },
                \   }
                \ } 
    " let g:lsp_settings['eclipse-jdt-ls'] = {
    "             \ 'root_uri_patterns'  : ['.root'],
    "             \}
    " let g:lsp_settings['clangd'] = {
    "             \ 'args': ['123']
    "             \ }
    Plug 'PEMessage/jorenar-lsp-calltree'
" -------------------------------------------
" Start of plug
" -------------------------------------------
    call plug#end()
endif

" 7. VIM Plug-in Zone (Part2)
" ===========================================
" -------------------------------------------
" 7.1 Style
" -------------------------------------------
if PSelect('colorscheme') && !empty(globpath(&rtp, 'colors/onedark.vim'))
    colorscheme onedark
else
    colorscheme desert
endif
" -------------------------------------------
" 7.2 Async complete
" -------------------------------------------
if exists('*asyncomplete#register_source')
    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
                \ 'name': 'buffer',
                \ 'allowlist': ['*'],
                \ 'blocklist': ['go'],
                \ 'completor': function('asyncomplete#sources#buffer#completor'),
                \ 'config': {
                \    'max_buffer_size': 5000000,
                \  },
                \ }))
    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
                \ 'name': 'file',
                \ 'allowlist': ['*'],
                \ 'priority': 10,
                \ 'completor': function('asyncomplete#sources#file#completor')
                \ }))
endif

" if g:using_plugin_scope == 1
"     call scope#popup#OptionsSet({
"                 \ 'maxheight': 30,
"                 \ 'emacsKeys': v:true,
"                 \ })
" endif

" -------------------------------------------
" 7.3 Expand region
" -------------------------------------------
if PSelect('textobj')
    " call expand_region#custom_text_objects()
    " call expand_region#custom_text_objects('java', {
    "             \ 'iF' :0,
    "             \ })
    " call expand_region#custom_text_objects('c', {
    "             \ 'iF' :0,
    "             \ })
    " call expand_region#custom_text_objects('python', {
    "             \ 'if' :0,
    "             \ })
	call textobj#user#plugin('equal', {
	\   'angle': {
    \     'pattern': ['=', '.'],
	\     'select-a': 'a=',
	\     'select-i': 'i=',
	\   },
	\ })

    " call textobj#user#plugin('datetime', {
    " \   'date': {
    " \     'pattern': '\<\d\d\d\d-\d\d-\d\d\>',
    " \     'select': ['ad', 'id'],
    " \   },
    " \   'time': {
    " \     'pattern': '\<\d\d:\d\d:\d\d\>',
    " \     'select': ['at', 'it'],
    " \   },
    " \ })
    "test 1234-12-34

    " call textobj#user#plugin('jiraid', {
    " \   'jiraid-tag': {
    " \     'pattern': '[A-Z]\+-[0-9]\{1,4\}',
    " \     'select': ['aJ', 'iJ'],
    " \     'scan': 'cursor',
    " \   }
    " \ })
    " Test: aaJIRA-1234aa


    call expand_region#custom_text_objects('java', {
                \ 'iF' :0,
                \ })
endif
" -------------------------------------------
" 7.4 Submode Map
" -------------------------------------------

    " call submode#enter_with('viewcode', 'n', '', 'gh', 'zz')
    " call submode#leave_with('viewcode', 'n', '', '<Esc>')
    " call submode#leave_with('viewcode', 'n', '', '<C-c>')
    " call submode#map('viewcode', 'n', '', 'y', ':GscopeFind g <C-R><C-W><cr>:call QuickfixArrowPreview("j")<cr>')
    " call submode#map('viewcode', 'n', '', 'g', ':GscopeFind g <C-R><C-W><cr>:cnext<cr>')
    " call submode#map('viewcode', 'n', '', 'v', '<C-o>')

    " " Go through every letter
    " for key in ['a','b','c','d','e','f','g','h','i','j','k','l','m',
    " \           'n','o','p','q','r','s','t','u','v','w','x','y','z']
    "   " maps lowercase, uppercase and <C-key>
    "   call submode#map('viewcode', 'n', '', key,  key)
    "   call submode#map('viewcode', 'n', '', toupper(key), toupper(key))
    "   call submode#map('viewcode', 'n', '', '<C-' . key . '>',  '<C-'.key . '>')
    " endfor
    " for key in ['=','_','+','-','<','>']
    "     call submode#map('window', 'n', '', key,  key)
    " endfor



" -------------------------------------------
" 7.5 Quick UI
" -------------------------------------------
    " Quick UI Register
    " let g:quickui_color_scheme = 'system'
    "  " 安装一个 File 目录，使用 [名称，命令] 的格式表示各个选项。
    "  call quickui#menu#install('&File', [
    "              \ [ "&New File\tCtrl+n", 'echo 0' ],
    "              \ [ "&Open File\t(F3)", 'echo 1' ],
    "              \ [ "&Close", 'echo 2' ],
    "              \ [ "--", '' ],
    "              \ [ "&Save\tCtrl+s", 'echo 3'],
    "              \ [ "Save &As", 'echo 4' ],
    "              \ [ "Save All", 'echo 5' ],
    "              \ [ "--", '' ],
    "              \ [ "E&xit\tAlt+x", 'echo 6' ],
    "              \ ])

    "  " 每个项目还可以多包含一个字段，表示它的帮助文档，光标过去时会被显示到最下方的命令行
    "  call quickui#menu#install('&Edit', [
    "              \ [ '&Copy', 'echo 1', 'help 1' ],
    "              \ [ '&Paste', 'echo 2', 'help 2' ],
    "              \ [ '&Find', 'echo 3', 'help 3' ],
    "              \ ])

    "  " 在 %{...} 内的脚本会被求值并展开成字符串
    "  call quickui#menu#install("&Option", [
    "              \ ['Set &Spell %{&spell? "Off":"On"}', 'set spell!'],
    "              \ ['Set &Cursor Line %{&cursorline? "Off":"On"}', 'set cursorline!'],
    "              \ ['Set &Paste %{&paste? "Off":"On"}', 'set paste!'],
    "              \ ])


    "  function! PECheetMessage()
    "      let content =[  "======================="
    "                  \ , " Basic Usage"
    "                  \ , "   Normal: <C-R> <-> u "
    "                  \ , "   Normal: y\"[reg] copy to reg "
    "                  \ , "   Visual: vi<range> r <space>"
    "                  \ , "   Terminal: <C-\\><C-N> back to Terminal-Normal"
    "                  \ , "======================="
    "                  \ , " EasyAlign"
    "                  \ , "   <C-X> Interactive Mode "
    "                  \ , "   :LiveEasyAlign live Mode"
    "                  \ , "   `2=` Around the 2nd Occurrences "
    "                  \ , "   `*=` Around all Occurrences"
    "                  \ , "======================="  ]
    "      let opts = {"close":"button", "title":"My CheetSheet"}
    "      call quickui#textbox#open(content, opts)
    "  endfunc

    "  " install 命令最后可以加一个 “权重”系数，用于决定目录位置，权重越大越靠右，越小越靠左
    "  call quickui#menu#install('H&elp', [
    "              \ ["&PE_CheetThing", ':call PECheetMessage()', 'Leader+U' ],
    "              \ ["&Cheatsheet", 'help index', ''],
    "              \ ['T&ips', 'help tips', ''],
    "              \ ['--',''],
    "              \ ["&Tutorial", 'help tutor', ''],
    "              \ ['&Quick Reference', 'help quickref', ''],
    "              \ ['&Summary', 'help summary', ''],
    "              \ ], 10000)
    "  nnoremap leaderh :call PECheetMessage()<CR>

    "  " 打开下面选项，允许在 vim 的下面命令行部分显示帮助信息
    "  let g:quickui_show_tip = 1

    "  " 定义按两次空格就打开上面的目录
    "  noremap <space>m :call quickui#menu#open()<cr>
    "  noremap <space>a :call quickui#tools#list_buffer('e')<cr>
    "

    " let n_rightmouse_content = [
    "             \ ["Paste", "exec 'normal" . '"' . "+p'" ],
    "             \ ['-'],
    "             \ ["Find File(Tags)", 'exec "normal gi"' ],
    "             \ ]

    " " set cursor to the last position
    " let n_rightmouse_opts = {'index':g:quickui#context#cursor}
    " nnoremap <RightMouse> :call quickui#context#open(n_rightmouse_content, n_rightmouse_opts)<CR>

" -------------------------------------------
" 7.6 local vimrc load
" -------------------------------------------

" -------------------------------------------
" 7.7 vim-lsp
" -------------------------------------------
    if executable('ccls')
	    au User lsp_setup call lsp#register_server({
		\ 'name': 'ccls',
		\ 'cmd': {server_info->['ccls']},
		\ 'root_uri':{server_info->lsp#utils#path_to_uri(
		\	lsp#utils#find_nearest_parent_file_directory(
		\		lsp#utils#get_buffer_path(),
		\		['.ccls', 'compile_commands.json', '.git/']
		\	))},
		\ 'initialization_options': {},
		\ 'allowlist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
		\ })
    endif
    function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        setlocal signcolumn=yes
        if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
        nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> <C-w>gd :rightbelow vertical LspDefinition<CR>

        nmap <buffer> gs <plug>(lsp-document-symbol-search)
        nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
        nmap <buffer> gr <plug>(lsp-references)
        nmap <buffer> gi <plug>(lsp-implementation)
        nmap <buffer> gt <plug>(lsp-type-definition)
        nmap <buffer> <leader>rn <plug>(lsp-rename)
        nmap <buffer> [d <plug>(lsp-previous-diagnostic)
        nmap <buffer> ]d <plug>(lsp-next-diagnostic)
        nmap <buffer> K <plug>(lsp-hover)

        " THANKS:
        " https://github.com/h-wata/dotfiles/blob/fdb2ff699d840e67517039ea1db590c2c18c723b/dot_vim/_config/lsp.vim
        nmap <buffer> <leader>F <plug>(lsp-document-format)
        xmap <buffer> <leader>F <plug>(lsp-document-range-format)

        " Extra Map
        nmap <buffer> <leader>lt :LspTypeHierarchy<CR>
        nmap <buffer> <leader>li :LspCallHierarchyIncoming<CR>
        nmap <buffer> <leader>lo :LspCallHierarchyOutgoing<CR>
        nmap <buffer> <M-h> :LspDocumentSwitchSourceHeader<CR>
        nnoremap <buffer> <leader>q :LspCodeAction --ui=float<CR>
        " nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
        " nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

        let g:lsp_format_sync_timeout = 1000
        autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

        " refer to doc to add more commands
    endfunction

    augroup lsp_install
        au!
        " call s:on_lsp_buffer_enabled only for languages that has the server registered.
        autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END



" 8 Self Function Zone
" ===========================================
    let s:exitKeyList = [ 'q', "\<ESC>" ]
    let s:delKeyList  = [ 'x', 'd' ]
    let s:pairKeyList = [
    \ '(', ')' ,
    \ '<', '>' ,
    \ '{', '}' ,
    \ '`', '`' ,
    \ '[', ']'
    \ ]
    " Stay in c-w prefix
    function! PEWinMode()
        echo "VIM Windows Mode"
        while(1)
            let follow = nr2char(getchar())
            if index( s:exitKeyList , follow ) >= 0
                echo "Mode End"
                return
            endif
            exec "normal \<c-w>" . follow
            redraw
        endwhile
    endfunction
    command! PEWinMode :call PEWinMode()
    nnoremap <silent><leader>wm :PEWinMode<CR>
    " nnoremap <silent><C-w> :PEWinMode<CR>

    " TimeStamp in english or locale language
    function! PEDate(lang)
        if a:lang == "en"
            let l:temp_lc_time = v:lc_time
            exec "normal :language time en_US.UTF-8\<CR>"
            exec "normal a \<C-R>=" . 'strftime("%Y-%m-%d %a %I:%M %p")' . "\<CR>\<Esc>"
        endif

        if a:lang == "zh"
            exec "normal a \<C-R>=" . 'strftime("%Y-%m-%d %a %I:%M %p")' . "\<CR>\<Esc>"
        endif
    endfunction


    command! PEDate :call PEDate("en")
    " Surround Visual Zone
    function! PESurroundVisualZone()
        echo "VIM Surround"
        let follow = nr2char(getchar())
        if index( s:exitKeyList , follow ) >= 0
            echo "End Mode"
            return
        endif
        if index( s:delKeyList , follow ) >= 0
            exec "normal `<hx"
            exec "normal `>x"
            return
        endif

        let pairIndex = index( s:pairKeyList , follow )
        if pairIndex >= 0
            if ( pairIndex % 2 ) == 0
                let leftpair = s:pairKeyList[ pairIndex ]
                let rightpair  = s:pairKeyList[ pairIndex+1 ]
            else
                let rightpair  = s:pairKeyList[ pairIndex ]
                let leftpair = s:pairKeyList[ pairIndex-1 ]
            endif
            exec "normal `<i" .leftpair ."\<esc>"
            exec "normal `>la".rightpair."\<esc>"
            return
        endif

        exec "normal `<i" .follow . "\<esc>"
        exec "normal `>la".follow . "\<esc>"
    endfunction
    noremap <silent><leader>sr :call PESurroundVisualZone()<CR>

    " function! PEToggleReadonly()
    "     set readonly!
    "     set modifiable
    " endfunction
    " fun! TrimWhitespace()
    "     let l:save = winsaveview()
    "     keeppatterns %s/\s\+$//e
    "     call winrestview(l:save)
    " endfun
    " autocmd BufWritePre * %s/\s\+$//e


    function! s:DiffWithSaved()
        let filetype=&ft
        diffthis
        vnew | r # | normal! 1Gdd
        diffthis
        exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
    endfunction
    com! DiffSaved call s:DiffWithSaved()

    function! s:DiffWithCVSCheckedOut()
        let filetype=&ft
        diffthis
        vnew | r !cvs up -pr BASE #
        1,6d
        diffthis
        exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
    endfunction
    com! DiffCVS call s:DiffWithCVSCheckedOut()

    if !exists(":DiffOrig")
        command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                    \ | wincmd p | diffthis
    endif

    " let g:lightline = {
    "             \ 'active': {
    "             \   'left': [ [ 'mode', 'paste' ],
    "             \             [ 'readonly', 'filename', 'modified' ] ],
    "             \   'right': [ [ 'lineinfo' ],
    "             \              [ 'percent' ],
    "             \              [ 'searchcount' ] ]
    "             \ },
    "             \ 'component_function': {
    "             \   'searchcount': 'SearchCount',
    "             \ },
    "         \ }

    function! SearchCount() abort
        let search_count = searchcount()
        if !empty(search_count)
            return '[' . search_count.current . '/' . search_count.total . ']'
        else
            return ''
        endif
    endfunction

    function! SearchIndex() abort
        let res = searchindex#MatchCounts()
        return '[' . res[0] . '/' . res[1] . ']'
    endfunction


" 9 Some others Function snippet
" ===========================================
    " copy to attached terminal using the yank(1) script:
    " Credit:
    " https://github.com/sunaku/home/blob/master/bin/yank
    function! Yank(text) abort
        let escape = system('yank', a:text)
    if v:shell_error
        echoerr escape
    else
        call writefile([escape], '/dev/tty', 'b')
    endif
    endfunction
    " using map rather then noremap to compatible with yankring
    map <silent> <Leader>y y:<C-U>call Yank(@0)<CR>
    xmap <silent> <space>  y:<C-U>call Yank(@0)<CR>

    " Credit:
    " https://stackoverflow.com/questions/13194428/is-better-way-to-zoom-windows-in-vim-than-zoomwin
    function! s:ZoomToggle() abort
        if exists('t:zoomed') && t:zoomed
            execute t:zoom_winrestcmd
            let t:zoomed = 0
        else
            let t:zoom_winrestcmd = winrestcmd()
            resize
            vertical resize
            let t:zoomed = 1
        endif
    endfunction
    command! ZoomToggle call s:ZoomToggle()
    nnoremap <silent> ZO :ZoomToggle<CR>
    nnoremap <silent> <M-S-z> :ZoomToggle<CR>


    " Credit: guitong.wu
    function! s:Duplication()
        let f = expand("%:p:h")."/"
        let filename = input("[Duplicant] Please input filename:".f )
        exe "w ".f.filename
        exe "hide edit ".f.filename

        echo filename
    endfunction
    command! Duplication call s:Duplication()

    " Credit: skywind3000
    function! Tapi_TerminalEdit(bid, arglist)
        let name = (type(a:arglist) == v:t_string)? a:arglist : a:arglist[0]
        let cmd = get(g:, 'terminal_edit', 'tab drop')
        silent exec 'FloatermHide'
        silent exec cmd . ' ' . fnameescape(name)
        silent exec 'FloatermShow'
        return ''
    endfunc

    function! Tapi_Api(bid, arglist)
        let cmd =  a:arglist[0]
        let args = a:arglist[1]
        silent exec cmd . ' ' . fnameescape(args)
        echo  cmd . ' ' . fnameescape(args)
        return ''
    endfunc

    function! Tapi_ApiV2(bid, arglist)
        if len(a:arglist) < 2
            echoerr 'Tapi_ApiHide: At least2 arg [action] [cmd] [args...]'
            return ''
        endif

        let action = a:arglist[0]
        let cmd = a:arglist[1]
        let args = join(a:arglist[2:], ' ')

        " Validate action
        if index(['hide', 'toggle', 'none'], action) == -1
            echoerr 'Tapi_ApiHide:Invalid action，must be hide|toggle|none'
            return ''
        endif

        " Execute FloatermHide for hide and toggle actions
        if action ==# 'hide' || action ==# 'toggle'
            silent exec 'FloatermHide'
        endif

        " Execute the command
        if !empty(cmd)
            let full_cmd = cmd . (empty(args) ? '' : ' ' . fnameescape(args))
            silent exec full_cmd
            echo full_cmd
        endif

        " Execute FloatermShow for toggle action
        if action ==# 'toggle'
            silent exec 'FloatermShow'
        endif

    endfunction

    function! s:Capture(bang, cmd)
        let message = execute(a:cmd)

        if a:bang
            new
            setlocal buftype=nofile bufhidden=hide noswapfile
        endif

        call append('.', split(message, '\r\?\n'))
        redraw!
    endfunction

    command! -bang -nargs=+ -complete=command Capture call <SID>Capture("<bang>" == '!', <q-args>)
    command! -nargs=+ -complete=command Redir let s:reg = @@ | redir @"> | silent execute <q-args> | redir END | tab new | pu | 1,2d_ | let @@ = s:reg


    " Credit: GPT
    function! DeletePattern(pattern)
        let @" = ''
        execute 'g/' . a:pattern . '/let @" .= getline(".") . "\n"'
        execute 'g/' . a:pattern . '/d _'
    endfunction
    command! DeletePattern call DeletePattern(@/)
    nnoremap dl :DeletePattern<CR>

    " Credit: GPT


    " function! FoldSearchPattern() abort
    "     if !exists('w:foldpatterns')
    "         let w:foldpatterns=[]
    "         setlocal foldmethod=expr foldlevel=0 foldcolumn=2
    "     endif
    "     if index(w:foldpatterns, @/) == -1
    "         call add(w:foldpatterns, @/)
    "         setlocal foldexpr=SetFolds(v:lnum)
    "     endif
    " endfunction

    " function! SetFolds(lnum) abort
    "     for pattern in w:foldpatterns
    "         if getline(a:lnum) =~ pattern
    "             if getline(a:lnum + 1) !~ pattern
    "                 return 's1'
    "             else
    "                 return 1
    "             endif
    "         endif
    "     endfor
    " endfunction

    " nnoremap \zf :call FoldSearchPattern()<CR>


    " Credit: GPT-4o-mini
    " Function to execute a command on the last matched pattern
    function! PatternCmd(...)
        " Get the last search pattern
        let l:pattern = @/

        " Check if the pattern is empty
        if empty(l:pattern)
            echo "No previous search pattern found."
            return
        endif

        " Extract the command from the arguments
        let l:cmd = join(a:000, ' ') " Join all arguments as the command

        " Execute the command on lines matching the pattern
        execute 'g/' . l:pattern . '/ ' . l:cmd
    endfunction

    " Command to call the function
    command! -nargs=+ -complete=command PatternCmd call PatternCmd(<f-args>)

    " call which_key#register('\', "g:which_key_map")

    function! LoopOption(option, choices, ...)
        " Get the current value of the option
        exe 'let current_value =' . a:option
        let choices_list = a:choices

        let index = index(choices_list, current_value) " Find the index of the current value in the choices
        " " Toggle the index to get the next option
        if index == -1
            let new_index = 0
        else
            let new_index = (index + 1) % len(choices_list)
        endif

        let new_value = choices_list[new_index]
        if type(new_value) == 1 " str
            let cmd = 'let ' . a:option . ' = ' . '''' . new_value . ''''
        elseif type(new_value) == 0 " number
            let cmd = 'let ' . a:option . ' = ' . new_value
        else
            echo "Unknow type"
            return
        endif
        echo  'Loop Option ' . (index + 1) .  ' of ' . len(a:choices) . ' by running: ' . cmd

        execute cmd

        if a:0 > 0
            execute a:1
        endif

    endfunction
    command! PEToggleGP call LoopOption('&gp', ['git grep -n', 'rg -n'])
    nnoremap <leader>gp :PEToggleGP<CR>

    command! PEToggleInlayHint call LoopOption('g:lsp_inlay_hints_enabled', [0, 1], 'silent edit %')
    command! LspInlayHintToggle execute 'PEToggleInlayHint'
    nnoremap <leader>ih :PEToggleInlayHint<CR>


    function! PEGrep(...)
        " Check if any arguments were provided
        if len(a:000) == 0
            " No arguments provided, prompt the user for input
            let pattern = input('Enter pattern(pwd is' . '"' . expand('%:p:h') . '"' . '): ' )
            if pattern == ''
                echo "No pattern entered. Aborting."
                return
            endif
        else
            " Join all provided arguments as the pattern
            let pattern = join(a:000, ' ')
        endif

        " Execute the grep command with the pattern
        silent execute 'grep! ' . pattern
        redraw!

        " Check if there are any entries in the quickfix list
        if len(getqflist()) > 0
            " Open the quickfix window if there are matches
            copen
        else
            echo "No matches found."
        endif
    endfunction

    " Create a command that takes one or more arguments
    command! -nargs=* PEGrep call PEGrep(<f-args>)

    function! InspectHighlight ()
        for i1 in synstack(line("."), col("."))
            let i2 = synIDtrans(i1)
            let n1 = synIDattr(i1, "name")
            let n2 = synIDattr(i2, "name")
            echo n1 "->" n2
        endfor
    endfunction
    command! InspectHighlight  call InspectHighlight()


    function! HighlightCurrentLineTemporarily()
        " Save the current highlight settings
        let s:old_cursorline = &cursorline
        let s:old_cursorlineopt = &cursorlineopt

        " Set highlight options
        set cursorline
        set cursorlineopt=both  " highlight both line number and text
        normal zz

        " Define highlight group (you can customize this)
        highlight TemporaryLineHighlight term=bold cterm=bold ctermbg=darkgray guibg=darkgray

        " Apply the highlight
        highlight link CursorLine TemporaryLineHighlight

        " Set up a timer to clear the highlight after 1 second
        let timer = timer_start(3000, {-> execute([
                    \ 'highlight link CursorLine ' . (s:old_cursorline ? 'CursorLine' : 'NONE'),
                    \ 'set nocursorline',
                    \ 'set cursorlineopt=' . s:old_cursorlineopt,
                    \ 'redraw'
                    \ ])})
    endfunction

    function! TmuxFocusCurrentPane()
        " Check if we're running inside tmux
        if ! ( exists('$TMUX') && g:pe_tmux_pane_id != '' && g:pe_tmux_window_id != '' )
            echohl WarningMsg
            echo "Not running inside tmux!"
            echohl None
            return
        endif
        " Get tmux pane ID for current vim instance
        " Focus on this pane in tmux
        call system("tmux select-window -t " . g:pe_tmux_window_id)
        call system("tmux select-pane -t " . g:pe_tmux_pane_id)
    endfunction

    " Temrdebug config
    " ----------------
    function! TermdebugWrapper(...) abort
        if !exists(':TermdebugCommand')
            packadd termdebug
        endif

        if a:0 > 0
            " echomsg 'TermdebugCommand ' .  join(a:000, ' ')
            execute 'TermdebugCommand ' .  join(a:000, ' ')
            execute 'Source'
            execute 'wincmd L'
            nnoremap M :Evaluate<CR>
            nnoremap _ :Down<CR>
        endif
    endfunction

    function! TermdebugSetConfig(...)
        let s:termdebug_extra_args = copy(a:000)
        " echomsg s:termdebug_extra_args
        " return

        function! CommandAddArgs(gdb_cmd, pty) abort
            let l:cmd = copy(a:gdb_cmd)

            " Add extra arguments if they exist

            " Add all fixed arguments at once using extend()
            let l:fixed_args = [
                        \ '-quiet',
                        \ '-iex', 'set pagination off',
                        \ '-iex', 'set mi-async on',
                        \ '-tty', a:pty,
                        \ '-ex', 'echo startupdone\n'
                        \ ]
            call extend(l:cmd, l:fixed_args)

            if exists('s:termdebug_extra_args') && !empty(s:termdebug_extra_args)
                call extend(l:cmd, s:termdebug_extra_args)
            endif

            " echomsg l:cmd
            return l:cmd
        endfunction

        let g:termdebug_config['command_add_args'] = function('CommandAddArgs')
        " echomsg g:termdebug_config
    endfunction

    function! TermdebugHandleArrays(gdb_encoded, proc_encoded, delim)
        let gdb_decoded = system('printf "%s" ''' . a:gdb_encoded . ''' | base64 -d')
        let proc_decoded = system('printf "%s" ''' . a:proc_encoded . ''' | base64 -d')

        let gdb_args = gdb_decoded == '' ? [] : split(gdb_decoded, a:delim, 1)
        let proc_args = proc_decoded == '' ? [] : split(proc_decoded, a:delim, 1)

        " echomsg gdb_args
        " echomsg proc_args
        call call('TermdebugSetConfig', gdb_args)
        call call('TermdebugWrapper', proc_args)
    endfunction

    command! -nargs=* -complete=file TermdebugWrapper call TermdebugWrapper(<f-args>)
    command! -nargs=* -complete=file TermdebugSetConfig call TermdebugSetConfig(<f-args>)


    function! JsonEncodeFiltered(dict) abort
        " Create a filtered copy of the dictionary
        let l:filtered = {}
        for [l:Key, l:Value] in items(a:dict)
            " Try to encode the value to check if it's supported
            try
                call json_encode(l:Value)
                let l:filtered[l:Key] = l:Value
            catch /E1161:/
                " Skip unsupported values (E474 is the JSON encoding error)
            endtry
        endfor
        return json_encode(filtered)
    endfunction

    function! LspDumpInfo() abort
        let l:servers = lsp#get_server_names()

        if empty(l:servers)
            echohl WarningMsg
            echomsg 'No LSP servers are currently active'
            echohl None
            return
        endif

        if len(l:servers) != 1
            echohl WarningMsg
            echomsg 'Multiple LSP servers found. Please specify which server: ' . join(l:servers, ', ')
            echohl None
        endif

        let l:server_name = l:servers[0]
        let l:info = lsp#get_server_info(l:server_name)
        let l:content = JsonEncodeFiltered(l:info)

        " Create new buffer and set content
        new
        setlocal buftype=nofile bufhidden=hide noswapfile
        call setline(1, split(l:content, '\n'))
    endfunction
    command! LspDumpInfo call LspDumpInfo()

    " command! AsUtf8 execute '%!iconv -t utf-8' | set fileencoding=utf-8
    command! -nargs=0 AsUtf8 silent execute '%!iconv -t utf-8 2>/dev/null' | silent set fileencoding=utf-8 | redraw!

    " You can map this to a key, for example:
    " nnoremap <Leader>h :call HighlightCurrentLineTemporarily()<CR>

    function! FilenoDiff()
        let d = gf#diff#investigate_the_hunk_under_the_cursor()
        if empty(d)
            echo "Not in a diff hunk"
            return
        endif

        let lineno = gf#diff#calculate_better_lineno('to', d)
        let path = d.to_path

        call Yank(path . ':' . lineno)
        echo path . ':' . lineno
    endfunction
    autocmd FileType diff command! -buffer Fileno call FilenoDiff()
