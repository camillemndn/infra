lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- TODO enable disabled stuff for languages without lsp support?
  highlight = { enable = false, }, 
  incremental_selection = { enable = false, },
  indent = { enable = false, },
}
EOF

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
