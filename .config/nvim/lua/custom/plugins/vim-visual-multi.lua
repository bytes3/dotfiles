-- return {
--   -- cond = false,
--   'mg979/vim-visual-multi',
--   branch = 'master',
--   init = function()
--     -- vim.g.VM_leader = 'm'
--   end,
--   config = function()
--     vim.cmd [[hi! VM_Mono guibg=Grey60 guifg=Black gui=NONE]]
--     vim.g.VM_default_mappings = 0
--     vim.g.VM_maps['Find Next'] = '<C-m>'
--     -- vim.g.VM_custom_noremaps = { ['<c-m>'] = 'N' }
--   end,
-- }
--

return {
  'smoka7/multicursors.nvim',
  cond = false,
  event = 'VeryLazy',
  dependencies = {
    'nvimtools/hydra.nvim',
  },
  opts = {},
  cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
  keys = {
    {
      mode = { 'v', 'n' },
      '<Leader>m',
      '<cmd>MCstart<cr>',
      desc = 'Create a selection for selected text or word under the cursor',
    },
  },
}
