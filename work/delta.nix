
{ ... }:
{
  programs.delta = {
    enable = true;
  };

  programs.git.settings = {
    core.pager = "less --mouse";
    delta = {
      features = "zebra-dark";
      line-numbers = "true";
    };
  };
}
