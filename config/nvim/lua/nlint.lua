require("lint").linters_by_ft = {
	python = { "pylint" },
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

local linters = require("lint").linters

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
local lint_progress = function()
  local linters = require("lint").get_running()
  if #linters == 0 then
      return "󰦕"
  end
  return "󱉶 " .. table.concat(linters, ", ")
end
