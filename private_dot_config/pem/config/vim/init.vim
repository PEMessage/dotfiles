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



" 1. Configure List
" ===========================================

    " Plug-Mirror
    let s:PE_VimPlugURL = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    " let s:PE_VimPlugURL = 'https://gitee.com/yaozhijin/vim-plug/raw/master/plug.vim'

    " let g:plug_url_format='https://git::@hub.fastgit.xyz/%s.git'
    " let g:plug_url_format='https://ghproxy.com/https://github.com/%s.git'

    " TrueColor
    set termguicolors
    set nocompatible


    " Comment Color
    let s:PECommentColor = {"gui": "#00af87", "cterm": "246", "cterm16": "7"}
    " let s:PECompleteSys  = "asyncomplete"
    " let s:PECompleteSys  = "apt"
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

                    " \   'gitbranch': 'FugitiveHead',
                    " \   'searchcount': 'SearchIndex'



" 2. Auto Install ViM-Plug
" ===========================================
"
    if has('nvim')
        let g:pe_runtimepath = stdpath('data') . '/site'
    else
        exe 'set rtp+=' . expand('~/.config/vim')
        let g:pe_runtimepath = expand('~/.config/vim')
    endif
    if empty(glob(pe_runtimepath . '/autoload/plug.vim'))
      silent execute '!curl -fLo '.pe_runtimepath.'/autoload/plug.vim --create-dirs '.s:PE_VimPlugURL
      source $MYVIMRC
    endif

    let g:pe_cachedir = expand('~/.cache/vim')
    if !isdirectory(pe_cachedir)
        call mkdir(pe_cachedir, "p")
    endif

" 3. Some General Setting
" ===========================================


" -------------------------------------------
" 3.1 Basic Setting Zone
" -------------------------------------------
    set nocompatible     " 禁用 vi 兼容模式
    set helplang=cn      " 设置中文帮助手册
    set nowrap           " 关闭自动换行
    set ruler            " 显示光标位置
    set ffs=unix,dos,mac " 文件换行符，默认使用 unix 换行符
    set updatetime=700
    set linebreak
    set wildmenu
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
        set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1
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
    endif

    if has("patch-8.1.0360")
        set diffopt+=internal,algorithm:patience,iwhite
    endif
    set diffopt+=iwhite

    vnoremap RightMouse "+y



" -------------------------------------------
" 3.3 Search Zone
" -------------------------------------------
    set smartcase   " 智能搜索大小写判断，默认忽略大小写，除非搜索内容包含大写字母
    set incsearch   " 查找输入时动态增量显示查找结果
    set hlsearch    " 高亮搜索内容



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


    set backspace=eol,start,indent " 类似所有编辑器的删除键

    if has('autocmd')
        filetype plugin indent on  " 允许 Vim 自带脚本根据文件类型自动设置缩进等
    endif

    " Tab Line Setting Zone
    set hidden

