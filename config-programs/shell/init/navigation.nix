{ ... }:
{
  programs.zsh.initContent = ''
    source ${./scripts/navigation.zsh}
  '';
}
