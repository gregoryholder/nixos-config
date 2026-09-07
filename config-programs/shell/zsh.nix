{ lib, ... }:
{
  imports = [
    ./keybindings.nix
    ./init.nix
    ./aliases.nix
    ./plugins.nix
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    initExtraFirst = ''
      if [[ -n "$ZSH_PROFILE_STARTUP" ]]; then
        zmodload zsh/zprof
      fi
    '';
    initExtra = lib.mkAfter ''
      PATH="/home/dev/.yarn/bin:$PATH"
      if [[ -n "$ZSH_PROFILE_STARTUP" ]]; then
        zprof
      fi
    '';

    enableCompletion = true;
    completionInit = ''
      FPATH="$HOME/.docker/completions:$FPATH"

      mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
      autoload -Uz +X compinit && compinit -d "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump" -C
      autoload -Uz +X bashcompinit && bashcompinit
      source /etc/bash_completion.d/*
    '';
    history.extended = true;
  };

  programs.vivid = {
    enable = true;
    activeTheme = "molokai";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.alacritty.settings.terminal.shell.program = "zsh";
  services.ssh-agent.enableZshIntegration = true;
}
