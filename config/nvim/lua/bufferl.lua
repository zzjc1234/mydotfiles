require'bufferline'.setup{
  options = {
    numbers = "ordinal",  -- 显示缓冲区编号
    close_command = "bdelete",  -- 关闭缓冲区的命令
    right_mouse_command = "bdelete!",  -- 右键单击关闭缓冲区的命令
    middle_mouse_command = "bdelete!",  -- 中键单击关闭缓冲区的命令
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "center"}},
  },
}

vim.api.nvim_set_keymap('n', '<C-1>', ':BufferLineGoToBuffer 1<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-2>', ':BufferLineGoToBuffer 2<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-3>', ':BufferLineGoToBuffer 3<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-4>', ':BufferLineGoToBuffer 4<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-5>', ':BufferLineGoToBuffer 5<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-6>', ':BufferLineGoToBuffer 6<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-7>', ':BufferLineGoToBuffer 7<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-8>', ':BufferLineGoToBuffer 8<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-9>', ':BufferLineGoToBuffer 9<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', '<C-$>', ':BufferLineGoToBuffer -1<CR>', { noremap = true, silent=true })

vim.api.nvim_set_keymap('n', ',gt', ':BufferLineCycleNext<CR>', { noremap = true, silent=true })
vim.api.nvim_set_keymap('n', ',gT', ':BufferLineCyclePrev<CR>', { noremap = true, silent=true })

vim.api.nvim_set_keymap('n', '<C-Q>', ':bd<CR>', { noremap = true, silent=true })
