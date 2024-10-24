vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- load vimscripts
-- vim.cmd 'source ~/.config/nvim/vimscripts/multicursor.vim'

-- load lua scripts
require 'custom.options'

require 'custom.remaps'

require 'custom.autocmds'

require 'custom.commands'

require 'custom.lazyvim'
