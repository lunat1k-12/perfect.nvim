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
    vim.keymap.set('n', '<leader>oi', jdtls.organize_imports, opts)
    vim.keymap.set('n', '<leader>ev', jdtls.extract_variable, opts)
    vim.keymap.set('v', '<leader>em', jdtls.extract_method, opts)
    vim.keymap.set('n', '<leader>tc', jdtls.test_class, opts)
    vim.keymap.set('n', '<leader>tm', jdtls.test_nearest_method, opts)
    vim.keymap.set('n', '<leader>cx', vim.diagnostic.open_float, opts)
  end,
}
