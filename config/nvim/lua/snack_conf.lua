vim.g.snacks_animate = false
require("snacks").setup({
	animate = {
		enabled = false,
	},
	bigfile = {
		enabled = true,
		notify = true, -- show notification when big file detected
		size = 1.5 * 1024 * 1024, -- 1.5MB
		line_length = 1000, -- average line length (useful for minified files)
		-- Enable or disable features when big file detected
		---@param ctx {buf: number, ft:string}
		setup = function(ctx)
			if vim.fn.exists(":NoMatchParen") ~= 0 then
				vim.cmd([[NoMatchParen]])
			end
			Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
			vim.b.minianimate_disable = true
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(ctx.buf) then
					vim.bo[ctx.buf].syntax = ctx.ft
				end
			end)
		end,
	},
	terminal = {
		enabled = true,
		bo = {
			filetype = "snacks_terminal",
		},
		wo = {},
		keys = {
			q = "hide",
			gf = function(self)
				local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
				if f == "" then
					Snacks.notify.warn("No file under cursor")
				else
					self:hide()
					vim.schedule(function()
						vim.cmd("e " .. f)
					end)
				end
			end,
			term_normal = {
				"<esc>",
				function(self)
					self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
					if self.esc_timer:is_active() then
						self.esc_timer:stop()
						vim.cmd("stopinsert")
					else
						self.esc_timer:start(200, 0, function() end)
						return "<esc>"
					end
				end,
				mode = "t",
				expr = true,
				desc = "Double escape to normal mode",
			},
		},
	},
	image = {
		enabled = true,
		formats = {
			"png",
			"jpg",
			"jpeg",
			"gif",
			"bmp",
			"webp",
			"tiff",
			"heic",
			"avif",
			"mp4",
			"mov",
			"avi",
			"mkv",
			"webm",
			"pdf",
		},
		force = false, -- try displaying the image, even if the terminal does not support it
		doc = {
			-- enable image viewer for documents
			-- a treesitter parser must be available for the enabled languages.
			enabled = true,
			-- render the image inline in the buffer
			-- if your env doesn't support unicode placeholders, this will be disabled
			-- takes precedence over `opts.float` on supported terminals
			inline = true,
			-- render the image in a floating window
			-- only used if `opts.inline` is disabled
			float = true,
			max_width = 80,
			max_height = 40,
			-- Set to `true`, to conceal the image text when rendering inline.
			-- (experimental)
			---@param lang string tree-sitter language
			---@param type snacks.image.Type image type
			conceal = function(lang, type)
				-- only conceal math expressions
				return type == "math"
			end,
		},
		img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
		-- window options applied to windows displaying image buffers
		-- an image buffer is a buffer with `filetype=image`
		wo = {
			wrap = false,
			number = false,
			relativenumber = false,
			cursorcolumn = false,
			signcolumn = "no",
			foldcolumn = "0",
			list = false,
			spell = false,
			statuscolumn = "",
		},
		cache = vim.fn.stdpath("cache") .. "/snacks/image",
		debug = {
			request = false,
			convert = false,
			placement = false,
		},
		env = {},
		-- icons used to show where an inline image is located that is
		-- rendered below the text.
		icons = {
			math = "󰪚 ",
			chart = "󰄧 ",
			image = " ",
		},
		---@class snacks.image.convert.Config
		convert = {
			notify = true, -- show a notification on error
			---@type snacks.image.args
			mermaid = function()
				local theme = vim.o.background == "light" and "neutral" or "dark"
				return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}" }
			end,
			---@type table<string,snacks.image.args>
			magick = {
				default = { "{src}[0]", "-scale", "1920x1080>" }, -- default for raster images
				vector = { "-density", 192, "{src}[0]" }, -- used by vector images like svg
				math = { "-density", 192, "{src}[0]", "-trim" },
				pdf = { "-density", 192, "{src}[0]", "-background", "white", "-alpha", "remove", "-trim" },
			},
		},
		math = {
			enabled = true, -- enable math expression rendering
			-- in the templates below, `${header}` comes from any section in your document,
			-- between a start/end header comment. Comment syntax is language-specific.
			-- * start comment: `// snacks: header start`
			-- * end comment:   `// snacks: header end`
			typst = {
				tpl = [[
        #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
        #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
        #set text(size: 12pt, fill: rgb("${color}"))
        ${header}
        ${content}]],
			},
			latex = {
				font_size = "Large", -- see https://www.sascha-frank.com/latex-font-size.html
				-- for latex documents, the doc packages are included automatically,
				-- but you can add more packages here. Useful for markdown documents.
				packages = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools" },
				tpl = [[
        \documentclass[preview,border=0pt,varwidth=1000pt,12pt]{standalone}
        \usepackage{${packages}}
        \begin{document}
        ${header}
        { \${font_size} \selectfont
          \color[HTML]{${color}}
        ${content}}
        \end{document}]],
			},
		},
	},
	picker = { enabled = true },
	git = { enabled = true },
	indent = { enabled = true },
	input = {
		enabled = true,
		icon = " ",
		icon_hl = "SnacksInputIcon",
		icon_pos = "left",
		prompt_pos = "title",
		win = { style = "input" },
		expand = true,
		backdrop = false,
		position = "float",
		border = "rounded",
		title_pos = "center",
		height = 1,
		width = 60,
		relative = "editor",
		noautocmd = true,
		row = 2,
		wo = {
			winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
			cursorline = false,
		},
		bo = {
			filetype = "snacks_input",
			buftype = "prompt",
		},
		--- buffer local variables
		b = {
			completion = false, -- disable blink completions in input
		},
		keys = {
			n_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "n", expr = true },
			i_esc = { "<esc>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
			i_cr = { "<cr>", { "cmp_accept", "confirm" }, mode = { "i", "n" }, expr = true },
			i_tab = { "<tab>", { "cmp_select_next", "cmp" }, mode = "i", expr = true },
			i_ctrl_w = { "<c-w>", "<c-s-w>", mode = "i", expr = true },
			i_up = { "<up>", { "hist_up" }, mode = { "i", "n" } },
			i_down = { "<down>", { "hist_down" }, mode = { "i", "n" } },
			q = "cancel",
		},
	},
	notifier = {
		enabled = true,
		timeout = 3000, -- default timeout in ms
		width = { min = 40, max = 0.4 },
		height = { min = 1, max = 0.6 },
		-- editor margin to keep free. tabline and statusline are taken into account automatically
		margin = { top = 0, right = 1, bottom = 0 },
		padding = true, -- add 1 cell of left/right padding to the notification window
		sort = { "level", "added" }, -- sort by level and time
		-- minimum log level to display. TRACE is the lowest
		-- all notifications are stored in history
		level = vim.log.levels.TRACE,
		icons = {
			error = " ",
			warn = " ",
			info = " ",
			debug = " ",
			trace = " ",
		},
		keep = function(notif)
			return vim.fn.getcmdpos() > 0
		end,
		---@type snacks.notifier.style
		style = "compact",
		top_down = true, -- place notifications from top to bottom
		date_format = "%R", -- time format for notifications
		-- format for footer when more lines are available
		-- `%d` is replaced with the number of lines.
		-- only works for styles with a border
		---@type string|boolean
		more_format = " ↓ %d lines ",
		refresh = 50, -- refresh at most every 50ms
	},
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	dashboard = {
		enabled = true,
		width = 60,
		row = nil,
		col = nil,
		pane_gap = 4,
		autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
		preset = {
			pick = nil,
			keys = {
				{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
				{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
				{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{ icon = " ", key = "S", desc = "Schedule", action = ":e ~/Dropbox/org/refile.md" },
				{
					icon = " ",
					key = "c",
					desc = "Config",
					action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
				},
				{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
				{ icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
			header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
		},
		formats = {
			icon = function(item)
				if item.file and (item.icon == "file" or item.icon == "directory") then
					local icon = ""
					local hl = "Normal"
					if item.icon == "directory" then
						icon = ""
					end
					return { icon, width = 2, hl = hl }
				end
				return { item.icon, width = 2, hl = "icon" }
			end,
			footer = { "%s", align = "center" },
			header = { "%s", align = "center" },
			file = function(item, ctx)
				local fname = vim.fn.fnamemodify(item.file, ":~")
				fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
				if #fname > ctx.width then
					local dir = vim.fn.fnamemodify(fname, ":h")
					local file = vim.fn.fnamemodify(fname, ":t")
					if dir and file then
						file = file:sub(-(ctx.width - #dir - 2))
						fname = dir .. "/…" .. file
					end
				end
				local dir, file = fname:match("^(.*)/(.+)$")
				return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
			end,
		},
		sections = {
			{ section = "header" },
			{
				pane = 2,
				section = "terminal",
				cmd = vim.fn.expand("~/.tools/square"),
				height = 5,
				padding = 1,
			},
			{ section = "keys", gap = 1, padding = 1 },
			{ pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
			{ pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
			{
				pane = 2,
				icon = " ",
				title = "Git Status",
				section = "terminal",
				enabled = function()
					return require("snacks").git.get_root() ~= nil
				end,
				cmd = "git status --short --branch --renames",
				height = 5,
				padding = 1,
				ttl = 5 * 60,
				indent = 3,
			},
			{ section = "startup" },
		},
	},
})

vim.keymap.set("n", "<leader>b.", function()
	Snacks.bufdelete.delete()
end, { desc = "Delete current buffer" })
vim.keymap.set("n", "<leader>bo", function()
	Snacks.bufdelete.other()
end, { desc = "Delete all other buffer" })
vim.keymap.set("n", "<leader>hs", function()
	Snacks.notifier.show_history()
end, { desc = "Show notifications" })
vim.keymap.set("n", "<leader>n", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss all notifications" })

vim.keymap.set("n", "<leader>gb", function()
	Snacks.picker.git_branches()
end, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, { desc = "Git Log" })
vim.keymap.set("n", "<leader>gL", function()
	Snacks.picker.git_log_line()
end, { desc = "Git Log Line" })
vim.keymap.set("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gS", function()
	Snacks.picker.git_stash()
end, { desc = "Git Stash" })
vim.keymap.set("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Git Diff (Hunks)" })
vim.keymap.set("n", "<leader>gf", function()
	Snacks.picker.git_log_file()
end, { desc = "Git Log File" })
vim.keymap.set("n", "<leader>ss", function()
	Snacks.picker.lsp_symbols()
end, { desc = "LSP Symbols" })
vim.keymap.set("n", "<leader>sS", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })
vim.keymap.set("n", "<c-/>", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })
vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })

local snacks = require("snacks")

local uv = vim.loop

function OpenEditableSnackWindow()
	vim.ui.input({ prompt = "Enter file path: " }, function(path)
		if not path or path == "" then
			vim.notify("No file path provided", vim.log.levels.WARN)
			return
		end

		-- 创建 buffer
		local buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_name(buf, path)
		vim.bo[buf].buftype = "" -- 重要！可编辑
		vim.bo[buf].filetype = vim.filetype.match({ filename = path }) or "text"

		-- 如果文件存在，则读取
		if uv.fs_stat(path) then
			local fd = assert(io.open(path, "r"))
			local lines = {}
			for line in fd:lines() do
				table.insert(lines, line)
			end
			fd:close()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		end

		-- 创建 snacks window
		local win = snacks.win({
			title = "Editing: " .. vim.fn.fnamemodify(path, ":t"),
			buf = buf,
			fixbuf = true,
			show = true,
			relative = "editor",
			position = "float",
			backdrop = 60,
			width = 0.6,
			height = 0.6,
			border = "rounded",
			zindex = 50,
			wo = {
				winhighlight = "Normal:SnacksNormal,NormalNC:SnacksNormalNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC",
			},
			bo = {
				bufhidden = "wipe",
			},
			keys = {
				q = "close",
			},
		})

		-- 关键：设置当前窗口为新建的 snacks window
		vim.api.nvim_set_current_win(win)

		-- 允许 :w
		vim.cmd("buffer " .. buf)
	end)
end

vim.api.nvim_create_user_command("Fedit", OpenEditableSnackWindow, {})

vim.keymap.set("n", "<leader>.", function()
	Snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })
vim.keymap.set("n", "<leader>S", function()
	Snacks.scratch.select()
end, { desc = "Select Scratch Buffer" })

function RunShellSimple()
	vim.ui.input({ prompt = "Shell > " }, function(input)
		if input and input ~= "" then
			local output = vim.fn.system(input)
			print(output)
		else
			print("No command entered.")
		end
	end)
end

vim.api.nvim_create_user_command("ShellSimple", RunShellSimple, {})

local function enable_math_conceal()
	if vim.tbl_contains({ "markdown", "tex", "plaintex", "latex" }, vim.bo.filetype) then
		vim.wo.conceallevel = 2
		vim.wo.concealcursor = "nc"
	end
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
	group = vim.api.nvim_create_augroup("math_formula_conceal", { clear = true }),
	callback = enable_math_conceal,
})

enable_math_conceal()
