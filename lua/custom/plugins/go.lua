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
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- Jump to definition
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

          -- Show references
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

          -- Hover docs
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

          -- Implementation
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

          -- Rename symbol
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
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
