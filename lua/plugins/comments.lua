return {
  {
    'folke/ts-comments.nvim',
    config = function()
      require('ts-comments').setup {
        lang = {
          nu = {
            comment = '#',
            line_comment = '#',
            block_comment = { '#', '#' },
          },
        },
      }
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  {
    dir = '~/Projects/divide.nvim',
    -- 'brendon-felix/divide.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>ds',
        function()
          require('divide').subheader()
        end,
        desc = '[D]ivide with [S]ubheader',
      },
      {
        '<leader>dh',
        function()
          require('divide').header()
        end,
        desc = '[D]ivide with [H]eader',
      },
      {
        '<leader>dd',
        function()
          require('divide').divider()
        end,
        desc = '[D]ivide with [D]ivider',
      },
    },
    config = function()
      require('divide').setup {
        language_config = {
          nu = {
            line_start = '#',
            line_end = '#',
            character = '-',
          },
        },
      }
    end,
  },
}
