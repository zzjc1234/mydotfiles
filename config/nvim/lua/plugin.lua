require("lazy").setup({
	--Themes
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"catppuccin/nvim", name = "catppuccin", priority = 1000
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons"
		},
	},
	{
		'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = false,
	},
	{
		'goolord/alpha-nvim',
		lazy = false,
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	},
	{
		"nvim-zh/colorful-winsep.nvim",
		config = true,
		event = { "WinNew" },
	},
	{
		'folke/twilight.nvim',
		event = "VeryLazy",
	},
	{
		"folke/noice.nvim",
		event="VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		}
	},


	--highlight
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
	},

	--Compeletion
	{
		"neoclide/coc.nvim",
		branch = "release",
		lazy = false,
	},
	{
		"honza/vim-snippets",
	},
	{
		"lervag/vimtex",
	},

	--Coding
	{
		'preservim/tagbar',
	},
	{
		'folke/todo-comments.nvim',
	},
	{
		'numToStr/Comment.nvim',
		lazy = true,
	},
	{
		'mfussenegger/nvim-dap',
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {"mfussenegger/nvim-dap"},
	},

	--orgnaization
	{
		'vimwiki/vimwiki',
		branch='dev',
		priority=1000,
	},
	{
		'tools-life/taskwiki',
		dependencies = {
			'powerman/vim-plugin-AnsiEsc',
			'blindFS/vim-taskwarrior',
		},
	},

	--Tools
	{
		'akinsho/toggleterm.nvim',
		version = "*",
		config = true,
	},
	-- {
		-- 	"easymotion/vim-easymotion",
		-- },
		{
			'folke/flash.nvim',
			lazy=false,
		},
		{
			'folke/which-key.nvim',
		},
		{
			'nvim-telescope/telescope.nvim',
			branch = '0.1.x',
			dependencies =  'nvim-lua/plenary.nvim',
		},
		{
			'folke/zen-mode.nvim',
			event = "VeryLazy",
		},
		{
			'makerj/vim-pdf'
		},
		{
			'jvgrootveld/telescope-zoxide'
		},
		{
			'mg979/vim-visual-multi'
		}
		-- {
			-- 	'Pocco81/true-zen.nvim',
			-- },
		})

