return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    vim.keymap.set('n', '<leader>ep', function()
      harpoon:list():prev()
    end, { desc = 'Previous File' })
    vim.keymap.set('n', '<leader>en', function()
      harpoon:list():next()
    end, { desc = 'Next File' })
    vim.keymap.set('n', '<leader>ea', function()
      harpoon:list():add()
    end, { desc = 'Add file' })

    vim.keymap.set('n', '<leader>et', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Toggle list' })
  end,
}
