return {
  {
    "nvim-treesitter/nvim-treesitter",
    pin = true,
    opts = {
      ensure_installed = {
        "bash",
        "diff",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = false,
    },
  },
}
