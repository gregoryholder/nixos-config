{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    completionInit = ''
      FPATH="$HOME/.docker/completions:$FPATH"

      autoload -Uz +X compinit && compinit
      autoload -Uz +X bashcompinit && bashcompinit
      source /etc/bash_completion.d/*
    '';
    initExtra = ''
      bindkey  "^[[H"   beginning-of-line

      bindkey  "^[[F"   end-of-line

      bindkey '^?'    backward-delete-char         # Backspace
      bindkey '\e[3~' delete-char                  # Del
      bindkey '\e[3;5~' delete-char                # sometimes Del, sometimes C-Del
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

      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init - zsh)"

      # if [ ! -z "$SSH_CLIENT" ]; then sodu; fi

      setopt AUTO_PUSHD

      # use builtin cd path replacement syntax:
      # ~/path1/sub > cd path1 path2
      # ~/path2/sub >
      function cd() {
        if [[ $# -le 1 ]]; then
          __zoxide_z "$@"
        else
          builtin cd "$@"
        fi
      }

      '';
    shellAliases = {
      dir   = "dir --color=auto";
      vdir  = "vdir --color=auto";
      grep  = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";

      ls  = "lsd -F --hyperlink auto";
      ll  = "ls -alhg";
      la  = "ls -A";
      lsa = "ls -A";
      l   = "ls -CF";

      gs  = "git status";
      gp  = "git push --force-with-lease";
      gaa = "git commit -a --no-verify --amend --no-edit";
      gr  = "cd $(git rev-parse --show-toplevel)";

      nvim_main = "nvr -s";

      sudo = "sudo -E";

      pick = "git cherry-pick -x";
    };
    history.extended = true;

    zsh-abbr = {
      enable = true;
      globalAbbreviations = {
          gcr = "git clone --recursive";
          tae = "./Navineo.py tests automatiques vehicule";
          ncv = "./Navineo.py compiler vehicule";
          nlc = "./Navineo.py lancer vehicule";
        };
    };

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
      {
          name = "zsh-prompt-benchmark";
          src = pkgs.fetchFromGitHub {
            owner = "romkatv";
            repo = "zsh-prompt-benchmark";
            rev = "5f80595b3bc9ab4e2b11c1b8bcaa3a52c874d118";
            sha256 = "sha256-rQt0/sdb+z9h86ca4H3/10tYmL1ILH+eiHYg6+R6sMk=";
          };
      }
      # {
      #   name = "vi-mode";
      #   src = pkgs.zsh-vi-mode;
      #   file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      # }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # programs.oh-my-posh.enableZshIntegration = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.alacritty.settings.terminal.shell.program = "zsh";

  
}
