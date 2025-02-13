-- clear on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

local is_diagnostic_drawing_disabled = false
function toggle_diagnostic_drawing()
  vim.diagnostic.config {
    virtual_text = is_diagnostic_drawing_disabled,
    underline = is_diagnostic_drawing_disabled,
  }

  is_diagnostic_drawing_disabled = not is_diagnostic_drawing_disabled
end

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [d]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [d]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [e]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [q]uickfix list' })
vim.keymap.set('n', '<leader>td', toggle_diagnostic_drawing, { desc = 'Toggle [d]iagnostic line drawing' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set({ 'n', 'v' }, '<leader>Y', [["+Y]])

vim.keymap.set({ 'n' }, '<leader>o', '<cmd>Oil<CR>')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('n', '<leader>S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = '[S]ubstitute the whole file' })

-- open new project
vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>')

-- don't save into \" register
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])
vim.keymap.set('x', '<leader>p', [["_dP]])

vim.keymap.set('n', '<C-c>', ':w<CR>')
