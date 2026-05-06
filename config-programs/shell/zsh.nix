{ ... }:
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
    enableCompletion = true;
    completionInit = ''
      FPATH="$HOME/.docker/completions:$FPATH"

      autoload -Uz +X compinit && compinit
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
