{ ... }:
{
  programs.oh-my-posh = {
    enable = true;
    settings = {
      blocks = [
        {
          alignment = "left";
          newline = true;
          segments = [
            {
              background = "transparent";
              foreground = "blue";
              properties = {
                style = "full";
              };
              style = "plain";
              template = "{{ .Path }}";
              type = "path";
            }
            {
              background = "transparent";
              foreground = "p:grey";
              properties = {
                branch_icon = "";
                commit_icon = "@";
              };
              style = "plain";
              template = " {{if not .Detached}}{{ .HEAD }}{{else}}@{{ printf \"%.7s\" .Commit.Sha }}{{end}}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>\n ";
              type = "git";
            }
          ];
          type = "prompt";
        }
        {
          overflow = "hidden";
          segments = [
            {
              background = "transparent";
              foreground = "yellow";
              properties = {
                threshold = 5000;
              };
              style = "plain";
              template = "{{ .FormattedMs }}";
              type = "executiontime";
            }
          ];
          type = "rprompt";
        }
        {
          alignment = "left";
          newline = true;
          segments = [
            {
              background = "transparent";
              foreground_templates = [
                "{{if gt .Code 0}}red{{end}}"
                "{{if eq .Code 0}}magenta{{end}}"
              ];
              style = "plain";
              template = "❯";
              type = "text";
            }
          ];
          type = "prompt";
        }
      ];
      console_title_template = "{{ .Shell }} in {{ .Folder }}";
      enable_cursor_positioning = true;
      final_space = true;
      properties = {
        display_status = false;
        ignore_submodules = {
          "*" = "all";
        };
      };
      secondary_prompt = {
        background = "transparent";
        foreground = "magenta";
        template = "❯❯ ";
      };
      transient_prompt = {
        background = "transparent";
        foreground_templates = [
          "{{if gt .Code 0}}red{{end}}"
          "{{if eq .Code 0}}magenta{{end}}"
        ];
        template = "❯ ";
      };
      version = 2;
    };
  };
}
