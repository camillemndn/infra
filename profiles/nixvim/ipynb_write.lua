function(args)
  local buf = args.buf
  local path = vim.api.nvim_buf_get_name(buf)
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"

  local cmd = { "jupytext", "--from", "md", "--to", "ipynb", "--output", path }
  if vim.fn.filereadable(path) == 1 then
    -- Keep the outputs already stored in the notebook.
    table.insert(cmd, "--update")
  end
  table.insert(cmd, "-")

  local res = vim.system(cmd, { stdin = text, text = true }):wait()
  if res.code ~= 0 then
    vim.notify("jupytext: " .. res.stderr, vim.log.levels.ERROR)
    return
  end

  vim.bo[buf].modified = false
  vim.api.nvim_exec_autocmds("BufWritePost", { buffer = buf })
end
