local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
local lspkind = require("lspkind")
local cmp = require("cmp")

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	-- 指定 snippet 引擎
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	-- 来源
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "vsnip" },
	}, { { name = "buffer" }, { name = "path" } }),
	mapping = {
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		}),

		["<Tab>"] = function(fallback)
			if not cmp.select_next_item() then
				if vim.bo.buftype ~= "prompt" and has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end
		end,

		["<S-Tab>"] = function(fallback)
			if not cmp.select_prev_item() then
				if vim.bo.buftype ~= "prompt" and has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end
		end,

		["<Down>"] = function(fallback)
			if not cmp.select_next_item() then
				if vim.bo.buftype ~= "prompt" and has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end
		end,

		["<Up>"] = function(fallback)
			if not cmp.select_prev_item() then
				if vim.bo.buftype ~= "prompt" and has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end
		end,
	},

	-- 使用lspkind-nvim显示类型图标
	formatting = {
		format = lspkind.cmp_format({
			with_text = true, -- do not show text alongside icons
			maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
			before = function(entry, vim_item)
				-- Source 显示提示来源
				vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
				return vim_item
			end,
		}),
	},
})

vim.api.nvim_set_keymap("i", "<C-j>", [[vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>']], { expr = true })
vim.api.nvim_set_keymap("s", "<C-j>", [[vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>']], { expr = true })
vim.api.nvim_set_keymap("i", "<C-k>", [[vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>']], { expr = true })
vim.api.nvim_set_keymap("s", "<C-k>", [[vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>']], { expr = true })

-- If you want insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
