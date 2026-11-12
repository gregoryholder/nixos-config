{ pkgs, ... }:
let
  terminalNvimSource = pkgs.writeText "terminal-nvim.py" (
    builtins.readFile ./scripts/terminal-nvim.py
  );
  terminalNvim = pkgs.writeShellApplication {
    name = "terminal-nvim";
    runtimeInputs = [
      pkgs.python3
      pkgs.neovim-remote
      pkgs.lazygit
      pkgs.kitty
      pkgs.wezterm
    ];
    text = ''
      exec python3 ${terminalNvimSource} "$@"
    '';
  };
  lazygitNvimOpen = pkgs.writeShellApplication {
    name = "lazygit-nvr-open";
    runtimeInputs = [ terminalNvim ];
    text = builtins.readFile ./scripts/lazygit-nvr-open.sh;
  };
  lazygitSplit = pkgs.writeShellApplication {
    name = "lazygit-split";
    runtimeInputs = [ terminalNvim ];
    text = "exec terminal-nvim lazygit";
  };
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
      };
    };
  };

  home.packages = [
    terminalNvim
    lazygitNvimOpen
    lazygitSplit
  ];
}
