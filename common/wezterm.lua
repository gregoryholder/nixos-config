local wezterm = require 'wezterm'

local current_mode = wezterm.GLOBAL.current_mode or ""

local activations = {
  horizontal_move = true,
  vertical_move = true,
  tab_move = true
}


-- features
--  mode display
--  modes:
--   - horizontal / vertical lock
--   - tab lock



wezterm.on("update-right-status", function(window, pane)
  local mode = wezterm.GLOBAL.current_mode
  if mode and mode ~= "" then
    window:set_right_status("MODE: " .. mode)
  else
    window:set_right_status("")
  end
end)

local function clear_mode()
  return wezterm.action_callback(function(window, pane)
    wezterm.GLOBAL.current_mode = ""
  end)
end

local function set_mode(mode_name)
  return wezterm.action_callback(function(window, pane)
    wezterm.GLOBAL.current_mode = mode_name
    window:perform_action(wezterm.action.ActivateKeyTable {
      name = mode_name,
      until_unknown = true,
      one_shot = false,
      replace_current = true,
    }, pane)
  end)
end

local function smart_split(window, pane)
  local dims = pane:get_dimensions()
  if dims.pixel_width > dims.pixel_height * 1.5 then
    window:perform_action(wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }, pane)
  else
    window:perform_action(wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }, pane)
  end
end

return {
  leader = { key = 'a', mods = 'ALT', timeout_milliseconds = 1000 },

  key_tables = {
    resize_mode = {
      { key = 'h', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
      { key = 'l', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
      { key = 'k', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
      { key = 'j', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
      -- { key = 'q', action = wezterm.action.Multiple {
      --     wezterm.action.PopKeyTable,
      --     clear_mode(),
      --   }
      -- },
      { key = 'Escape', action = wezterm.action.Multiple {
          wezterm.action.PopKeyTable,
          clear_mode(),
        }
      },
    },
    tab_mode = {
      { key = 'h', action = wezterm.action.ActivateTabRelative(-1) },
      { key = 'l', action = wezterm.action.ActivateTabRelative(1) },
      { key = 'n', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
      { key = 'Escape', action = wezterm.action.Multiple {
          wezterm.action.PopKeyTable,
          clear_mode(),
        }
      },
    }
  },

  keys = {
    -- Modal resizing
    { key = 'r', mods = 'LEADER', action = set_mode('resize_mode')},
    { key = 't', mods = 'LEADER', action = set_mode('tab_mode') },

    -- Smart split with Alt+n
    { key = 'n', mods = 'ALT|SHIFT', action = wezterm.action_callback(smart_split) },

    -- Split panes manually
    { key = 'd', mods = 'ALT|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 's', mods = 'ALT|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

    -- Navigate between panes
    { key = 'h', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'l', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
    { key = 'k', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'j', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'd', mods = 'ALT|SHIFT', action = wezterm.action.CloseCurrentPane {confirm = false} },

    { key = 'h', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.ActivateTabRelative (-1) },
    { key = 'l', mods = 'CTRL|ALT|SHIFT', action = wezterm.action.ActivateTabRelative (1) },

    -- Tab management
    { key = 't', mods = 'ALT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = 'ALT', action = wezterm.action.CloseCurrentTab { confirm = true } },

    -- Toggle full screen
    { key = 'f', mods = 'ALT|SHIFT', action = wezterm.action.ToggleFullScreen },

    {
      key = 'F',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.Search({ CaseInSensitiveString = '' })
    }
  },

  enable_scroll_bar = true,

  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },

  font = wezterm.font 'FiraCode Nerd Font Mono',
  font_size = 6,

  initial_cols = 120,
  initial_rows = 48,

  -- Visual distinction between active and inactive panes
  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
  },

  window_frame = {
    active_titlebar_bg = '#1D2021',
    inactive_titlebar_bg = '#3C3836',
  },

  color_scheme = 'Raycast_Dark',
  scrollback_lines = 10000,
}
