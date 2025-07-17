return {
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/noice.nvim',
    },
    config = function()
      require('notify').setup {
        background_colour = '#191919',
        merge_duplicates = true,
      }
      vim.notify = require 'notify'
    end,
  },
}
