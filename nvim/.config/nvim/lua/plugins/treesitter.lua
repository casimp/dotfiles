return {
  {
    "nvim-treesitter/nvim-treesitter",
    pin = false,
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
      auto_install = true,
    },
  },
}
