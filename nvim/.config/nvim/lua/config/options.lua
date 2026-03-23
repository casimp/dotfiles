vim.g.mapleader = " "

-- Ubuntu multiarch: tree-sitter needs this to compile parsers
if vim.fn.isdirectory("/usr/include/x86_64-linux-gnu") == 1 then
  vim.env.CPATH = "/usr/include/x86_64-linux-gnu"
end

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.clipboard = "unnamedplus"

-- Auto-reload files changed externally
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})
