function(args)
  local buf = args.buf
  local path = vim.api.nvim_buf_get_name(buf)
  local lines = {}

  if vim.fn.filereadable(path) == 1 then
    local res = vim.system({ "jupytext", "--to", "md", "--output", "-", path }, { text = true }):wait()
    if res.code ~= 0 then
      -- A scratch buffer cannot be written, so a failed read never clobbers the notebook.
      vim.bo[buf].buftype = "nofile"
      vim.notify("jupytext: " .. res.stderr, vim.log.levels.ERROR)
      return
    end
    lines = vim.split(res.stdout, "\n")
    if lines[#lines] == "" then
      table.remove(lines)
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
  vim.bo[buf].filetype = "markdown"
end
