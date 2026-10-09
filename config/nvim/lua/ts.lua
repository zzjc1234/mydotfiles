-- ~/.config/nvim/lua/ts.lua

-- filetype -> parser language 映射
-- .tex 的 filetype 通常是 "tex"，但 parser 名是 "latex"
vim.treesitter.language.register("latex", "tex")
vim.treesitter.language.register("latex", "plaintex")

local disabled_fts = {
	-- UI / popup / dashboard buffer 不需要 treesitter
	noice = true,
	notify = true,
	lazy = true,
	mason = true,
	snacks_dashboard = true,
	["snacks-dashboard"] = true,
	TelescopePrompt = true,
}

local max_filesize = 100 * 1024 -- 100 KB

local function is_big_file(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return false
	end

	local ok, stats = pcall(vim.uv.fs_stat, name)
	return ok and stats and stats.size > max_filesize
end

local function get_lang(bufnr)
	local ft = vim.bo[bufnr].filetype
	if ft == "" or disabled_fts[ft] then
		return nil
	end

	return vim.treesitter.language.get_lang(ft) or ft
end

local function has_parser(lang)
	if not lang or lang == "" then
		return false
	end

	return pcall(vim.treesitter.language.add, lang)
end

local function start_treesitter(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	if is_big_file(bufnr) then
		return false
	end

	local lang = get_lang(bufnr)
	if not has_parser(lang) then
		return false
	end

	return pcall(vim.treesitter.start, bufnr, lang)
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("NativeTreesitterStart", { clear = true }),
	callback = function(args)
		start_treesitter(args.buf)

		-- 按迁移指南：缩进要自己启用
		-- 这里用 nvim-treesitter main 的 indentexpr；如果模块不存在就静默跳过。
		local ok = pcall(require, "nvim-treesitter")
		if ok then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = vim.api.nvim_create_augroup("NativeTreesitterFold", { clear = true }),
	callback = function(args)
		local bufnr = args.buf

		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		if not start_treesitter(bufnr) then
			return
		end

		vim.api.nvim_set_option_value("foldmethod", "expr", {
			scope = "local",
			win = 0,
		})

		vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.treesitter.foldexpr()", {
			scope = "local",
			win = 0,
		})

		-- 默认不要自动折叠，避免打开文件时全部折起来
		vim.api.nvim_set_option_value("foldenable", false, {
			scope = "local",
			win = 0,
		})
	end,
})
