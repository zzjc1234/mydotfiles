-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
vim.api.nvim_set_keymap('n', '<leader>m', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<S-l>', '<C-w>l', { noremap = true })

vim.g.nvim_tree_gitignore = 0
-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 25,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

vim.cmd[[hi NvimTreeNormal guibg=NONE ctermbg=NONE]]

--local function open_nvim_tree(data)
--
--  -- buffer is a real file on the disk
--  local real_file = vim.fn.filereadable(data.file) == 1
--
--  -- buffer is a [No Name]
--  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
--
--  if not real_file and not no_name then
--    return
--  end
--
--  -- open the tree, find the file but don't focus it
--  require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
--end
