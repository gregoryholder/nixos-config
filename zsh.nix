{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    completionInit = ''
      autoload -Uz compinit && compinit
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    '';
    initExtra = ''
      bindkey  "^[[H"   beginning-of-line

      bindkey  "^[[F"   end-of-line

      bindkey '^?'    backward-delete-char         # Backspace
      bindkey '\e[3~' delete-char                  # Del
      # bindkey '\e[3;5~' delete-char                # sometimes Del, sometimes C-Del
      bindkey '\e[2~' overwrite-mode               # Ins

      bindkey '^H'      backward-kill-word         # C-Backspace

      bindkey '5~'      kill-word                  # C-Del
      bindkey '^[[3;5~' kill-word                  # C-Del
      bindkey '^[[3^'   kill-word                  # C-Del

      bindkey "^[[1;5H" backward-kill-line         # C-Home
      bindkey "^[[7^"   backward-kill-line         # C-Home

      bindkey "^[[1;5F" kill-line                  # C-End
      bindkey "^[[8^"   kill-line                  # C-End

      bindkey '^[[1;5C' forward-word               # C-Right
      bindkey '^[0c'    forward-word               # C-Right
      bindkey '^[[5C'   forward-word               # C-Right

      bindkey '^[[1;5D' backward-word              # C-Left
      bindkey '^[0d'    backward-word              # C-Left
      bindkey '^[[5D'   backward-word              # C-Left
    '';
    shellAliases = {
      ls = "lsd";
      dir = "dir --color=auto";
      vdir = "vdir --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";

      ll = "ls -alF";
      la = "ls -A";
      lsa = "ls -A";
      l = "ls -CF";

      gcr = "git clone --recursive";
    };
    history.extended = true;

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
          sha256 = "1b4pksrc573aklk71dn2zikiymsvq19bgvamrdffpf7azpq6kxl2";
        };
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.alacritty.settings.terminal.shell.program = "zsh";

  
}
