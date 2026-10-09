vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

require("lint").linters_by_ft = {
	python = { "ruff" },
	c = { "cpplint" },
	cpp = { "cpplint" },
	golang = { "golangcilint" },
	markdown = { "markdownlint" },
}

local go = require("lint.linters.golangcilint")
go.append_fname = true
go.args = {
	"run",
	"--enable=gosec,gocritic,gofumpt,gofmt,goimports",
	"--exclude='gosec:G601'",
	"--out-format",
	"json",
	"-",
}

require("lint").linters.cpplint.cmd = "cpplint"
require("lint").linters.cpplint.args = {
	"--linelength=120",
	"--filter=-legal,-readability/casting,-whitespace,-runtime/printf,-runtime/threadsafe_fn,-readability/todo,-build/include_subdir,-build/header_guard",
}

local python = require("lint").linters
python.cmd = { "ruff" }
python.args = {
	"check",
	"--output-format",
	"json",
	"-",
}

local lint_progress = function()
	local linters = require("lint").get_running()
	if #linters == 0 then
		return "󰦕"
	end
	return "󱉶 " .. table.concat(linters, ", ")
end
