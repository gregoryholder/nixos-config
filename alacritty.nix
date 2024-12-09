{ ... }:
{
  programs.alacritty = {
    enable = true;

    settings = {
      font = {
        size = 9;
      };
      hints = {
        enabled = [
          {
            command = {
              args = [ "--goto" ];
              program = "code";
            };
            mouse = {
              enabled = true;
            };
            post_processing = true;
            regex = "[a-zA-Z/\\-_\\.]+(:\\d+)(:\\d*)?";
          }
        ];
      };
      keyboard = {
        bindings = [
          {
            chars = "";
            key = "Back";
            mods = "Control";
          }
        ];
      };
    };
  };
}
