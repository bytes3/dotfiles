return {
  -- cond = false,
  'shivamashtikar/tmuxjump.vim',
  init = function()
    vim.g.tmuxjump_telescope = true
    vim.g.tmuxjump_custom_capture = '~/.config/nvim/scripts/capture.sh'
  end,
}
