
" -------------------------------------------
" Color Scheme
" -------------------------------------------
    source $VIMRUNTIME/defaults.vim
    set termguicolors
    set nocompatible
    colorscheme desert
    runtime macros/matchit.vim
" -------------------------------------------
" Basic setting
" -------------------------------------------
    set nowrap           " 关闭自动换行
    set ruler            " 显示光标位置
    set ffs=unix,dos,mac " 文件换行符，默认使用 unix 换行符
    set updatetime=700
    set linebreak

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


    set backspace=eol,start,indent " 类似所有编辑器的删除键

    if has('autocmd')
        filetype plugin indent on  " 允许 Vim 自带脚本根据文件类型自动设置缩进等
    endif

    " Tab Line Setting Zone
    set hidden


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

" -------------------------------------------
" 4.3 Mouse mapping
" -------------------------------------------
    " nnoremap <MiddleMouse>     :tabclose<CR>
    vnoremap <RightMouse>            "+y
    inoremap <RightMouse>       <C-o>"+p
    vnoremap tt :s/\s\+$//e<CR>
    vnoremap p pgvy


" -------------------------------------------
" 4.3 Extend mapping and command
" -------------------------------------------
    nnoremap <leader>rcc  :w<CR> :source %<CR> " Re:Configuration
    nnoremap <leader>rce  :tabe ~/.vimrc <CR> 

    nnoremap <leader>``   :nohlsearch<CR>
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
    nnoremap <silent><leader>ro :set readonly!<CR>:set modifiable<CR>


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
