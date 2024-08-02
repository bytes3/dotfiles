return {
  -- cond = false,
  'mg979/vim-visual-multi',
  branch = 'master',
  init = function()
    vim.g.VM_leader = 'm'
  end,
  config = function()
    vim.cmd [[hi! VM_Mono guibg=Grey60 guifg=Black gui=NONE]]
  end,
}
