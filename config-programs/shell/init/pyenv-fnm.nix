{ ... }:
{
  programs.zsh.initExtra = ''
    source ${./scripts/pyenv-fnm.zsh}
  '';
}
