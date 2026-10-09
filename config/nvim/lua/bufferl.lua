require("bufferline").setup({
	options = {
		numbers = "ordinal", -- 显示缓冲区编号
		close_command = "bdelete", -- 关闭缓冲区的命令
		right_mouse_command = "bdelete!", -- 右键单击关闭缓冲区的命令
		middle_mouse_command = "bdelete!", -- 中键单击关闭缓冲区的命令
		offsets = { { filetype = "NvimTree", text = "File Explorer", text_align = "center" } },
	},
})

vim.api.nvim_set_keymap("n", ",1", ":BufferLineGoToBuffer 1<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",2", ":BufferLineGoToBuffer 2<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",3", ":BufferLineGoToBuffer 3<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",4", ":BufferLineGoToBuffer 4<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",5", ":BufferLineGoToBuffer 5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",6", ":BufferLineGoToBuffer 6<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",7", ":BufferLineGoToBuffer 7<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",8", ":BufferLineGoToBuffer 8<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",9", ":BufferLineGoToBuffer 9<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",$", ":BufferLineGoToBuffer -1<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", ",gt", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",gT", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-Q>", ":bd<CR>", { noremap = true, silent = true })
