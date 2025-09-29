return {
  {
    'booperlv/nvim-gomove',
    event = 'VeryLazy',
    config = function()
      require('gomove').setup {}
    end,
  },

  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {}
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
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
    'brendon-felix/divide.nvim',
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
        languages = {
          nu = {
            line_start = '#',
            line_end = '#',
            character = '-',
          },
          toml = {
            line_start = '#',
            line_end = '#',
            character = '-',
          },
        },
      }
    end,
  },
}
