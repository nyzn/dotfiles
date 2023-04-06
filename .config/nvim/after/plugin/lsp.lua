-- comment lsp zero config for CoC 

-- local lsp = require("lsp-zero")
-- local cmp = require('cmp')
-- local cmp_action = require('lsp-zero').cmp_action()

-- lsp.preset("recommended")

-- lsp.ensure_installed({
--   'tsserver', -- ts und js
--   'eslint',
--   'jdtls', -- java
--   'sqlls', -- sql
--   'jsonls', --json 
--   'graphql',
--   'html',
--   'cssls',
--   'tailwindcss',
--   'yamlls',
--   'lemminx', --xml
--   'rust_analyzer'
--   -- 'lua_ls'
-- })

-- -- Fix Undefined global 'vim'
-- lsp.configure('lua_ls', {
--     settings = {
--         Lua = {
--             diagnostics = {
--                 globals = { 'vim' }
--             }
--         }
--     }
-- })

-- local cmp_select = {behavior = cmp.SelectBehavior.Select}
-- local cmp_mappings = lsp.defaults.cmp_mappings({
--   ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
--   ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
--   ['<C-y>'] = cmp.mapping.confirm({ select = true }),
--   ["<C-Space>"] = cmp.mapping.complete(),
-- })

-- cmp.setup({
--   mapping = {
--     ['<Tab>'] = cmp_action.luasnip_supertab(),
--     ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
--   }
-- })

-- lsp.setup_nvim_cmp({
--   mapping = cmp_mappings
-- })

-- lsp.set_preferences({
--     suggest_lsp_servers = false,
--     sign_icons = {
--         error = 'E',
--         warn = 'W',
--         hint = 'H',
--         info = 'I'
--     }
-- })

-- lsp.on_attach(function(client, bufnr)
--   local opts = {buffer = bufnr, remap = false}

--   vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
--   vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
--   vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
--   vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
--   vim.keymap.set("n", "<leader><cr>", function() vim.lsp.buf.code_action() end, opts)
-- end)

-- lsp.setup()

-- vim.diagnostic.config({
--     virtual_text = true
-- })