" -------------------------------------------
" 3.5 Window Setting
" -------------------------------------------
    autocmd FileType help wincmd L
    autocmd FileType man wincmd L
    augroup vimrc_help
        autocmd!
        autocmd BufEnter *.* if &buftype == 'help' | wincmd L | endif
    augroup END


	runtime ftplugin/man.vim
    runtime macros/matchit.vim
    
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
    execute "set viewdir=" . g:pe_cachedir . '/view'
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
    augroup vimStartup
        au!

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid, when inside an event handler
        " (happens when dropping a file on gvim) and for a commit message (it's
        " likely a different one than last time).
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
    elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
        set ttimeoutlen=80
    endif
    " 终端下允许 ALT，详见：http://www.skywind.me/blog/archives/2021
    " 记得设置 ttimeout （见 init-basic.vim） 和 ttimeoutlen （上面）
    " Plug ‘vim-fixkey’ 更好的解决了这个问题
    "----------------------------------------------------------------------
    if has('nvim') == 0 && has('gui_running') == 0
        function! s:metacode(key)
            exec "set <M-".a:key.">=\e".a:key
        endfunc
        function! s:set_key(key, keyCode)
            if get(g:, 'altmeta_skip_meta', 0) == 0
                execute "set " . a:key . "=" . a:keyCode
            endif
        endfunc

        for i in range(10)
            call s:metacode(nr2char(char2nr('0') + i))
        endfor
        for i in range(26)
            call s:metacode(nr2char(char2nr('a') + i))
            call s:metacode(nr2char(char2nr('A') + i))
        endfor
        for c in [',', '.', '/', ';', '{', '}']
            call s:metacode(c)
        endfor
        for c in ['?', ':', '-', '_', '+', '=', "'"]
            call s:metacode(c)
        endfor
        for c in ['`']
            call s:metacode(c)
        endfor
    endif
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
    inoremap jj <ESC>
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
    nnoremap <silent><C-S-TAB> :tabp<CR>
    inoremap <silent><C-S-TAB> <C-o>:tabp<CR>
    nnoremap <silent><C-TAB>   :tabn<CR>
    inoremap <silent><C-TAB>   <C-o>:tabn<CR>

    nnoremap gq :exit<CR>

" -------------------------------------------
" 4.3 Mouse mapping
" -------------------------------------------
    " nnoremap <MiddleMouse>     :tabclose<CR>
    vnoremap <RightMouse>            "+y
    inoremap <RightMouse>       <C-o>"+p


