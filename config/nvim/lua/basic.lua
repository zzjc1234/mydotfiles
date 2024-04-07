local opt=vim.opt
local g=vim.g
local api=vim.api
local cmd=vim.cmd

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

g.mapleader = ','
g.maplocalleader = '\\'

vim.opt.shortmess:append 'IWs'
vim.opt.rtp:prepend(lazypath)

-- 设置背景
opt.background = 'dark'

g.vimwiki_list = {{path='~/Dropbox/**/*', syntax='markdown', ext='.md'}}

vim.g.vimwiki_ext2syntax = { ['.md'] = 'markdown' }

-- 设置Neovim的语言为英语
cmd('language en_US.UTF-8')

-- 配色方案
cmd[[colorscheme tokyonight]]

-- 关闭 vi 兼容模式
opt.compatible = false

-- 自动语法高亮
cmd('syntax enable')

-- 显示行号
opt.number = true

-- 突出显示当前行
opt.cursorline = true

-- 打开状态栏标尺
opt.ruler = true

-- 设定 << 和 >> 命令移动时的宽度为 2
opt.shiftwidth = 2

-- 使得按退格键时可以一次删掉 2 个空格
opt.softtabstop = 2

-- 设定 tab 长度为 2
opt.tabstop = 2

-- 覆盖文件时不备份
opt.backup = false

-- 自动切换当前目录为当前文件所在的目录
opt.autochdir = true

-- 设置备份时的行为为覆盖
opt.backupcopy = 'yes'

-- 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
opt.ignorecase = true

opt.smartcase = true

-- 禁止在搜索到文件两端时重新搜索
opt.wrapscan = false

-- 输入搜索内容时就显示搜索结果
opt.incsearch = true

-- 搜索时高亮显示被找到的文本
opt.hlsearch = true

-- 关闭错误信息响铃
opt.errorbells = false

-- 关闭使用可视响铃代替呼叫
opt.visualbell = false

-- 设置魔术
opt.magic = false

-- 允许在有未保存的修改时切换缓冲区
opt.hidden = true

-- 开启新行时使用智能自动缩进
opt.smartindent = true

-- 设置 backspace 行为
opt.backspace = 'indent,eol,start'

-- 显示状态栏
opt.laststatus = 2

-- 设置命令行高度
opt.cmdheight = 1

-- 开始折叠
opt.foldenable = false

-- 设置语法折叠
--opt.foldmethod = 'syntax'

-- 设置 Python 文件的缩进折叠
api.nvim_exec([[
augroup PythonIndentFold
    autocmd!
    autocmd FileType python lua if vim.bo.filetype == "python" then vim.wo.foldmethod = "indent" end
augroup END
]], false)

-- 设置其他文件类型的语法折叠
api.nvim_exec([[
augroup SyntaxFold
    autocmd!
    autocmd FileType * lua if vim.bo.filetype ~= "python" then vim.wo.foldmethod = "syntax" end
augroup END
]], false)

-- 设置折叠区域的宽度
opt.foldcolumn = '0'

-- 设置折叠层数
vim.opt_local.foldlevel = 1
vim.opt_local.foldlevelstart = 0

-- 设置自动关闭折叠
--opt.foldclose = 'all'

-- 设置分割窗口方向
opt.splitright = true
opt.splitbelow = true

-- 用空格键来开关折叠
-- 定义函数来折叠/展开代码块
local function toggle_fold()
  local line_number = vim.fn.line('.')
  local fold_status = vim.fn.foldclosed(line_number)
  if fold_status < 0 then
    cmd('normal! zc')
  else
    cmd('normal! zO')
  end
end

-- 将函数暴露给全局
_G.toggle_fold = toggle_fold

-- 将函数映射到 <Space>
api.nvim_set_keymap('n', '<S-Space>', ':lua toggle_fold()<CR>', { noremap = true, silent=true })

api.nvim_set_keymap('n', '`k', '<C-w>+', { noremap = true, silent=true })
api.nvim_set_keymap('n', '`j', '<C-w>-', { noremap = true, silent=true })
api.nvim_set_keymap('n', '`l', '<C-w>>', { noremap = true, silent=true })
api.nvim_set_keymap('n', '`h', '<C-w><', { noremap = true, silent=true })
api.nvim_set_keymap('n', '\\\\n', ':set number!<Cr>', { noremap = true, silent=true })

api.nvim_set_keymap('n', '<leader>p', ':vs|term=glow<CR>', { noremap = true, silent = true })

-- 设置字体
opt.guifont = 'Droid Sans Mono for Powerline Nerd Font Complete 16'
opt.encoding = 'utf8'

api.nvim_set_keymap('v', '(', 's()<ESC>P', { noremap = true, silent=true })
api.nvim_set_keymap('v', '[', 's[]<ESC>P', { noremap = true, silent=true })
api.nvim_set_keymap('v', '{', 's{}<ESC>P', { noremap = true, silent=true })
-- api.nvim_set_keymap('v', '<', 's<><ESC>P', { noremap = true, silent=true })

function surround_selected_text(Sign)
	api.nvim_exec(string.format([[ '<,'>s/\%%V\.\*\%%V\./%s\&%s/ ]], Sign, Sign), true)
end

api.nvim_set_keymap('x', '<leader>sd', [[:lua surround_selected_text(vim.fn.input('Sign: '))<CR>]], { noremap = true, silent = true })

  --autocmd Filetype markdown inoremap $ $$<ESC>i
cmd([[autocmd FileType tex let b:coc_pairs = ([(["$", "$"])])]])
cmd([[autocmd FileType cpp let b:coc_pairs_disabled = (['<'])]])
cmd([[autocmd FileType c let b:coc_pairs_disabled = (['<'])]])
cmd([[
  autocmd Filetype tex inoremap $ $$<ESC>i
  autocmd Filetype markdown inoremap <C-b> ****<ESC>i<Left>
  autocmd Filetype markdown inoremap ^ ^{}<Left>
  autocmd Filetype markdown inoremap _ _{}<Left>
  autocmd Filetype tex inoremap ^ ^{}<Left>
  autocmd Filetype tex inoremap _ _{}<Left>
  autocmd Filetype markdown vnoremap <C-f> xi$$<ESC>hp
]])

-- 内置终端
api.nvim_set_keymap('n', '<F3>', ':belowright term <CR>', { noremap = true })
api.nvim_set_keymap('n',',/', ':set nohlsearch<CR>', { noremap = true})
api.nvim_set_keymap('n','\\/', ':set !make<CR>', { noremap = true})

-- filetype issue
cmd([[autocmd BufNewFile,BufRead *.wxss set filetype=css]])
cmd([[autocmd BufNewFile,BufRead *.wxml set filetype=html]])

