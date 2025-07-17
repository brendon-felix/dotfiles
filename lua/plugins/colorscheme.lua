return {
  {
    'brendon-felix/anysphere.nvim',
    event = 'VimEnter',
    lazy = false,
    priority = 1000,
    config = function()
      require('anysphere').setup {
        italic = {
          strings = false,
          emphasis = true,
          comments = true,
          operators = true,
          folds = true,
        },
      }
      vim.cmd.colorscheme 'anysphere'
    end,
  },
}
