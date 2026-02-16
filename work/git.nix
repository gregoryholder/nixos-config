{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      alias = {
        pick = "cherry-pick -x";
        rinse = "!git submodule foreach --recursive git clean -xfd && git submodule sync --recursive && git restore . --recurse-submodules";
      };
      user.name = "Gregory Holder";
      user.email = "gregory.holder@equans.com";
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
      core = {
        editor = "nvim";
      };
      submodule.recurse = "true";
    };
  };
}
