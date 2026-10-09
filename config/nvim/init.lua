package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

require("basic")
require("wiki")
require("plugin")
require("ufo_conf")
require("theme")
require("bufferl")
require("nTree")
require("lline")
require("msn")
require("lsp")
require("which")
-- require("tso")
require("fsh")
require("nnoice")
require("snack_conf")
-- require("dash")
-- require("twli")
-- require("zen")
require("blank")
require("ts")
require("ncomment")
require("ncmp")
require("form")
vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("UIEnter", {
	once = true,
	callback = function()
		vim.defer_fn(function()
			for _, module in ipairs({
				"mlsp",
				"nlint",
				"tele",
				"togterm",
				"out_line",
				"tdcomment",
				"zici",
			}) do
				local ok, err = pcall(require, module)
				if not ok then
					vim.notify(("Failed to load %s: %s"):format(module, err), vim.log.levels.WARN)
				end
			end
		end, 100)
	end,
})
