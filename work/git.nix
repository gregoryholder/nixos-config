{ ... }:
{
  programs.git = {
    enable = false;
    aliases = {
      pick = "cherry-pick -x";
    };
    userName = "Gregory Holder";
    userEmail = "gregory.holder@equans.com";
    extraConfig = {
      diff.tool = "bc";
      http = {
        proxy = "http://ach-download-pc:5865";
        postBuffer = "524288000";
      };
      "http \"http://ach-gitlab\"".proxy = "";
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        recurseSubmodules = "check";
      };
      lfs.cachecredentials = true;
      "filter \"lfs\"" = {
        process = "git-lfs filter-process";
        required = "true";
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
      };
      merge.conflictstyle = "zdiff3";
    };
  };
}
