{ ... }:
{
  programs.zsh.initExtra = ''
    source ${./keybindings.zsh}
  '';
}
