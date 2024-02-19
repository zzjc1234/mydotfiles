require("toggleterm").setup{
  open_mapping = [[<C-\>]],  -- 在新标签页中打开终端
  hide_numbers = true,  -- 隐藏终端号码
  shade_terminals = true,  -- 是否为终端窗口添加阴影
  start_in_insert = true,  -- 是否在终端中以插入模式启动
  insert_mappings = true,  -- 是否为终端插入模式映射键
	direction = "float",
  float_opts = {
    border = 'curved',  -- 浮动窗口边框样式
  }
}


vim.api.nvim_set_keymap("n", "'h", "<Cmd>ToggleTerm direction=horizontal<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "'v",  "<Cmd>ToggleTerm direction=vertical size=40<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "'f", "<Cmd>ToggleTerm direction=float<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "'t", "<Cmd>ToggleTerm direction=tab<CR>", { noremap = true, silent = true })

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
local ranger = Terminal:new({ cmd = "ranger", hidden = true })

function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end

function _RANGER_TOGGLE()
  ranger:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>r", "<cmd>lua _RANGER_TOGGLE()<CR>", {noremap = true, silent = true})
