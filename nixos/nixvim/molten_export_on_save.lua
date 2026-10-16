function()
  if require("molten.status").initialized() == "Molten" then
    vim.cmd("MoltenExportOutput!")
  end
end
