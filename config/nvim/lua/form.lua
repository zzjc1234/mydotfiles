-- Utilities for creating configurations
local util = require "formatter.util"

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup {
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {

		c = {
			function()
				return {
					exe = "clang-format",
					args = {},
					stdin = true,
				}
			end
		},
		cpp = {
			function()
				return {
					exe = "clang-format",
					args = {
						util.escape_path(util.get_current_buffer_file_path()),
					},
					stdin = true,
				}
			end
		},
		python = {
			function()
				return {
					exe = "black",
					args = {},
					stdin = true,
				}
			end
		},
		go = {
			function ()
				return {
					exe = "gofumpt",
					args={},
					stdin=true
				}
			end
		},
		lua = {
			require("formatter.filetypes.lua").stylua,

			function()
				if util.get_current_buffer_file_name() == "special.lua" then
					return nil
				end

				return {
					exe = "stylua",
					args = {
						"--search-parent-directories",
						"--stdin-filepath",
						util.escape_path(util.get_current_buffer_file_path()),
						"--",
						"-",
					},
					stdin = true,
				}
			end
		},

		-- -- Use the special "*" filetype for defining formatter configurations on
		-- -- any filetype
		-- ["*"] = {
		-- 	-- "formatter.filetypes.any" defines default configurations for any
		-- 	-- filetype
		-- 	require("formatter.filetypes.any").remove_trailing_whitespace
		-- }
	}
}

vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>Format<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>FormatWrite<CR>', { noremap = true, silent = true })

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})
