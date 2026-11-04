{ config, pkgs, ... }:
let
  kittySocket = "${config.xdg.cacheHome}/kitty.sock";
in
{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      allow_remote_control = "socket-only";
      listen_on = "unix:${kittySocket}";
      enabled_layouts = "splits,stack";
      font_size = 8.0;
      font_family = "FiraCode Nerd Font Mono";
      # inactive_text_alpha = 0.7;
      placement_strategy = "top-left";
      custom_shaders = "dim-inactive-windows";
      inactive_text_alpha = 1;
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{custom}";
    };
    keybindings = {
      "alt+shift+n" = "kitten smart_split.py";
      "alt+shift+v" = "launch --location=vsplit --cwd=current";
      "alt+shift+s" = "launch --location=hsplit --cwd=current";
      "alt+shift+t" = "new_tab_with_cwd";
      "alt+shift+d" = "close_window";
      "alt+shift+f" = "toggle_fullscreen";
      "alt+shift+h" = "neighboring_window left";
      "alt+shift+j" = "neighboring_window down";
      "alt+shift+k" = "neighboring_window up";
      "alt+shift+l" = "neighboring_window right";
      "ctrl+alt+shift+h" = "previous_tab";
      "ctrl+alt+shift+l" = "next_tab";
      "ctrl+shift+z" = "toggle_layout stack";
    };
  };

  # Split along the visually longer side (in pixels, not cells), matching wezterm's smart_split.
  xdg.configFile."kitty/smart_split.py".source = ./scripts/smart_split.py;
  xdg.configFile."kitty/tab_bar.py".source = ./scripts/tab_bar.py;

  xdg.configFile."kitty/shaders/dim-inactive-windows.pipeline".text = ''
    startgroup
        animation_step 0
        var float HIGHLIGHT_INTENSITY = 0
        var float BORDER_WIDTH = 0
        var float INACTIVE_DIM = 0.6
        var bool DIM_CENTRAL_AREA_ONLY = true
        var bool INCLUDE_WINDOW_PADDING = true
        shaders focus-highlight
    endgroup
  '';
}
