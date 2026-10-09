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

vim.keymap.set("n", "<leader><space>", "<Plug>VimwikiToggleListItem", { buffer = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	callback = function(args)
		local filepath = args.file
		if filepath:match("%.md$") then
			vim.env.PYTHONPATH = "/Users/zhouzhaojiacheng/.venv/lib/python3.12/site-packages"
			vim.g.python3_host_prog = vim.fn.expand("/Users/zhouzhaojiacheng/.venv/bin/python")
		end
	end,
})

local function compile_latex()
	local current_dir = vim.fn.expand("%:p:h")
	local file_name = vim.fn.expand("%:t")

	vim.cmd("w!") -- Save file

	vim.system(
		{ "xelatex", "-shell-escape", "-output-directory=" .. current_dir, file_name },
		{ text = true, cwd = current_dir },
		function(obj)
			if obj.code == 0 then
				vim.notify("Compilation successful ✅", vim.log.levels.INFO)
			else
				vim.notify("Compilation failed ❌:\n" .. obj.stderr, vim.log.levels.ERROR)
			end
		end
	)
end

vim.keymap.set("n", "<Leader>l<Space>", compile_latex, { desc = "Compile LaTeX with xelatex" })
