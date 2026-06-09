{ pkgs, ... }:
let
  weztermWithNixGL = pkgs.writeShellScriptBin "wezterm" ''
    exec ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.wezterm}/bin/wezterm "$@"
  '';
in
{
  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;

  home.packages = [
    weztermWithNixGL
  ];
}
