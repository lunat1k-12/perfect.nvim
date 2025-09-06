return {
  'mfussenegger/nvim-jdtls',
  ft = { 'java' },
  dependencies = {
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'mfussenegger/nvim-dap', -- if you want debugging
    'rcarriga/nvim-dap-ui',
  },
  config = function()
    local jdtls = require 'jdtls'
    local home = vim.fn.getenv 'HOME'

    -- Find project root
    local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
    local root_dir = require('jdtls.setup').find_root(root_markers)
    if root_dir == '' then
      return
    end

    -- Workspace directory (each project gets its own)
    local workspace_dir = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

    -- Debug/test bundles
    local bundles = {
      vim.fn.glob(home .. '/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', 1),
    }
    vim.list_extend(bundles, vim.split(vim.fn.glob(home .. '/.local/share/nvim/mason/packages/java-test/extension/server/*.jar', 1), '\n'))

    local config = {
      cmd = {
        vim.fn.expand '$HOME/.local/share/nvim/mason/bin/jdtls',
        string.format('--jvm-arg=-javaagent:%s', vim.fn.expand '$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar'),
      },
      root_dir = root_dir,
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = 'fernflower' },
          completion = {
            favoriteStaticMembers = {
              'org.mockito.Mockito.*',
              'org.springframework.*',
              'org.junit.Assert.*',
            },
          },
        },
      },
      init_options = {
        bundles = bundles,
      },
    }

    -- Start or attach JDTLS
    jdtls.start_or_attach(config)

    -- Keymaps for Java-specific actions
    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<leader>co', jdtls.organize_imports, { desc = 'Organize imports' })
    vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, { noremap = true, silent = true, desc = 'Extract variable' })
    vim.keymap.set('v', '<leader>ce', jdtls.extract_method, { noremap = true, silent = true, desc = 'Extract method' })
    vim.keymap.set('n', '<leader>ctc', jdtls.test_class, { noremap = true, silent = true, desc = 'Test Class' })
    vim.keymap.set('n', '<leader>ctm', jdtls.test_nearest_method, { noremap = true, silent = true, desc = 'Test Nearest method' })
    vim.keymap.set('n', '<leader>cx', vim.diagnostic.open_float, { desc = 'Show exception details' })
    vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, { desc = 'Go to definition' })
    vim.keymap.set('n', '<leader>ci', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
  end,
}
