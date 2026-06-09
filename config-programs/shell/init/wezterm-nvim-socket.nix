{ pkgs, ... }:
let
  weztermTabId = pkgs.writeText "wezterm-tab-id.py" (builtins.readFile ./scripts/wezterm-tab-id.py);
  # Replace the placeholder in the generated zsh script with the store path of the Python helper.
  weztermNvimSocketScript = pkgs.writeText "wezterm-nvim-socket.zsh" (
    builtins.replaceStrings [ "__WEZTERM_TAB_ID__" ] [ (toString weztermTabId) ]
      (builtins.readFile ./scripts/wezterm-nvim-socket.zsh)
  );
in
{
  programs.zsh.initExtra = ''
    source ${weztermNvimSocketScript}
  '';
}
