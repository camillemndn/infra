set backup " keep a backup copy when overwriting

set history=100 " 100 items in history

set signcolumn=auto:3 " always show sign column

set hidden " allow to switch buffers although the current buffer has unsaved changes

set sessionoptions-=options " do not store global and local values in a session

let g:vim_markdown_conceal = 0
let g:tex_flavor = 'latex'
let g:tex_conceal = 'abdmgs'
let g:conceallevel = 2
let g:vim_markdown_math = 0
let g:vim_markdown_conceal_code_blocks = 0

" disable git gutter in diff view
if &diff
  let g:gitgutter_enabled = 0
endif
