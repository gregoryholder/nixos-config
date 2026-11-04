{ pkgs, ... }:
let
  terminalTabId = pkgs.writeText "terminal-tab-id.py" (builtins.readFile ./scripts/wezterm-tab-id.py);
  # Replace the placeholder in the generated zsh script with the store path of the Python helper.
  terminalNvimSocketScript = pkgs.writeText "terminal-nvim-socket.zsh" (
    builtins.replaceStrings
      [ "__WEZTERM_TAB_ID__" "__KITTY_TAB_ID__" ]
      [ (toString terminalTabId) (toString terminalTabId) ]
      (builtins.readFile ./scripts/wezterm-nvim-socket.zsh)
  );
in
{
  programs.zsh.initContent = ''
    source ${terminalNvimSocketScript}
  '';
}
