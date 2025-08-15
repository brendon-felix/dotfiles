return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'nvim-telescope/telescope-live-grep-args.nvim' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          layout_config = {
            vertical = {
              width = 0.9,
              height = 0.9,
              preview_height = 0.6,
            },
            horizontal = {
              width = 0.9,
              height = 0.9,
              preview_width = 0.6,
            },
            center = {
              width = 0.9,
              height = 0.9,
            },
            bottom_pane = {
              width = 0.9,
              height = 0.9,
            },
          },
        },
        pickers = {
          find_files = {
            theme = 'dropdown',
            initial_mode = 'insert',
            path_display = { 'smart' },
            layout_config = {
              width = 0.9,
              height = 0.9,
              preview_width = 0.8,
            },
          },
          live_grep = {
            initial_mode = 'insert',
          },
          buffers = {
            sort_lastused = true,
            initial_mode = 'normal',
          },
          oldfiles = {
            sort_lastused = true,
            initial_mode = 'normal',
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          file_browser = {
            hide_parent_dir = true,
            initial_mode = 'normal',
            display_stat = {
              size = true,
            },
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'file_browser')
      pcall(require('telescope').load_extension, 'live_grep_args')
      local builtin = require 'telescope.builtin'
      local extensions = require('telescope').extensions
      vim.keymap.set(
        'n',
        '<leader>sh',
        builtin.help_tags,
        { desc = '[S]earch [H]elp' }
      )
      vim.keymap.set(
        'n',
        '<leader>sk',
        builtin.keymaps,
        { desc = '[S]earch [K]eymaps' }
      )
      vim.keymap.set(
        'n',
        '<leader>sf',
        builtin.find_files,
        { desc = '[S]earch [F]iles' }
      )
      vim.keymap.set(
        { 'n', 'i', 'v' },
        '<C-q>',
        builtin.find_files,
        { desc = 'Search Files' }
      )
      vim.keymap.set(
        'n',
        '<leader>ss',
        builtin.builtin,
        { desc = '[S]earch [S]elect Telescope' }
      )
      vim.keymap.set(
        'n',
        '<leader>sw',
        builtin.grep_string,
        { desc = '[S]earch current [W]ord' }
      )
      vim.keymap.set(
        'n',
        '<leader>sg',
        extensions.live_grep_args.live_grep_args,
        { desc = '[S]earch by [G]rep' }
      )
      -- vim.keymap.set(
      --   { 'n', 'i', 'v' },
      --   '<C-S-f>',
      --   extensions.live_grep_args.live_grep_args,
      --   { desc = 'Search by grep' }
      -- )
      vim.keymap.set(
        'n',
        '<leader>sd',
        builtin.diagnostics,
        { desc = '[S]earch [D]iagnostics' }
      )
      vim.keymap.set(
        'n',
        '<leader>sr',
        builtin.resume,
        { desc = '[S]earch [R]esume' }
      )
      vim.keymap.set(
        'n',
        '<leader>s.',
        builtin.oldfiles,
        { desc = '[S]earch Recent Files ("." for repeat)' }
      )
      vim.keymap.set(
        'n',
        '<leader><leader>',
        builtin.buffers,
        { desc = '[ ] Find existing buffers' }
      )
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          }
        )
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
