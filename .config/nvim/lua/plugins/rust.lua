local uv = vim.uv or vim.loop

local function realpath(p)
  return (uv and uv.fs_realpath(p)) or p
end

local CONNECT_ROOT = realpath(vim.fn.expand("~/connect"))

local function in_connect_repo()
  local cwd = realpath(vim.fn.getcwd())
  -- true if cwd == ~/connect or inside it
  return cwd == CONNECT_ROOT or cwd:sub(1, #CONNECT_ROOT + 1) == (CONNECT_ROOT .. "/")
end

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    enabled = function()
      return not in_connect_repo()
    end,
    init = function()
      -- your rustaceanvim settings (optional)
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {},
          },
        },
      }
    end,
  },

  -- Optional: also disable crates.nvim in connect (can leave enabled if you want)
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    enabled = function()
      return not in_connect_repo()
    end,
    opts = { completion = { cmp = { enabled = true } } },
  },
}
