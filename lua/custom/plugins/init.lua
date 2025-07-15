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
  --   'nvimtools/none-ls.nvim',
  --   config = function()
  --     local null_ls = require 'null-ls'
  --     null_ls.setup {
  --       -- sources = {
  --       --   null_ls.builtins.formatting.prettierd,
  --       --   null_ls.builtins.diagnostics.eslint_d,
  --       --   null_ls.builtins.code_actions.eslint_d,
  --       --   null_ls.builtins.formatting.stylua,
  --       --   null_ls.builtins.formatting.rustfmt,
  --       --   null_ls.builtins.diagnostics.shellcheck,
  --       --   null_ls.builtins.formatting.shfmt,
  --       --   null_ls.builtins.diagnostics.markdownlint,
  --       -- },
  --     }
  --   end,
  -- },
  -- {
  --   'LhKipp/nvim-nu',
  --   config = function()
  --     require('nu').setup {}
  --     vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = true })
  --   end,
  -- },
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
