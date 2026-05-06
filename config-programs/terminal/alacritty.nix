{ ... }:
{
  programs.alacritty = {
    # enable = true;

    settings = {
      font = {
        size = 9;
      };
      hints = {
        enabled = [
          {
            command = {
              program = "code";
              args = [ "--goto" ];
            };
            mouse.enabled = true;
            post_processing = true;
            regex = "[a-zA-Z/\\\\-_\\\\.]+(:\\\\d+)(:\\\\d*)?";
          }
        ];
      };
      keyboard.bindings = [
        {
          chars = "";
          key = "Back";
          mods = "Control";
        }
      ];
    };
  };
}
