return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    lazy = false,
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
      {
        '<leader>e',
        function()
          require('neo-tree.command').execute { toggle = true, dir = vim.loop.cwd() }
        end,
        desc = 'Toggle NeoTree',
      },
    },
    opts = {
      filesystem = {
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
      source_selector = {
        winbar = true,
        statusline = false,
        content_layout = 'center',
        sources = {
          { source = 'filesystem', display_name = 'Files' },
          { source = 'buffers', display_name = 'Buffers' },
          { source = 'git_status', display_name = 'Git' },
        },
      },
      window = {
        mappings = {
          ['P'] = {
            'toggle_preview',
            config = {
              use_float = false,
              -- title = 'Neo-tree Preview',
            },
          },
        },
      },
    },
  },
}
