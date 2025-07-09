return {
  {
    'zbirenbaum/copilot.lua',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = '<Tab>',
          },
        },
      }
    end,
  },
  -- {
  --   'karb94/neoscroll.nvim',
  --   config = function()
  --     require('neoscroll').setup {
  --       mappings = {
  --         '<C-u>',
  --         '<C-d>',
  --         '<C-b>',
  --         '<C-f>',
  --         '<C-y>',
  --         '<C-e>',
  --         'zt',
  --         'zz',
  --         'zb',
  --         'gg',
  --       },
  --       hide_cursor = false,
  --       stop_eof = true,
  --       cursor_scrolls_alone = true,
  --       ignored_events = {},
  --     }
  --   end,
  -- },
}
