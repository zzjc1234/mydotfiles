-- Disable default mappings
vim.g.EasyMotion_do_mapping = 0

vim.api.nvim_set_keymap('n', 'ms', '<Plug>(easymotion-overwin-f2)', {})

vim.api.nvim_set_keymap('n', 'm/', '<Plug>(easymotion-sn)', {})
vim.api.nvim_set_keymap('x', 'm/', '<Plug>(easymotion-tn)', {})

vim.api.nvim_set_keymap('n', 'mn', '<Plug>(easymotion-next)', {})
vim.api.nvim_set_keymap('n', 'mN', '<Plug>(easymotion-prev)', {})

-- Turn on case-insensitive feature
vim.g.EasyMotion_smartcase = 1

-- Map <Leader>L
vim.api.nvim_set_keymap('n', 'ml', '<Plug>(easymotion-bd-jk)', {})
vim.api.nvim_set_keymap('n', 'ml', '<Plug>(easymotion-overwin-line)', { noremap = true })

vim.api.nvim_set_keymap('n', 'mf', '<Plug>(easymotion-sl)', {})

