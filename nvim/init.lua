-- -------------------------------------------------------------------------- --
--                                  init.lua                                  --
-- -------------------------------------------------------------------------- --

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- -------------------------------- options --------------------------------- --

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.linebreak = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
-- vim.o.shiftwidth = 4
-- vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.virtualedit = 'block'
vim.o.termguicolors = true

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣',
}

-- -------------------------------- keymaps --------------------------------- --

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
  desc = '[Q]uickfix list',
})

-- ------------------------------ autocommands ------------------------------ --

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup(
    'kickstart-highlight-yank',
    { clear = true }
  ),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ------------------------------ install lazy ------------------------------ --

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- ------------------------------- setup lazy ------------------------------- --

require('lazy').setup {
  install = { colorscheme = 'anysphere' },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  { import = 'plugins' },
}

-- vim: ts=2 sts=2 sw=2 et
