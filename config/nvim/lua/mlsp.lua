require('mason').setup()
require("mason-lspconfig").setup({
                -- These were added as a test to see it it would enable LSP on first launch
                automatic_enable = false,
                ensure_installed = { "lua_ls" }
            })
