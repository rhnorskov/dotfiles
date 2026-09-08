-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- macOS Option+Backspace: delete the word before the cursor.
vim.keymap.set({ "i", "c" }, "<M-BS>", "<C-w>")
