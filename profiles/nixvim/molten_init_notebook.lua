function(args)
  local buf = args.buf
  local path = vim.api.nvim_buf_get_name(buf)
  if not path:match("%.ipynb$") or vim.fn.exists(":MoltenInit") ~= 2 then
    return
  end

  vim.schedule(function()
    -- MoltenInit attaches to the current buffer.
    if vim.api.nvim_get_current_buf() ~= buf or require("molten.status").kernels() ~= "" then
      return
    end

    local ok, kernel = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(path), "\n")).metadata.kernelspec.name
    end)
    if ok and vim.tbl_contains(vim.fn.MoltenAvailableKernels(), kernel) then
      vim.cmd.MoltenInit(kernel)
      vim.cmd.MoltenImportOutput()
    end
  end)
end
