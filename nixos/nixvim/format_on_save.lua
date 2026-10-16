function(bufnr)
  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
    return
  end

  return { timeout_ms = 200, lsp_fallback = true }
end
