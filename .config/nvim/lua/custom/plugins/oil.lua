return {
  {
    'stevearc/oil.nvim',
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['<C-p>'] = 'actions.open_external',
        ['<C-v>'] = 'actions.preview',
        ['yp'] = {
          desc = 'Copy filepath to system clipboard',
          callback = function()
            require('oil.actions').copy_entry_path.callback()
            vim.fn.setreg('+', vim.fn.getreg(vim.v.register))
          end,
        },
        ['yr'] = {
          callback = function()
            local oil = require 'oil'
            local entry = oil.get_cursor_entry()
            local dir = oil.get_current_dir()

            if not entry or not dir then
              return
            end

            local relpath = vim.fn.fnamemodify(dir, ':.')

            vim.fn.setreg('+', relpath .. entry.name)
          end,
        },
      },
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
