call setenv("GRADLE_HOME", "/home/florian/.gradle")
call setenv("WORKSPACE", "/home/florian/Documents/eclipse_workspace")

lua << EOF
local custom_lsp_attach = function(client)
	local opts = {noremap = true}

	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>ch', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)	
	-- following currently broken, but known issue
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>cH', '<cmd>lua vim.lsp.buf.hover()vim.lsp.buf.hover()<CR>', opts) 
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>cn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>cd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>ct', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>crr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>crf', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>cru', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>crs', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>cf', '<cmd>lua vim.lsp.buf.formatting_sync()<CR>', opts)
	vim.api.nvim_buf_set_keymap(0, 'n', '<Space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local lspconfig = require'lspconfig'
lspconfig.bashls.setup {
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.ccls.setup {
	root_dir = lspconfig.util.root_pattern(".ccls-root", "compile_commands.json", ".git"),
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.cssls.setup {
    cmd = { "css-languageserver", "--stdio" },
	on_attach = custom_lsp_attach,
    root_dir = lspconfig.util.root_pattern("package.json", ".git"),
    capabilities = capabilities
}
-- lspconfig.diagnosticls.setup {
-- 	on_attach = custom_lsp_attach,
--     capabilities = capabilities
-- }
lspconfig.dockerls.setup {
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.html.setup {
    cmd = { "html-languageserver", "--stdio" },
	on_attach = custom_lsp_attach,
    filetypes = { "html", "htmldjango" },
    capabilities = capabilities
}
lspconfig.jsonls.setup  {
	cmd = { "json-languageserver", "--stdio" },
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.java_language_server.setup {
  cmd = { "java-language-server" },
  on_attach = custom_lsp_attach
}
-- lspconfig.jdtls.setup {
-- 	on_attach = custom_lsp_attach,
-- 	root_dir = lspconfig.util.root_pattern("gradle.build", "pom.xml", ".git", "mvnw", "gradlew", "build.xml"),
-- 	filetypes = { "java" },
-- 	init_options = {
-- 		jvm_args = {},
-- 		workspace = "/home/florian/Documents/eclipse-workspace",
-- 	},
--     capabilities = capabilities
-- }
lspconfig.pylsp.setup {
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.rust_analyzer.setup  {
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.sqlls.setup {
	cmd = { "sql-language-server", "up", "--method", "stdio" },
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.texlab.setup  {
	on_attach = custom_lsp_attach,
	filetypes = { "tex", "bib" },
    capabilities = capabilities
}
lspconfig.vimls.setup  {
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.yamlls.setup {
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.rnix.setup {
	on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.denols.setup {
    on_attach = custom_lsp_attach,
    capabilities = capabilities
}
lspconfig.elixirls.setup {
    on_attach = custom_lsp_attach,
    capabilities = capabilities, 
    cmd = { "elixir-ls" }
}
lspconfig.elmls.setup {
    on_attach = custom_lsp_attach,
    capabilities = capabilities,
    settings = {
      elmLS = {
        elmFormatPath = "elm-format";
        elmPath = "elm";
        elmReviewPath = "elm-review";
        elmTestPath = "elm-test";
      }
    }
}
EOF

" jdtls.start_or_attach({cmd = {'java-lsp.sh', '/home/user/workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')}, root_dir = jdtls_setup.find_root({'gradle.build', 'pom.xml'}), on_attach = custom_lsp_attach})
"
