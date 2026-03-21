-- Minimal neovim config for viewing code
-- Not trying to be an IDE. Just a good viewer with syntax highlighting.

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Visual
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.opt.wrap = false

-- Tabs (view only, but makes files display correctly)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Auto-reload files changed externally (by Claude)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

-- Mouse support
vim.opt.mouse = "a"

-- System clipboard
vim.opt.clipboard = "unnamedplus"

-- Disable swap/backup (we have git)
vim.opt.swapfile = false
vim.opt.backup = false

-- Space as leader
vim.g.mapleader = " "

-- Quick quit
vim.keymap.set("n", "q", ":q<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", ":qa<CR>", { silent = true })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", ":noh<CR>", { silent = true })
