vim.g.mc = "y/\\V\\<C-r>=escape(@\", '/')\\<CR>\\<CR>"

vim.api.nvim_set_keymap('n', 'cn', [[*``cgn]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'cN', [[*``cgN]], { noremap = true, silent = true })

vim.api.nvim_set_keymap('v', 'cn', [[<Cmd>lua return vim.g.mc .. "``cgn"<CR>]], { expr = true, noremap = true })
vim.api.nvim_set_keymap('v', 'cN', [[<Cmd>lua return vim.g.mc .. "``cgN"<CR>]], { expr = true, noremap = true })

local function setup_cr()
  vim.api.nvim_set_keymap('n', '<Enter>', [[<Cmd>lua vim.api.nvim_feedkeys('n@z<CR>q:', 'n', true)<CR><Cmd>lua vim.api.nvim_set_reg('z', string.sub(vim.fn.getreg('z'), 1, #vim.fn.getreg('z') - 1))<CR>]], { noremap = true, silent = true })
  vim.api.nvim_feedkeys('n@z', 'n', true)
end

vim.api.nvim_set_keymap('n', 'cq', [[<Cmd>lua setup_cr()<CR>*``qz]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'cQ', [[<Cmd>lua setup_cr()<CR>#``qz]], { noremap = true, silent = true })

vim.api.nvim_set_keymap('v', 'cq', [[<Cmd>lua setup_cr()<CR>gv]] .. vim.g.mc .. "``qz", { expr = true, noremap = true })
vim.api.nvim_set_keymap('v', 'cQ', [[<Cmd>lua setup_cr()<CR>gv]] .. vim.g.mc:gsub('/', '?') .. "``qz", { expr = true, noremap = true })