" -------------------------------------------
" 4.3 Extend mapping and command
" -------------------------------------------
    nnoremap <leader>rcc  :w<CR> :source %<CR> " Re:Configuration
    nnoremap <leader>rce  :tabe ~/.vimrc <CR>

    nnoremap <leader>``   :nohlsearch<CR>
    nnoremap <leader>`1   :set! virtualedit=onemore<CR>
    nnoremap <leader>wp  :set nowrap!<CR>
    nnoremap <leader>cl  :set cursorline!<CR>

    nnoremap <leader>nu  :set number!<CR>
                        set number
    nnoremap <leader>nr :set relativenumber!<CR>
    nnoremap <leader>tb  :tab ball<CR>
    nnoremap <leader>gp  `[v`]
    nnoremap gp  `[v`]

    command! PCD execute 'cd' .. expand('%:p:h')
    command! PFile echo  expand('%:p')
    " See: https://www.cyberciti.biz/faq/vim-vi-text-editor-save-file-without-root-permission/
    command Psudow :execute ':silent w !sudo tee % > /dev/null' | :edit!
    nnoremap <silent><leader>ro :set readonly!<CR>:set modifiable<CR>

    " vnoremap <cr> iwoiwo

" 5. Netrw Setting
" ===========================================

" -------------------------------------------
" 5.1 Basic netrw setting
" -------------------------------------------
    let g:netrw_banner = 0                      " 设置是否显示横幅
    if argv(0) ==# '.'
        let g:netrw_browse_split = 0
    else
        let g:netrw_browse_split = 4
    endif

    let g:netrw_preview = 1                     " 指针保留于Netrw
    let g:netrw_winsize = 25                    " %25的窗口大小
    let g:netrw_liststyle = 2                   " 设置目录列表的样式：树形
    let g:netrw_sort_sequence = '[\/]$,*'
    let g:netrw_hide = 1

" -------------------------------------------
" 5.2 Buffer mapping
" -------------------------------------------
    autocmd FileType netrw call s:RemoveNetrwMap()
    function! s:RemoveNetrwMap()
        if hasmapto('<Plug>NetrwRefresh')
        " Unmap Netrw Keybind
            unmap <buffer> <C-I>
            unmap <buffer> <C-O>

        " map Netrw Keybind
            " Forward dir
            nmap <buffer> <C-I> U
            " Backword dir
            nmap <buffer> <C-O> u
            " ctrl-l for left pannel

        " New Map
            " Back to parent dir
            nmap <buffer> H -
            nmap <buffer> <C-0> echo b
            " Enter next dir
            nmap <buffer> L <C-M>
            nmap <buffer> <leader>b :wincmd c<CR>
        endif
    endfunction

    nnoremap <silent><leader>b  :Lexplore<CR>

    command! PEWrite w! sudo tee %


" 6. VIM Plug-in Zone (Part1)
" ===========================================
call plug#begin(pe_runtimepath . '/plugged')

" -------------------------------------------
" 6.1 Basic Funtion
" -------------------------------------------
    " Some little tweak
    " Plug 'drmikehenry/vim-fixkey'
    Plug 'PEMessage/vim-fixkey'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    " Plug 'linrongbin16/fzfx.vim'
    Plug 'tacahiroy/ctrlp-funky'
    Plug 'ctrlpvim/ctrlp.vim'
        let g:ctrlp_map = ''
        let g:ctrlp_root_markers = ['.root', 'repo', '.git']
        let g:ctrlp_max_depth = 3
        nnoremap <c-f> :CtrlPFunky<Cr>

        noremap <silent> <C-r> :History<CR>
        noremap <silent> <C-p> :CtrlPBuffer<CR>
        " nnoremap <leader>cm :\<C-U>FzfxCommands<CR>
        noremap <silent> <C-e> :FZF<CR>
        " nnoremap <C-S-p> :\<C-U>FzfxCommands<CR>


        noremap <leader>ft :BTags<CR>
        nnoremap <leader>fbr :\<C-U>FzfxBranches<CR>

        " nnoremap <leader>fg :\<C-U>FzfxLiveGrep<CR>
        " nnoremap <leader>ff :\<C-U>FzfxFiles<CR>
        nnoremap <Leader>fu :CtrlPFunky<Cr>
        " nnoremap <space>fw :\<C-U>FzfxLiveGrep<CR>
        " if has('autocmd')
        "     autocmd filetype fzf
        " else
        " augroup PE_FZF_GROUP
        "     autocmd!
        "     autocmd filetype fzf tnoremap  <buffer> <C-o> <enter>
        " augroup END
        " JUST USE <C-M> AS ENTER
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
        let g:M_default_mappings = 0
        let g:VM_mouse_mappings  = 1
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

        nmap / <Plug>(easymotion-sn)
        nnoremap <leader>/ /
        map <space> <Plug>(easymotion-s)
        " See: https://www.reddit.com/r/vim/comments/lhohqd/remap_after_searching/
        " https://github.com/romainl/vim-cool
        " cnoremap <expr> <silent> <cr> getcmdtype() =~ '[?/]' ? "\<cr>:noh\<cr>" : "\<cr>"
        " nunmap ds
        " <leader>yr
    Plug 'vim-scripts/YankRing.vim'
        " let vimd_path =
        " if !isdirectory(vimd_path)
        "     call mkdir(vimd_path, "p")
        " endif
        let g:yankring_history_dir = pe_cachedir
        " nnoremap <silent> <leader>yy :YRShow<CR>
        nnoremap <silent> <C-y> :YRShow<CR>
        inoremap <silent> <C-y> <ESC>:YRShow<CR>


        let g:yankring_replace_n_pkey = ''
        let yankring_min_element_length = 2
        let g:yankring_paste_using_g = 0
    Plug 'ojroques/vim-oscyank', {'branch': 'main'}
        vmap <leader>c <Plug>OSCYankVisual
    " Plug 'dylanaraps/fff.vim'
    "     nnoremap f :F<CR>
    Plug 'preservim/nerdtree'
        nnoremap <leader>n :NERDTreeFocus<CR>






" -------------------------------------------
" 6.2 Textobj
" -------------------------------------------
"

    Plug 'kana/vim-submode'
        let g:submode_timeout = 0
        " let g:submode_keep_leaving_key = 0
        let g:submode_always_show_submode = 1
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-indent'
    Plug 'kana/vim-textobj-syntax'
    Plug 'kana/vim-textobj-line'
    Plug 'sgur/vim-textobj-parameter'
    Plug 'jceb/vim-textobj-uri'
    Plug 'terryma/vim-expand-region'
    let g:expand_region_text_objects = {
                \ 'iw'  :0,
                \ 'iW'  :0,
                \ 'i"'  :0,
                \ 'i''' :0,
                \ 'i]'  :1,
                \ 'ib'  :1,
                \ 'iB'  :1,
                \ 'il'  :0,
                \ 'ip'  :0,
                \ 'ab' :1,
                \ 'aB' :1,
                \ 'ii' :0,
                \ 'ai' :0,
    \ }
        map <CR> <Plug>(expand_region_expand)
        map <BS> <Plug>(expand_region_shrink)



" -------------------------------------------
" 6.3 Style PlugIn
" -------------------------------------------
    Plug 'itchyny/lightline.vim'
    Plug 'google/vim-searchindex'
    Plug 'edkolev/tmuxline.vim'

    Plug 'romgrk/github-light.vim'
    Plug 'joshdick/onedark.vim'
    " let g:onedark_color_overrides = {
    "             \ "QuickFixLine": {"gui": "#2F343F", "cterm": "235", "cterm16": "0" },
    "             \}
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
            autocmd ColorScheme * call onedark#extend_highlight("Search", { "gui" : "underline,bold,italic,standout",  "bg": { "gui": "#444959" } , "fg" : {"gui":"yellow" }})
            autocmd ColorScheme * call onedark#extend_highlight("IncSearch", { "gui" : "underline,bold,italic,standout",  "bg": { "gui": "#444959" } , "fg" : {"gui":"yellow" }})
            autocmd ColorScheme * call onedark#extend_highlight("QuickFixLine", { "gui" : "underline",  "bg": { "gui": "NONE" } , "fg" : {"gui":"yellow" }})
            autocmd ColorScheme * highlight QuickFixLineScope gui=underline guifg=#e5c07b

        augroup END
    endif

    Plug 'Yggdroot/indentLine'
    Plug 'mhinz/vim-startify'
        nnoremap <leader>st :tab new<CR>:Startify<CR> " Most Recent File MRF
        nnoremap <leader>sb :Startify<CR> " Most Recent File MRF
        let g:startify_session_dir = pe_cachedir . "/session"
    " Plug 'ap/vim-buftabline'

    Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
    Plug 'itchyny/vim-cursorword'
    " Plug 'junegunn/rainbow_parentheses.vim'
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
    " Plug 'ARM9/arm-syntax-vim'
        " autocmd BufNewFile,BufRead *.s,*.S set filetype=arm " arm = armv6/7
    Plug 'rubberduck203/aosp-vim'
        autocmd BufNewFile,BufRead *.bp set filetype=json " arm = armv6/7
    " Plug 'sheerun/vim-polyglot'
    Plug 'mtdl9/vim-log-highlighting'
    Plug 'chrisbra/Colorizer'
    Plug 'powerman/vim-plugin-AnsiEsc'

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

" -------------------------------------------
" 6.4 Locale
" -------------------------------------------
    Plug 'yianwillis/vimcdoc'
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
    " Using :verbose and :set together will (likely) tell you
    " the file and line number where the option was last set.
    " Can you do the following after opening a kotlin file?
    " verbose set commentstring?
        autocmd FileType c setlocal commentstring=//\ %s
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-vinegar'
    Plug 'tpope/vim-rsi'


" -------------------------------------------
" 6.6 Git plugin
" -------------------------------------------
    Plug 'airblade/vim-gitgutter'
        command! Gqf GitGutterQuickFix | copen
    Plug 'will133/vim-dirdiff'
        let g:DirDiffWindowSize = 7
    Plug 'samoshkin/vim-mergetool'
        let g:mergetool_layout = 'mr'
        let g:mergetool_prefer_revision = 'local'
        " :h copy-diffs
        " :'<,'>diffget  do(diff obtain)
        " :'<,'>diffput. dp(diff put)
    Plug 'cohama/agit.vim'
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
        nnoremap <leader>ag :Agit<CR>




" -------------------------------------------
" 6.7 Tmux and Terminal
" -------------------------------------------
    Plug 'NickLaMuro/vimux'
        nmap <Leader>vl :VimuxRunLastCommand<CR>
        nmap <Leader>vp :VimuxPromptCommand<CR>
        " nmap <Leader>vo :VimuxOpenRunner<CR>
    Plug 'gioele/vim-autoswap'
        let g:autoswap_detect_tmux = 1
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
    Plug 'voldikss/vim-floaterm'
        let g:floaterm_keymap_toggle = '<M-`>'
        let g:floaterm_position = 'bottomright'
        let g:floaterm_opener = 'tabe'
    Plug 'christoomey/vim-tmux-navigator'
        let g:tmux_navigator_no_mappings = 1
        noremap  <silent><M-S-h> :<C-U>TmuxNavigateLeft<cr>
        noremap  <silent><M-S-j> :<C-U>TmuxNavigateDown<cr>
        noremap  <silent><M-S-k> :<C-U>TmuxNavigateUp<cr>
        noremap  <silent><M-S-l> :<C-U>TmuxNavigateRight<cr>
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
    Plug 'PEMessage/vim-gutentags'
        set tags=./.tags;,.tags
        let g:gutentags_project_root = ['.root','.project']
        let g:gutentags_add_default_project_roots = 1
        let g:gutentags_add_ctrlp_root_markers = 0
        " Pls manully gen tags, using :GutentagsUpdate
        let g:gutentags_background_update = 0
        let g:gutentags_generate_on_write = 0

        " 所生成的数据文件的名称
        " let g:gutentags_ctags_tagfile = '.tags'
        " 同时开启 ctags 和 gtags 支持：
        let g:gutentags_modules = []
        " if executable('ctags')
        "     let g:gutentags_modules += [ 'ctags' ]
        " endif
        if executable('gtags-cscope') && executable('gtags')
            let g:gutentags_modules += ['gtags_cscope']
        endif
        " 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
        let s:vim_tags = expand('~/.cache/tags')
        let g:gutentags_cache_dir = s:vim_tags
        if !isdirectory(s:vim_tags)
            silent! call mkdir(s:vim_tags, 'p')
        endif

        " 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extra=+q，注意
        let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
        let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
        let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
        " 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
        let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
        let g:gutentags_gtags_extra_args = [ '--skip-unreadable' ]
        " 禁用 gutentags 自动加载 gtags 数据库的行为
        let g:gutentags_auto_add_gtags_cscope = 0
        let g:gutentags_auto_add_cscope = 0
        let g:gutentags_define_advanced_commands = 1
        set cscopetag

        " 0 or s: Find this symbol
        " 1 or g: Find this definition
        " 2 or d: Find functions called by this function
        " 3 or c: Find functions calling this function
        " 4 or t: Find this text string
        " 6 or e: Find this egrep pattern
        " 7 or f: Find this file
        " 8 or i: Find files #including this file
        " 9 or a: Find places where this symbol is assigned a value
    Plug 'PEMessage/gutentags_plus'
        let g:gutentags_plus_nomap = 1
        let g:gutentags_plus_height = 5
        let g:gutentags_plus_native = 0
        let g:gutentags_plus_native = 0

        noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>
        noremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>

        noremap <silent> gn         :GscopeFind g <C-R><C-W><cr>
        noremap <silent> gy         :GscopeFind g <C-R><C-W><cr>:call QuickfixArrowPreview('j')<cr>
        noremap <silent> gh         :GscopeFind g <C-R><C-W><cr>:cnext<cr>
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
    Plug 'liuchengxu/vista.vim'
        let g:vista#renderer#enable_icon = 0
        let g:vista_echo_cursor_strategy = "scroll"
        nnoremap <leader>at :TagbarToggle<CR>
        nnoremap <leader>av :Vista!!<CR>
    Plug 'Shougo/vinarise.vim'

    " This will do "imap \ihs so !!! DONT USE IT !!!
    " Plug 'vim-scripts/a.vim'
    " Plug 'vim-scripts/taglist.vim'

    Plug 'skywind3000/asyncrun.vim'
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
        nnoremap <leader>ar :AsyncRun!
        " Compile current file
        nnoremap <silent> <leader>aq1 :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
        " Run it !
        nnoremap <silent> <leader>aq2 :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
        if has('win32') || has('win64')
            noremap <silent><leader>aqe :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>"
                        \ "\%CD\%\*.h" "\%CD\%\*.c*" <cr>
        else
            noremap <silent><leader>aqe :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W>
                        \ --include='*.h' --include='*.c*' '<root>' <cr>
        endif



" -------------------------------------------
" 6.9 Quickfix Plugin
" -------------------------------------------
    " Quickfix Config
    set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-,a-
    " Plug 'vim-scripts/cscope-quickfix'
    Plug 'skywind3000/vim-preview'
        autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
        autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>
        autocmd FileType qf nnoremap <silent><buffer> <MiddleMouse> :PreviewQuickfix<cr>

    " Quicktoggle
    function! ToggleQuickfix()
        if empty(filter(getwininfo(), 'v:val.quickfix'))
            copen
        else
            cclose
        endif
    endfunction

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
    " Call the function! to setup the autocmd

    " Gtag quickfix keymap
        noremap <silent> go :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
        nnoremap <leader>cc  :call ToggleQuickfix()<CR>
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
" 6.11 Complete Engine (async complete)
" -------------------------------------------
    set pumheight=5
    Plug 'prabirshrestha/async.vim'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'prabirshrestha/asyncomplete-buffer.vim'
    Plug 'wellle/tmux-complete.vim'
        let g:asyncomplete_auto_popup = 1
        

        function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
        endfunction


        inoremap <silent><expr> <TAB>
                    \ pumvisible() ? "\<C-n>" :
                    \ <SID>check_back_space() ? "\<TAB>" :
                    \ asyncomplete#force_refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
        imap <c-space> <Plug>(asyncomplete_force_refresh)
    if has('patch-8.0.1494')
        Plug 'hrsh7th/vim-vsnip'
        Plug 'hrsh7th/vim-vsnip-integ'
    endif
    Plug 'rafamadriz/friendly-snippets'
    Plug 'prabirshrestha/asyncomplete-file.vim'
    
    
    



call plug#end()

" 7. VIM Plug-in Zone (Part2)
" ===========================================
" -------------------------------------------
" 7.1 Style
" -------------------------------------------
    colorscheme onedark
" -------------------------------------------
" 7.2 Async complete
" -------------------------------------------
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
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


" -------------------------------------------
" 7.3 Expand region
" -------------------------------------------
    call expand_region#custom_text_objects()

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




" 8 Self Funtion Zone
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
    " Surround Viusal Zone
    function! PESurroundViusalZone()
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
    noremap <silent><leader>sr :call PESurroundViusalZone()<CR>

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
    vnoremap tt :s/\s\+$//e<CR>
    vnoremap p pgvy


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


    " copy to attached terminal using the yank(1) script:
    " https://github.com/sunaku/home/blob/master/bin/yank
    function! Yank(text) abort
        let escape = system('yank', a:text)
    if v:shell_error
        echoerr escape
    else
        call writefile([escape], '/dev/tty', 'b')
    endif
    endfunction
    noremap <silent> <Leader>y y:<C-U>call Yank(@0)<CR>
