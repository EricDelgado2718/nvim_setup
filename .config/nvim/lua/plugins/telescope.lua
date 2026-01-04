return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    enabled = vim.fn.executable("make") == 1,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- Wait until telescope is loaded by LazyVim, then load the extension
      require("lazyvim.util").on_load("telescope.nvim", function()
        pcall(require("telescope").load_extension, "fzf")
      end)
    end,
  },

  -- Add fzf settings to telescope without overriding LazyVim’s telescope config
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.extensions = opts.extensions or {}
      opts.extensions.fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      }
    end,
  },
}
