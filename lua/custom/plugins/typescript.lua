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
}
