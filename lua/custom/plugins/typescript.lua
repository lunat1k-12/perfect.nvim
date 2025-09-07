return {
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'typescript-language-server',
        'prettier', -- optional for formatting
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        tsserver = {
          -- optional: disable tsserver formatting if using prettier/eslint
          settings = {
            completions = { completeFunctionCalls = true },
          },
        },
      },
    },
  },
}
