call plug#begin('~/.vim/plugged')
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
"Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
"Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

" 代码自动完成，安装完插件还需要额外配置才可以使用
"Plug 'ycm-core/YouCompleteMe'

" 安装 CoC 插件
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 自动格式化
" Plug 'tell-k/vim-autopep8'
Plug 'psf/black', { 'branch': 'stable' }

" 用来提供一个导航目录的侧边栏
Plug 'scrooloose/nerdtree'

" 可以使 nerdtree 的 tab 更加友好些
Plug 'jistr/vim-nerdtree-tabs'

" 可以在导航目录中看到 git 版本信息
" Plug 'Xuyuanp/nerdtree-git-plugin'

" 查看当前代码文件中的变量和函数列表的插件，
" 可以切换和跳转到代码中对应的变量和函数的位置
" 大纲式导航, Go 需要 https://github.com/jstemmer/gotags 支持
Plug 'preservim/tagbar'

" 自动补全括号的插件，包括小括号，中括号，以及花括号
"Plug 'jiangmiao/auto-pairs'

" Vim状态栏插件，包括显示行号，列号，文件类型，文件名，以及Git状态
"Plug 'vim-airline/vim-airline'

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
" 可以快速对齐的插件
Plug 'junegunn/vim-easy-align'

" 可以在文档中显示 git 信息
Plug 'airblade/vim-gitgutter'

" markdown 插件
"Plug 'iamcco/mathjax-support-for-mkdp'

" 下面两个插件要配合使用，可以自动生成代码块
"Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'

" go 主要插件
"Plug 'fatih/vim-go', { 'tag': '*' }

" go 中的代码追踪，输入 gd 就可以自动跳转
"Plug 'dgryski/vim-godef'

" 可以在 vim 中使用 tab 补全
"Plug 'vim-scripts/SuperTab'

" 可以在 vim 中自动完成
"Plug 'Shougo/neocomplete.vim'

Plug 'dhruvasagar/vim-table-mode'

" 插件结束的位置，插件全部放在此行上面
call plug#end()

" F5 to run sh/python3
map <F5> :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    if &filetype == 'sh'
        :!time bash %
    elseif &filetype == 'python'
        exec "!time python3 %"
    elseif &filetype == 'go'
        exec "!time go run %"
    endif
endfunc

nmap <silent> <F8> <Plug>MarkdownPreview
imap <silent> <F8> <Plug>MarkdownPreview

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

nnoremap <leader>a i\begin{aligned}<CR><CR>\end{aligned}<Esc>ko
inoremap <leader>a \begin{aligned}<CR><CR>\end{aligned}<Esc>ko

nnoremap <space> za

windo set wrap

syntax enable
syntax on

" 启用语法折叠
" set foldmethod=syntax
" 默认折叠关闭（可选）
set foldlevelstart=99  " 打开文件时默认展开所有代码
" 显示折叠标志（可选）
set foldcolumn=0       " 在左侧显示折叠列
set foldenable         " 启用折叠功能
nnoremap <space> za

set ruler
"set virtualedit=all
set backspace=indent,eol,start
"set number

autocmd FileType python setlocal foldmethod=indent
autocmd FileType yaml setlocal foldmethod=indent

" 针对 Markdown 文件设置折叠规则
"autocmd FileType markdown setlocal foldmethod=expr
autocmd FileType markdown setlocal foldexpr=MarkdownFold()
" MarkdownFold() in /usr/local/share/vim/vim91/ftplugin/markdown.vim

nnoremap <leader>mf :setlocal foldmethod=expr<CR>
nnoremap <leader>mm :setlocal foldmethod=manual<CR>

" 打开 Markdown 文件时，统一折叠到 2 级标题
"autocmd FileType markdown call Fold2(2)

" 自定义函数：折叠到指定层级
function! Fold2(level)
    " 设置指定的折叠层级
    exec 'setlocal foldlevel=' . a:level
endfunction
nnoremap z0 :call Fold2(0)<CR>
nnoremap z1 :call Fold2(1)<CR>
nnoremap z2 :call Fold2(2)<CR>
nnoremap z3 :call Fold2(3)<CR>
nnoremap z4 :call Fold2(4)<CR>
nnoremap z5 :call Fold2(5)<CR>
nnoremap z6 :call Fold2(6)<CR>
nnoremap z7 :call Fold2(7)<CR>
nnoremap z8 :call Fold2(8)<CR>
nnoremap z9 :call Fold2(9)<CR>

let mapleader = "\\"
let g:my_virtualenv = expand('~/.venv')
let $http_proxy = 'http://127.0.0.1:7890'
let $https_proxy = 'http://127.0.0.1:7890'
