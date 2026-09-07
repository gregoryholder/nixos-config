{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      absorb.autoStageIfNothingStaged = true;
      advice.statusHints = false;
      alias = {
        pick = "cherry-pick -x";
        rinse = "!git submodule foreach --recursive git clean -xfd && git submodule sync --recursive && git restore . --recurse-submodules";
      };
      core = {
        commentchar=";";
        # pager = "less -LRc --mouse";
        pager = "less --mouse";
      };
      # Delta diff viewer settings
      delta = {
        features = "zebra-dark";
        line-numbers = "true";
      };
      diff.tool = "bc";
      http = {
        proxy = "http://localhost:5865";
        postBuffer = "524288000";
      };
      "http \"http://ach-gitlab\"".proxy = "";
      lfs.cachecredentials = true;
      "filter \"lfs\"" = {
        process = "git-lfs filter-process";
        required = "true";
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
      };
      merge.tool = "bc";
      merge.conflictStyle = "zdiff3";
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        recurseSubmodules = "check";
      };
      user.name = "Gregory Holder";
      user.email = "gregory.holder@equans.com";
    };
  };

  programs.delta = {
    enable = true;
  };

  # Git-related tools
  home.packages = [
    pkgs.git-absorb
  ];
}
