set hls
set is
set cb=unnamed
set ts=4
set sw=4
set si
set ai
syntax on

autocmd BufNewFile *.cpp -r ~/programming/cp/template.cpp


inoremap { {}<Left>
inoremap {<CR> {<CR>}<Esc>O
inoremap {{ {
inoremap {} {}
inoremap ( ()<Left>
inoremap () ()
inoremap [ []<Left>

autocmd filetype cpp nnoremap <F9> :w <bar> !g++ -std=c++17 -Wshadow -Wall % -o %:r -O2 -Wno-unused-result<CR>
"autocmd filetype cpp nnoremap <F9> :w <bar> !g++ -std=c++14 % -o %:r -Wl,--stack,268435456<CR>
autocmd filetype cpp nnoremap <F10> :!./%<<CR>
autocmd filetype cpp nnoremap <C-C> :silent! s/^\(\s*\)/\1\/\/<CR> :silent! s/^\(\s*\)\/\/\/\//\1<CR>


set nu
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set rnu
    autocmd BufLeave,FocusLost,InsertEnter * set nornu
augroup END
