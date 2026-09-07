{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fnm
  ];

  programs.zsh.initExtra = ''
    eval "$(fnm env --shell zsh)"
  '';
}

