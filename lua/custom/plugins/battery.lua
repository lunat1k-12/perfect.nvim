return {
  {
    'justinhj/battery.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('battery').setup {
        update_rate_seconds = 30, -- Update every 30 seconds
        show_status_when_no_battery = true, -- Show even without battery
        show_plugged_icon = true, -- Show charging icon
        show_unplugged_icon = true, -- Show discharging icon
        show_percent = true, -- Show percentage
        vertical_icons = false, -- Use vertical battery icons
        multiple_battery_selection = 1, -- Which battery to show
      }
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('lualine').setup {
        sections = {
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            -- Add battery here
            function()
              return require('battery').get_status_line()
            end,
          },
        },
      }
    end,
  },
}
