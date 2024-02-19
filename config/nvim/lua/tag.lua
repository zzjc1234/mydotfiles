vim.g.tagbar_previewwin_pos = "bottomright"
vim.api.nvim_set_keymap('n', '<leader>t', ':TagbarToggle<CR>', { noremap = true, silent = true })

--local tagbar_type_markdown = {
--    ctagsbin = 'mdctags',
--    ctagsargs = '--sort=yes',
--    kinds = {
--        'a:h1:0:0',
--        'b:h2:0:0',
--        'c:h3:0:0',
--        'd:h4:0:0',
--        'e:h5:0:0',
--        'f:h6:0:0',
--    },
--    sro = '::',
--    kind2scope = {
--        a = 'h1',
--        b = 'h2',
--        c = 'h3',
--        d = 'h4',
--        e = 'h5',
--        f = 'h6',
--    },
--    scope2kind = {
--        h1 = 'a',
--        h2 = 'b',
--        h3 = 'c',
--        h4 = 'd',
--        h5 = 'e',
--        h6 = 'f',
--    }
--}
--
--vim.g.tagbar_type_markdown = tagbar_type_markdown
--
vim.g.tagbar_autofocus=1
vim.g.tagbar_sort=0
local tagbar_type_markdown = {
    ctagsbin = 'mdctags',
    ctagsargs = '',
    kinds = {
        'a:h1:0:0',     -- 标题 1
        'b:h2:0:0',     -- 标题 1.1
        'c:h3:0:0',     -- 标题 1.1.1
        'd:h2:0:0',     -- 标题 1.2
        'e:h1:0:0',     -- 标题 2
    },
    sro = '::',
    kind2scope = {
        a = 'h1',
        b = 'h2',
		c = 'h3',
        d = 'h2',
        e = 'h1',
    },
    scope2kind = {
        h1 = 'a',
        h2 = 'b',
        h3 = 'c',
        h4 = 'd',
        h5 = 'e',
    }
}

vim.g.tagbar_type_markdown = tagbar_type_markdown
vim.g.tagbar_show_ballon = 0
vim.g.tagbar_silent = 1
