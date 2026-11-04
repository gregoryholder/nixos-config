{ ... }:
{
  programs.zsh.initContent = ''
    source ${./scripts/pyenv-fnm.zsh}
  '';
}
