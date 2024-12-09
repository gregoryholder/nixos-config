{ ... }:
{
  programs.helix = {
    enable = true;

    settings = {
      editor = {
        bufferline = "always";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          character = "╎";
          render = true;
          skip-levels = 1;
        };
        line-number = "relative";
        lsp = {
          display-inlay-hints = true;
        };
        mouse = true;
        soft-wrap = {
          enable = true;
        };
        statusline = {
          center = [ "file-name" ];
          left = [
            "mode"
            "spinner"
          ];
          mode = {
            insert = "INSERT";
            normal = "NORMAL";
            select = "SELECT";
          };
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = "│";
        };
      };
      theme = "onedark";
    };

    languages = {
      language = [
        {
          name = "cpp";
          debugger = {
            command = "lldb-dap-19";
            name = "lldb-dap-19";
            templates = [
              {
                args = {
                  program = "{0}";
                  runInTerminal = true;
                };
                completion = [
                  {
                    completion = "filename";
                    name = "binary";
                  }
                ];
                name = "binary (terminal)";
                request = "launch";
              }
            ];
            transport = "stdio";
          };
        }
      ];
    };
  };

}
