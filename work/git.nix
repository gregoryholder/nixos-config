{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Gregory Holder";
    userEmail = "gregory.holder@equans.com";
    extraConfig = {
      http = {
        proxy = "http://ach-download-pc:5865";
        postBuffer = "524288000";
      };
      "http \"http://ach-gitlab\"".proxy = "";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
