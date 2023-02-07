let
  airline = builtins.readFile ./plugins/airline.vim;
  completion = builtins.readFile ./plugins/completion.vim;
  camelCaseMotion = builtins.readFile ./plugins/CamelCaseMotion.vim;
  fzf = builtins.readFile ./plugins/fzf.vim;
  grammarous = builtins.readFile ./plugins/grammarous.vim;
  gruvbox = builtins.readFile ./plugins/gruvbox.vim;
  lspconfig = builtins.readFile ./plugins/lspconfig.vim;
  nerdtree = builtins.readFile ./plugins/nerdtree.vim;
  rainbow = builtins.readFile ./plugins/rainbow.vim;
  solarized = builtins.readFile ./plugins/solarized.vim;
  treesitter = builtins.readFile ./plugins/treesitter.vim;
in

''
  ${airline}  
  ${completion}
  ${camelCaseMotion}  
  ${fzf}  
  ${grammarous}  
  ${gruvbox}  
  ${lspconfig}  
  ${nerdtree}  
  ${rainbow}  
  ${solarized}  
  ${treesitter}
''
