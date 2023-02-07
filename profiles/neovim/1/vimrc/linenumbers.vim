set number relativenumber " hybrid line numbers (current line absolute, other relative)

function! ExcludeNumbers()
	if index(['nerdtree', 'fzf', 'help'], &ft) >= 0
		setlocal norelativenumber
		setlocal nonumber
		setlocal signcolumn=no
	endif
endfunc

function! EnableRelativeNumbers()
	setlocal relativenumber
	call ExcludeNumbers()
endfunc

function! DisableRelativeNumbers()
	setlocal norelativenumber
	call ExcludeNumbers()
endfunc

augroup numbertoggle " automatically switch
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * :call EnableRelativeNumbers()
	autocmd BufLeave,FocusLost,InsertEnter * :call DisableRelativeNumbers()
augroup end
