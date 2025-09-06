return {
  -- LSP Config
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require 'lspconfig'
      lspconfig.gopls.setup {
        cmd = { 'gopls' },
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
          },
        },
        on_attach = function(_, bufnr)
          -- Jump to definition
          vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, { noremap = true, silent = true, buffer = bufnr, desc = 'Go to definition' })

          -- Show references
          vim.keymap.set('n', '<leader>cr', vim.lsp.buf.references, { noremap = true, silent = true, buffer = bufnr, desc = 'References' })

          -- Hover docs
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true, buffer = bufnr, desc = 'Hover docs' })

          -- Implementation
          vim.keymap.set('n', '<leader>ci', vim.lsp.buf.implementation, { noremap = true, silent = true, buffer = bufnr, desc = 'Go To implementation' })

          -- Rename symbol
          vim.keymap.set('n', '<leader>cn', vim.lsp.buf.rename, { noremap = true, silent = true, buffer = bufnr, desc = 'Rename symbol' })
        end,
      }
    end,
  },

  -- Autocompletion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },

  -- Go specific tooling
  {
    'ray-x/go.nvim',
    dependencies = { 'ray-x/guihua.lua' },
    config = function()
      require('go').setup()
    end,
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()', -- installs binaries
  },

  -- Treesitter for syntax highlighting
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
}
