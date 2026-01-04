return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- keep compatible updates
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
          on_attach = function(_, bufnr)
            -- Inlay hints (Neovim 0.10+)
            pcall(function()
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end)
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = {
                command = "clippy",
              },
              procMacro = { enable = true },
            },
          },
        },
      }
    end,
  },

  -- Cargo.toml helper (versions, features, updates)
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = { cmp = { enabled = true } },
    },
  },
}
