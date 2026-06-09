{ pkgs, ... }:
let
  lazygitNvimOpen = pkgs.writeShellScriptBin "lazygit-nvr-open" (builtins.readFile ./scripts/lazygit-nvr-open.sh);
in
{
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        edit = "lazygit-nvr-open \"{{filename}}\"";
        editAtLine = "lazygit-nvr-open \"{{filename}}\" \"{{line}}\"";
        openDirInEditor = "lazygit-nvr-open \"{{dir}}\"";
        editInTerminal = false;
        # editAtLineAndWait = "nvr --servername \"$NVIM_LISTEN_ADDRESS\" --remote-wait +\"{{line}}\" \"{{filename}}\"";
      };
    };
  };

  home.packages = [
    lazygitNvimOpen
  ];
}
