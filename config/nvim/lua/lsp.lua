-- local lspconfig_util = require("lspconfig.util")

vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--clang-tidy",
		"--clang-tidy-checks=*",
		"-j=2",
		"--header-insertion=never",
		"--query-driver=/usr/bin/clang",
		"--background-index",
		"--all-scopes-completion",
		"--cross-file-rename",
		"--completion-style=detailed",
	},
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
	},
	init_options = {
		fallbackFlags = {
			"-Wall",
			"-Wextra",
			-- "-Werror",
			"-pedantic",
			"-Wno-unused-result",
			"-Wconversion",
			"-Wvla",
		},
	},
	filetypes = { "c", "cpp" },
})
vim.lsp.enable("clangd")
-- lspconfig.clangd.setup({
-- 	cmd = {
-- 		"clangd",
-- 		"--clang-tidy",
-- 		"--header-insertion=never",
-- 		"--query-driver=/opt/homebrew/opt/llvm/bin/clang",
-- 		"--all-scopes-completion",
-- 		"--completion-style=detailed",
-- 	},
--
-- 	init_options = {
-- 		fallbackFlags = {
-- 			"-std=gnu17",
-- 			"-Wall",
-- 			"-Wextra",
-- 			-- "-Werror",
-- 			"-pedantic",
-- 			"-Wno-unused-result",
-- 			"-Wconversion",
-- 			"-Wvla",
-- 		},
-- 	},
-- 	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
-- })

vim.lsp.config("protols", {})
vim.lsp.enable("protols")

vim.lsp.config("tinymist", {
	settings = {
		formatterMode = "typstyle",
		exportPdf = "onType",
		semanticTokens = "disable",
	},
})
vim.lsp.enable("tinymist")

-- vim.lsp.config("verible", {
-- 	cmd = { "verible-verilog-ls" },
-- 	filetypes = { "systemverilog", "verilog" },
-- 	root_dir = lspconfig_util.find_git_ancestor,
-- })
-- vim.lsp.enable("verible")
vim.lsp.config("verible", {
	cmd = { "verible-verilog-ls" },
	filetypes = { "systemverilog", "verilog" },
	root_markers = {
		".git",
	},
})
vim.lsp.enable("verible")

-- vim.lsp.enable("volar")
-- vim.lsp.config("volar", {
-- 	-- 定义 Volar 服务器的启动命令。
-- 	-- 当通过 Mason 安装 vue-language-server 后，lspconfig 会自动找到其可执行文件。
-- 	cmd = { "vue-language-server", "--stdio" },
--
-- 	-- 语言服务器应该响应的文件类型
-- 	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
--
-- 	-- 项目根目录的标记，用于 lspconfig 查找项目根目录
-- 	root_markers = { "package.json" },
--
-- 	-- Volar 的初始化选项
-- 	init_options = {
-- 		vue = {
-- 			hybridMode = false, -- 设置为非混合模式，Volar 将管理所有部分，包括 TypeScript
-- 		},
-- 		typescript = {
-- 			tsdk = "", -- TypeScript SDK 路径，由 before_init 动态设置
-- 		},
-- 	},
--
-- 	-- 在 LSP 客户端启动前执行的函数，用于动态设置 tsdk 路径
-- 	before_init = function(_, config)
-- 		-- 如果 init_options 中没有设置 tsdk，则尝试自动检测 TypeScript 服务器路径
-- 		if config.init_options and config.init_options.typescript and config.init_options.typescript.tsdk == "" then
-- 			config.init_options.typescript.tsdk = lspconfig_util.get_typescript_server_path(config.root_dir)
-- 		end
-- 	end,
-- })
-- vim.lsp.enable("volar")
vim.lsp.config("volar", {
	cmd = { "vue-language-server", "--stdio" },
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	root_markers = { "package.json", ".git" },

	init_options = {
		vue = {
			hybridMode = false,
		},
		typescript = {
			tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
		},
	},
})
vim.lsp.enable("volar")

vim.lsp.config("ltex", {
	on_attach = function(client, bufnr)
		require("ltex_extra").setup({
			load_langs = { "en-US" },
			path = vim.fn.expand("~") .. "/.local/share/ltex",
			init_check = true,
		})
	end,
	settings = {
		ltex = {
			completionEnabled = true,
			language = "en-US",
		},
	},
	filetypes = { "markdown", "tex", "txt" },
})
vim.lsp.enable("ltex")

vim.lsp.config("texlab", {})
vim.lsp.enable("texlab")

vim.lsp.config("gopls", {})
vim.lsp.enable("gopls")

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
vim.lsp.enable("lua_ls")

-- vim.lsp.config("pyright", {
-- 	root_dir = lspconfig_util.find_git_ancestor,
-- })
-- vim.lsp.enable("pyright")
vim.lsp.config("pyright", {
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
})
vim.lsp.enable("pyright")

-- vim.lsp.enable("rust_analyzer")
-- vim.lsp.config("rust_analyzer", {
-- 	-- Server-specific settings. See `:help lsp-quickstart`
-- 	settings = {
-- 		["rust-analyzer"] = {},
-- 	},
-- })

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>ca", function()
	vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
	-- or vim.lsp.buf.codeAction() if you don't want grouping.
end, { silent = true, buffer = bufnr })
vim.keymap.set(
	"n",
	"K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
	function()
		vim.cmd.RustLsp({ "hover", "actions" })
	end,
	{ silent = true, buffer = bufnr }
)

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<leader>qf", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		-- vim.keymap.set('n', '<leader>f', function()
		-- 	vim.lsp.buf.format { async = true }
		-- end, opts)
	end,
})
