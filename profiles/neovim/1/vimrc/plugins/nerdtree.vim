" autoclose nerdtree if everything is closed
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:NERDTreeGitStatusUntrackedFilesMode = 'all'
let g:NERDTreeGitStatusUseNerdFonts = 1
