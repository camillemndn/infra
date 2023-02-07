" toggle file tree
nnoremap <Space>ff :NERDTreeToggle<CR>

" window movement
nnoremap <Space>wj <C-W>j
nnoremap <Space>wk <C-W>k
nnoremap <Space>wl <C-W>l
nnoremap <Space>wh <C-W>h
nnoremap <Space>wc :close<CR>

" spelling
nnoremap <Space>se :setlocal spell spelllang=en<CR>
nnoremap <Space>sd :setlocal spell spelllang=de<CR>
nnoremap <Space>so :setlocal invspell<CR>

" Buffers
nnoremap <Space>bb :Buffers<CR>
nnoremap <Space>bd :bd<CR> " close (aka delete) buffer
nnoremap <Space>bw :bw<CR> " delete buffer from memory (wipe)
nnoremap <Space>bwf :bw!<CR> " force deletion (e. g. discard unwritten changes)

" Reload configs 
nnoremap <Space>rrr :source ~/.config/nvim/init.vim<CR>

" Search settings
nnoremap <Space>sc :set ignorecase!<CR> " toggle case (in)sensitive search 
nnoremap <Space>sh :nohlsearch<CR> " remove highlighting for the last search

" Opening config files 
nnoremap <Space>ec :edit ~/.config/nvim/
nnoremap <Space>esf :Rg<CR>
nnoremap <Space>esr :RgR<CR>
nnoremap <Space>ef :Files<CR>
nnoremap <Space>eg :GFiles<CR>

function! MakeSession()
	NERDTreeClose
	mksession!
endfunc

" Exit 
nnoremap <Space>q :call MakeSession()<CR>:q<CR>
nnoremap <Space>w :w<CR>
nnoremap <Space>wq :call MakeSession()<CR>:wq<CR>
nnoremap <Space>qa :call MakeSession()<CR>:qa<CR>
nnoremap <Space>wa :call MakeSession()<CR>:wqa<CR>
nnoremap <Space>wr <C-w>=
nnoremap <Space>qi :qa<CR>

" Swapping two windows
function! WinBufSwap()
	let thiswin = winnr()
	let thisbuf = bufnr("%")
	let lastwin = winnr("#")
	let lastbuf = winbufnr(lastwin)
	exec lastwin . " wincmd w" ."|".
		\ "buffer ". thisbuf ."|".
		\ thiswin ." wincmd w" ."|".
		\ "buffer ". lastbuf
endfunc

command! Wswap :call WinBufSwap()
map <Silent> <Space>ws :call WinBufSwap()<CR>

" format after putting
function! FormatPut()
	let curLine = line(".")
	execute "normal gp"
	let afterPasteLine = line(".")
	let difference = afterPasteLine - curLine
	exec "normal " curLine . "G" 	
	if difference > 0
		exec "normal "difference . "=="
	endif
endfunc

nnoremap <Space>pf :call FormatPut()<CR>

" autocompletion
" inoremap <expr> <C-J> pumvisible() ? "\<C-n>" : "\<C-J>"
" inoremap <expr> <C-K> pumvisible() ? "\<C-p>" : "\<C-K>"
" inoremap <silent><expr> <C-Space> compe#complete()
" inoremap <silent><expr> <CR>      compe#confirm('<CR>')
" inoremap <silent><expr> <C-e>     compe#close('<C-e>')
" inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
" inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
