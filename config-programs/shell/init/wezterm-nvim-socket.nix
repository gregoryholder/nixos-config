{ pkgs, ... }:
let
  terminalNvimSocketScript = pkgs.writeText "terminal-nvim-socket.zsh" (
    builtins.readFile ./scripts/wezterm-nvim-socket.zsh
  );
in
{
  programs.zsh.initContent = ''
    source ${terminalNvimSocketScript}
  '';
}
