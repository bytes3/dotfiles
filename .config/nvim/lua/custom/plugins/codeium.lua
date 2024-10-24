return {
  {
    'Exafunction/codeium.vim',
    opts = {},
    event = 'BufEnter',
    config = function()
      vim.g.codeium_disable_bindings = 1
      vim.g.codeium_enabled = 0

      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set('i', '<C-g>', function()
        return vim.fn['codeium#Accept']()
      end, { expr = true, silent = true })

      vim.keymap.set('i', '<c-;>', function()
        return vim.fn['codeium#CycleCompletions'](1)
      end, { expr = true, silent = true })

      vim.keymap.set('i', '<c-,>', function()
        return vim.fn['codeium#CycleCompletions'](-1)
      end, { expr = true, silent = true })

      vim.keymap.set('i', '<c-x>', function()
        return vim.fn['codeium#Clear']()
      end, { expr = true, silent = true })

      -- toggles codeium
      vim.keymap.set('n', '<Leader>tc', function()
        return vim.cmd 'Codeium Toggle'
      end, { desc = 'Toggle [c]odeium' })
    end,
  },
}
