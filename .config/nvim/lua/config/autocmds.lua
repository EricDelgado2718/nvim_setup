-- Rust: smart handling for `'` (lifetimes vs char literals) WITHOUT weird keycode bytes
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(args)
    local buf = args.buf

    -- If mini.pairs mapped `'`, remove it for this buffer so our mapping wins
    if _G.MiniPairs and MiniPairs.unmap_buf then
      pcall(MiniPairs.unmap_buf, buf, "i", "'")
    end

    local function in_string_or_comment()
      local syn = vim.fn.synIDattr(vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1), "name")
      return syn:find("String") ~= nil or syn:find("Comment") ~= nil
    end

    local function in_generic_angles()
      local line = vim.api.nvim_get_current_line()
      local col0 = vim.api.nvim_win_get_cursor(0)[2] -- 0-index col before insertion
      local before = line:sub(1, col0)
      local lt = select(2, before:gsub("<", ""))
      local gt = select(2, before:gsub(">", ""))
      return lt > gt
    end

    local function prev_nonspace_char()
      local line = vim.api.nvim_get_current_line()
      local col0 = vim.api.nvim_win_get_cursor(0)[2]
      local i = col0
      while i > 0 do
        local c = line:sub(i, i)
        if not c:match("%s") then
          return c
        end
        i = i - 1
      end
      return ""
    end

    local function lifetime_context()
      if in_string_or_comment() then
        return false
      end
      if in_generic_angles() then
        return true
      end
      local prev = prev_nonspace_char()
      -- common lifetime contexts: &'a, Foo<'a>, where 'a: 'b, etc.
      return prev == "&" or prev == "<" or prev == ":" or prev == "," or prev == "("
    end

    local function feed(keys)
      local k = vim.api.nvim_replace_termcodes(keys, true, false, true)
      vim.api.nvim_feedkeys(k, "in", false) -- insert + no-remap
    end

    vim.keymap.set("i", "'", function()
      if lifetime_context() then
        feed("'") -- lifetime: single '
      else
        feed("''<Left>") -- char literal convenience
      end
    end, { buffer = buf, noremap = true, desc = "Rust: smart apostrophe" })
  end,
})

-- Different colors for relative line numbers above vs below the cursor (+ current line)
local function set_rnu_colors()
  local above = "#b0d8f7" -- lines above cursor
  local below = "#7281b3" -- lines below cursor
  local current = "#ffffff" -- current line number (CursorLineNr) <-- change this

  if vim.fn.hlexists("LineNrAbove") == 1 then
    vim.api.nvim_set_hl(0, "LineNrAbove", { fg = above })
  end
  if vim.fn.hlexists("LineNrBelow") == 1 then
    vim.api.nvim_set_hl(0, "LineNrBelow", { fg = below })
  end

  -- Current line number
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = current, bold = true })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_rnu_colors,
  desc = "Set LineNrAbove/LineNrBelow/CursorLineNr colors",
})

set_rnu_colors()
