return {
  -- Ensure needed TypeScript tools are installed via Mason
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'typescript-language-server',
        'typescript', -- local TypeScript for better project compatibility (e.g., CDK)
        'prettierd', -- fast prettier formatter (optional)
        'eslint-lsp', -- ESLint language server (optional)
      },
    },
  },

  -- Configure TypeScript/JavaScript LSPs directly
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local lspconfig = require 'lspconfig'
      local util = require 'lspconfig.util'

      -- Capabilities (enhanced if nvim-cmp is present)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if ok_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- Common on_attach for keymaps and to disable formatting (use Prettier instead)
      local on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
        end

        map('n', 'K', vim.lsp.buf.hover, 'LSP Hover')
        map('n', '<leader>cd', vim.lsp.buf.definition, 'Go to definition')
        map('n', '<leader>cr', vim.lsp.buf.references, 'References')
        map('n', '<leader>ci', vim.lsp.buf.implementation, 'Go to implementation')
        map('n', '<leader>cn', vim.lsp.buf.rename, 'Rename symbol')
        map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
        map('n', '<leader>co', function()
          vim.lsp.buf_request(0, 'workspace/executeCommand', {
            command = '_typescript.organizeImports',
            arguments = { vim.api.nvim_buf_get_name(0) },
          })
        end, 'TS Organize Imports')
      end

      -- Helpful inlay hints and preferences for large TS projects and CDK repos
      local ts_js_settings = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
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

      -- TypeScript / JavaScript LSP (typescript-language-server via ts_ls)
      lspconfig.ts_ls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = util.root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git'),
        single_file_support = true,
        filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx', 'javascript', 'javascriptreact', 'javascript.jsx' },
        init_options = { hostInfo = 'neovim' },
        settings = {
          typescript = ts_js_settings,
          javascript = ts_js_settings,
        },
      }

      -- ESLint LSP (optional but helpful for TS/JS projects)
      if lspconfig.eslint then
        -- Only configure ESLint if the language server binary is available to avoid spawn errors
        if vim.fn.executable 'vscode-eslint-language-server' == 1 then
          lspconfig.eslint.setup {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              -- Keep TS formatting disabled, ESLint provides diagnostics/code actions
              local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
              end
              map('n', '<leader>ce', vim.lsp.buf.code_action, 'ESLint code action')
            end,
            root_dir = util.root_pattern('.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', 'package.json', '.git'),
          }
        else
          -- Informational notice once per session to hint installation via Mason
          if not vim.g.__eslint_missing_notified then
            vim.g.__eslint_missing_notified = true
            vim.schedule(function()
              vim.notify(
                'ESLint LSP not found (vscode-eslint-language-server). Install via :Mason or npm i -g vscode-langservers-extracted',
                vim.log.levels.INFO
              )
            end)
          end
        end
      end
    end,
  },
}
