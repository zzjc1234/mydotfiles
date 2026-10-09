require("lazy").setup({
	--Themes
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = true,
		event = "BufWinEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		lazy = true,
		event = "BufWinEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"akinsho/bufferline.nvim",
		lazy = true,
		event = "BufWinEnter",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = false,
	},
	{
		"nvim-zh/colorful-winsep.nvim",
		config = true,
		event = "VeryLazy",
	},
	{
		"folke/noice.nvim",
		commit = "cf758e9",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			{
				"rcarriga/nvim-notify",
				commit = "a3020c2",
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = false,
		lazy = false,
		config = function()
			local ensure_installed = {
				-- 先留空，避免继续触发你前面那些安装失败
				-- "python",
				-- "bash",
				-- "json",
				-- "yaml",
				-- "toml",
			}

			if #ensure_installed == 0 then
				return
			end

			local ok_config, ts_config = pcall(require, "nvim-treesitter.config")
			local ok_ts, ts = pcall(require, "nvim-treesitter")

			if not ok_config or not ok_ts then
				return
			end

			local installed = ts_config.get_installed()
			local to_install = vim.iter(ensure_installed)
				:filter(function(parser)
					return not vim.tbl_contains(installed, parser)
				end)
				:totable()

			if #to_install > 0 then
				ts.install(to_install)
			end
		end,
	},

	--Compeletion
	{
		"honza/vim-snippets",
		lazy = true,
		event = "InsertEnter",
	},
	{
		"lervag/vimtex",
		lazy = true,
	},

	--Coding
	{
		"williamboman/mason.nvim",
		event = "VeryLazy",
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
	},
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
	},
	{ "barreiroleo/ltex_extra.nvim", ft = { "markdown", "tex", "txt" }, event = { "BufReadPre", "BufNewFile" } },
	{ "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
	{ "hrsh7th/cmp-buffer", event = "InsertEnter" },
	{ "hrsh7th/cmp-path", event = "InsertEnter" },
	{ "hrsh7th/cmp-cmdline", event = "InsertEnter" },
	{ "hrsh7th/nvim-cmp", event = "InsertEnter" },
	{ "hrsh7th/cmp-vsnip", event = "InsertEnter" },
	{ "uga-rosa/cmp-dictionary", event = "InsertEnter" },
	{ "hrsh7th/vim-vsnip", event = "InsertEnter" },
	{ "rafamadriz/friendly-snippets", event = "InsertEnter" },
	{ "onsails/lspkind-nvim", event = "InsertEnter" },
	{
		"windwp/nvim-autopairs",
		config = true,
		event = "InsertEnter",
	},
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
	},
	{
		"mhartington/formatter.nvim",
		lazy = true,
	},
	{
		"hedyhli/outline.nvim",
		lazy = true,
		cmd = "Outline",
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		lazy = true,
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
	},
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = "BufWinEnter",
	},

	--AI
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {
			terminal_cmd = "env https_proxy=http://127.0.0.1:1087 /Users/zhouzhaojiacheng/.local/bin/claude --dangerously-skip-permissions",
			terminal = {
				provider = "native",
				split_side = "right",
				split_width_percentage = 0.50,
			},
		},
		keys = {
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject diff" },
		},
	},

	--Tools
	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {
			-- add options here
			-- or leave it empty to use the default settings
		},
		keys = {
			-- suggested keymap
			{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
	},
	{ "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },
	{
		"folke/edgy.nvim",
		---@module 'edgy'
		---@param opts Edgy.Config
		opts = function(_, opts)
			for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
				opts[pos] = opts[pos] or {}
				table.insert(opts[pos], {
					ft = "snacks_terminal",
					size = { height = 0.4 },
					title = "%{b:snacks_terminal.id}: %{b:term_title}",
					filter = function(_buf, win)
						return vim.w[win].snacks_win
							and vim.w[win].snacks_win.position == pos
							and vim.w[win].snacks_win.relative == "editor"
							and not vim.w[win].trouble_preview
					end,
				})
			end
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
	},
	-- {
	-- 	"nvim-treesitter/nvim-treesitter-textobjects",
	-- 	lazy = true,
	-- 	event = "BufWinEnter",
	-- },
	{
		"FabijanZulj/blame.nvim",
		config = function()
			require("blame").setup({})
		end,
		cmd = "BlameToggle",
		lazy = true,
	},
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({})
		end,
		event = "VeryLazy",
		lazy = true,
	},
	{
		"3rd/image.nvim",
		build = false,
		config = function()
			-- ...
		end,
		event = { "InsertEnter", "VeryLazy" },
		lazy = true,
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
		cmd = "ToggleTerm",
		lazy = true,
	},
	{
		"folke/flash.nvim",
		lazy = true,
	},
	{
		"folke/which-key.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = "nvim-lua/plenary.nvim",
		lazy = true,
	},
	{
		"makerj/vim-pdf",
		lazy = true,
	},
	{
		"jvgrootveld/telescope-zoxide",
		lazy = true,
		event = "VeryLazy",
	},
	{
		"mg979/vim-visual-multi",
		lazy = true,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		-- event = "VeryLazy",
	},
})
