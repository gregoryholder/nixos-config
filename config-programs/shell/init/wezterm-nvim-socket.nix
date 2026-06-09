{ pkgs, ... }:
let
  weztermNvimSocketScripts = pkgs.runCommand "wezterm-nvim-socket-scripts" { } ''
    mkdir -p "$out"
    cp ${./scripts/wezterm-nvim-socket.zsh} "$out/wezterm-nvim-socket.zsh"
    cp ${./scripts/wezterm-tab-id.py} "$out/wezterm-tab-id.py"
  '';
in
{
  programs.zsh.initExtra = ''
    source ${weztermNvimSocketScripts}/wezterm-nvim-socket.zsh
  '';
}
