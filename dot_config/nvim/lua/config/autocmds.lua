-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Register this nvim as a cmux cmd-click target; ~/.config/cmux/open-in-nvim picks the most recently focused one
if vim.env.CMUX_PANEL_ID then
  local dir = vim.fn.stdpath("state") .. "/cmux-nvim"
  local state_file = dir .. "/" .. vim.fn.getpid()
  local group = vim.api.nvim_create_augroup("cmux_active_nvim", { clear = true })
  local function claim()
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({ vim.v.servername, vim.env.CMUX_PANEL_ID, vim.env.CMUX_WORKSPACE_ID or "" }, state_file)
  end
  vim.api.nvim_create_autocmd("FocusGained", { group = group, callback = claim })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      os.remove(state_file)
    end,
  })
  claim()
end
