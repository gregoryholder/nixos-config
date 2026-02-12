{ pkgs, ... }:
{
  programs.git.settings = {
      absorb.autoStageIfNothingStaged = true;
  };
  home.packages = [
    pkgs.git-absorb
    ];
}
