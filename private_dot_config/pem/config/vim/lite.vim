
" -------------------------------------------
" Color Scheme
" -------------------------------------------
    source $VIMRUNTIME/defaults.vim
    set termguicolors
    set nocompatible
    colorscheme desert
    runtime macros/matchit.vim
" -------------------------------------------
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
        vnoremap RightMouse "+y
    endif

    if has("patch-8.1.0360")
        set diffopt+=internal,algorithm:patience,iwhite
    endif
    set diffopt+=iwhite




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
    " execute "set viewdir=" . g:pe_cachedir . '/view'
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
    set tags=./.tags;,.tags



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

    function PERcEdit() 
        if exists('g:pe_rc["file"]') && !empty(g:pe_rc['file'])
            execute 'tabedit ' .. g:pe_rc['file']
        else 
            execute 'tabedit ' .. '~/.vimrc'
        endif
    endfunction
    nnoremap <leader>rce  <cmd>call PERcEdit()<CR>

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

   
    vnoremap tt :s/\s\+$//e<CR>
    " See: v_p v_P
    vnoremap p P
    vnoremap P p
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

    command! PEWrite w !sudo tee %

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
