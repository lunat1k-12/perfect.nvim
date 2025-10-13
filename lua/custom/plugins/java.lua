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

    local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }

    local function attach_jdtls()
      local root_dir = require('jdtls.setup').find_root(root_markers)
      if root_dir == '' then
        return
      end

      -- Workspace dir per project
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
          '-data',
          workspace_dir,
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
            format = {
              enabled = true,
              settings = {
                -- Point to your custom XML file
                url = vim.fn.expand '~/.config/nvim/config/java-style.xml',
                profile = 'GoogleStyle', -- Can be any name
              },
            },
          },
        },
        init_options = {
          bundles = bundles,
        },
      }

      jdtls.start_or_attach(config)

      -- Setup DAP integration
      jdtls.setup_dap { hotcodereplace = 'auto' }
      if jdtls.setup_dap_main_class then
        jdtls.setup_dap_main_class {
          config_overrides = { console = 'integratedTerminal' },
        }
      end

      if jdtls.setup and jdtls.setup.add_commands then
        jdtls.setup.add_commands()
      end

      local dap_ok, dap = pcall(require, 'dap')
      if dap_ok then
        dap.configurations.java = dap.configurations.java or {}
        table.insert(dap.configurations.java, 1, {
          type = 'java',
          name = 'Debug (Attach) - Remote JVM',
          request = 'attach',
          hostName = function()
            return vim.fn.input('Host (default 127.0.0.1): ', '127.0.0.1')
          end,
          port = function()
            local input = vim.fn.input('Port (default 5005): ', '5005')
            return tonumber(input)
          end,
        })
      end

      -- Java-specific keymaps
      local opts = { noremap = true, silent = true }

      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
      vim.keymap.set('n', '<leader>co', jdtls.organize_imports, { desc = 'Organize imports' })
      vim.keymap.set('n', '<leader>cv', jdtls.extract_variable, { desc = 'Extract variable' })
      vim.keymap.set('v', '<leader>ce', jdtls.extract_method, { desc = 'Extract method' })
      vim.keymap.set('n', '<leader>ctc', jdtls.test_class, { desc = 'Test Class' })
      vim.keymap.set('n', '<leader>ctm', jdtls.test_nearest_method, { desc = 'Test Nearest method' })
      vim.keymap.set('n', '<leader>cx', vim.diagnostic.open_float, { desc = 'Show exception details' })
      vim.keymap.set('n', '<leader>cd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      vim.keymap.set('n', '<leader>ci', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
      vim.keymap.set('n', '<leader>cr', vim.lsp.buf.references, { desc = 'Find references' })
      vim.keymap.set('n', '<leader>cw', vim.lsp.buf.hover, { desc = 'Document' })
      vim.keymap.set('n', '<leader>cb', function()
        require('dap').toggle_breakpoint()
      end, { desc = 'Set breakpoint' })
    end

    -- Attach jdtls every time a Java buffer is opened
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = attach_jdtls,
    })
  end,
}
