-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Trackpads emit stray horizontal scroll events; 1 column per tick keeps them
-- from lurching the view sideways.
vim.opt.mousescroll = "ver:3,hor:1"
