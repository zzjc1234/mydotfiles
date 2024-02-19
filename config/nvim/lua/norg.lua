require("neorg").setup ({
	load = {
		["core.defaults"] = {}, -- Loads default behaviour
		["core.concealer"] = {}, -- Adds pretty icons to your documents
		["core.export"] = {},
		["core.export.markdown"]={
			config = {
				extensions = "all",
			},
		},
		["core.keybinds"] = {},
		["core.summary"] = {},
		["core.dirman"] = { -- Manages Neorg workspaces
			config = {
				workspaces = {
					notes = "~/notes",
				},
			},
		},
	},
})

