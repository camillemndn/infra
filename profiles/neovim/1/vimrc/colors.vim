" Color settings
set termguicolors

" see https://jdhao.github.io/2020/09/22/highlight_groups_cleared_in_nvim/
" for the rationaly behind this
augroup opaque_background
  autocmd!
  " take a look at the existing groups with `:so
  " $VIMRUNTIME/syntax/hitest.vim:
  " if something looks wrong with backgrounds...
  au ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
  au ColorScheme * highlight NonText ctermbg=NONE guibg=NONE
  au ColorScheme * highlight CursorLineNr ctermbg=NONE guibg=NONE
  au ColorScheme * highlight LineNr ctermbg=NONE guibg=NONE
  au ColorScheme * highlight Folded ctermbg=NONE guibg=NONE
  au ColorScheme * highlight FoldColumn ctermbg=NONE guibg=NONE
  au ColorScheme * highlight DiffDelete ctermbg=NONE guibg=NONE
  au ColorScheme * highlight Conceal ctermbg=NONE guibg=NONE
  au ColorScheme * highlight Todo ctermbg=NONE guibg=NONE
  au ColorScheme * highlight SignColumn ctermbg=NONE guibg=NONE
  au ColorScheme * highlight GruvboxRedSign ctermbg=NONE guibg=NONE
  au ColorScheme * highlight GruvboxGreenSign ctermbg=NONE guibg=NONE
  au ColorScheme * highlight GruvboxYellowSign ctermbg=NONE guibg=NONE
  au ColorScheme * highlight GruvboxBlueSign ctermbg=NONE guibg=NONE
  au ColorScheme * highlight GruvboxPurpleSign ctermbg=NONE guibg=NONE
  au ColorScheme * highlight GruvboxAquaSign ctermbg=NONE guibg=NONE
  au ColorScheme * highlight GruvboxOrangeSign ctermbg=NONE guibg=NONE
augroup END

set background=dark

colorscheme base16-tomorrow-night

