return {
  'neovim/nvim-lspconfig',
  dependencies = { 'hrsh7th/cmp-nvim-lsp' },
  config = function()
    local lspconfig = require 'lspconfig'
    local util = require 'lspconfig.util'

    -- Capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if ok_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Common on_attach
    local on_attach = function(client, bufnr)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
      end

      -- Disable formatting for TS (we’ll use prettier/eslint instead)
      if client.name == 'ts_ls' or client.name == 'eslint' then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      map('n', 'K', vim.lsp.buf.hover, 'LSP Hover')
      map('n', '<leader>cd', vim.lsp.buf.definition, 'Go to definition')
      map('n', '<leader>cr', vim.lsp.buf.references, 'References')
      map('n', '<leader>ci', vim.lsp.buf.implementation, 'Go to implementation')
      map('n', '<leader>cn', vim.lsp.buf.rename, 'Rename symbol')
      map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
      map('n', '<leader>cx', vim.diagnostic.open_float, 'Show exception details')

      if client.name == 'ts_ls' then
        map('n', '<leader>co', function()
          vim.lsp.buf.execute_command {
            command = '_typescript.organizeImports',
            arguments = { vim.api.nvim_buf_get_name(0) },
          }
        end, 'TS Organize Imports')
      elseif client.name == 'gopls' then
        map('n', '<leader>co', function()
          vim.lsp.buf.code_action {
            context = { only = { 'source.organizeImports' } },
            apply = true,
          }
        end, 'Go Organize Imports')
      end
    end

    -- Go LSP
    lspconfig.gopls.setup {
      cmd = { 'gopls' },
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true,
        },
      },
    }

    -- TS/JS LSP
    local ts_js_settings = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        importModuleSpecifierPreference = 'non-relative',
        includePackageJsonAutoImports = 'auto',
        preferTypeOnlyAutoImports = true,
      },
      suggest = { completeFunctionCalls = true },
      format = { enable = false },
    }

    lspconfig.ts_ls.setup {
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = util.root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git'),
      single_file_support = true,
      filetypes = {
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'javascript',
        'javascriptreact',
        'javascript.jsx',
      },
      init_options = { hostInfo = 'neovim' },
      settings = {
        typescript = ts_js_settings,
        javascript = ts_js_settings,
      },
    }

    -- ESLint (optional)
    if vim.fn.executable 'vscode-eslint-language-server' == 1 then
      lspconfig.eslint.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = util.root_pattern('.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', 'package.json', '.git'),
      }
    end
  end,
}
