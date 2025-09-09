return {
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
