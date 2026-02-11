
{ ... }:
{
  programs.delta = {
    enable = true;
  };

  programs.git.settings = {
    core.pager = "delta";
    delta = {
      features = "zebra-dark";
      line-numbers = "true";
    };
  };
}
