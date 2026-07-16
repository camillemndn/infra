function(bufnr)
  vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
  vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
end
