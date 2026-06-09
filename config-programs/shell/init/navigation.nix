{ ... }:
{
  programs.zsh.initExtra = ''
    source ${./scripts/navigation.zsh}
  '';
}
