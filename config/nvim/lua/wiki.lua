vim.g.vimwiki_key_mappings = {
  all_maps = 1,
  global = 1,
  headers = 1,
  text_objs = 1,
  table_format = 1,
  table_mappings = 0,
  lists = 1,
  links = 1,
  html = 1,
  mouse = 0,
}

vim.cmd([[
    autocmd FileType vimwiki setlocal filetype=markdown
]])


-- vim.cmd("let g:vimwiki_global_syntax=markdown")

-- vim.api.nvim_exec([[
-- augroup VimwikiRemaps
--   autocmd!
--   " unmap tab in insert mode
--   autocmd Filetype vimwiki silent! iunmap <buffer> <Tab>
--   " remap table tab mappings to M-n M-p
--   autocmd Filetype vimwiki inoremap <silent><expr><buffer> <M-n> vimwiki#tbl#kbd_tab()
--   autocmd Filetype vimwiki inoremap <silent><expr><buffer> <M-p> vimwiki#tbl#kbd_shift_tab()
--   " on enter if completion is open, complete first element otherwise use
--   " default vimwiki mapping
--   autocmd Filetype vimwiki inoremap <silent><expr><buffer> <cr> pumvisible() and coc#_select_confirm() or "<C-]><Esc>:VimwikiReturn 1 5<CR>"
-- augroup end
-- ]], false)
--
