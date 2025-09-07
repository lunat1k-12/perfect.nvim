-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['J'] = function(state) -- Press "J" in Neo-tree to create a Java class
            local node = state.tree:get_node()
            local path = node.type == 'directory' and node.path or vim.fn.fnamemodify(node.path, ':h')

            vim.ui.input({ prompt = 'Java class name: ' }, function(input)
              if not input or input == '' then
                return
              end

              -- Ensure .java extension
              local filename = input:match '%.java$' and input or (input .. '.java')
              local filepath = path .. '/' .. filename

              -- Class name (remove .java)
              local classname = filename:gsub('%.java$', '')

              -- Try to infer package name from relative path
              local cwd = vim.fn.getcwd()
              local relpath = filepath:gsub('^' .. cwd .. '/?', '')
              local pkg = relpath:match('src/main/java/(.*)/' .. classname .. '%.java$')
              pkg = pkg and pkg:gsub('/', '.') or ''

              local lines = {}
              if pkg ~= '' then
                table.insert(lines, 'package ' .. pkg .. ';')
                table.insert(lines, '')
              end
              table.insert(lines, 'public class ' .. classname .. ' {')
              table.insert(lines, '')
              table.insert(lines, '}')

              -- Write file
              vim.fn.writefile(lines, filepath)

              -- Open it in a new buffer
              vim.cmd('edit ' .. filepath)
            end)
          end,
        },
      },
    },
  },
}
