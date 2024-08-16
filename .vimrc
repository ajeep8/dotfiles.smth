"set virtualedit=all

call plug#begin()
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
call plug#end()

nmap <silent> <F8> <Plug>MarkdownPreview
imap <silent> <F8> <Plug>MarkdownPreview
nmap <silent> <F9> <Plug>StopMarkdownPreview
imap <silent> <F9> <Plug>StopMarkdownPreview

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

nnoremap <leader>a i\begin{aligned}<CR><CR>\end{aligned}<Esc>ko
inoremap <leader>a \begin{aligned}<CR><CR>\end{aligned}<Esc>ko

windo set wrap

