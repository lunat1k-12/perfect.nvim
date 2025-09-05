return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {},
  config = function()
    require('toggleterm').setup {}
    vim.keymap.set('n', '<leader>tc', ':ToggleTerm size=20 direction=horizontal<CR>')
    vim.keymap.set('v', '<leader>te', function()
      require('toggleterm').send_lines_to_terminal('single_line', true, { args = vim.v.count })
    end)
  end,
}
