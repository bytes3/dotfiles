return {
  {
    'tpope/vim-fugitive',
    cond = false,
    opts = {},
    config = function()
      vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
    end,
  },
}
