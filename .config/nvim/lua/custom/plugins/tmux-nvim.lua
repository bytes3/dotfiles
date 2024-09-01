return {
  -- cond = false,
  'aserowy/tmux.nvim',
  config = function()
    require('tmux').setup {
      copy_sync = { enable = true },
      navigation = { cycle_navigation = true, enable_default_keybindings = false },
      resize = { enable_default_keybindings = false, resize_step_x = 5, resize_step_y = 5 },
    }

    vim.keymap.set('n', '<M-h>', '<cmd>lua require("tmux").move_left()<cr>')
    vim.keymap.set('n', '<M-j>', '<cmd>lua require("tmux").move_bottom()<cr>')
    vim.keymap.set('n', '<M-k>', '<cmd>lua require("tmux").move_top()<cr>')
    vim.keymap.set('n', '<M-l>', '<cmd>lua require("tmux").move_right()<cr>')

    vim.keymap.set('n', '<M-S-h>', '<cmd>lua require("tmux").resize_left()<cr>')
    vim.keymap.set('n', '<M-S-j>', '<cmd>lua require("tmux").resize_bottom()<cr>')
    vim.keymap.set('n', '<M-S-k>', '<cmd>lua require("tmux").resize_top()<cr>')
    vim.keymap.set('n', '<M-S-l>', '<cmd>lua require("tmux").resize_right()<cr>')
  end,
}
