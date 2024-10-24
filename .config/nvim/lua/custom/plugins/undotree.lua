return {
  -- cond = false,
  'mbbill/undotree',
  branch = 'master',
  config = function()
    vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = 'Toggle [u]ndotree' })
  end,
}
