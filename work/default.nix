{ config, currentUsername, ... }:
{
  imports = [
    ../config-features/dev-env
  ];

  # On non-NixOS, this helps GUI apps (including WezTerm launched from desktop entries)
  # receive Home Manager environment/session wiring.
  targets.genericLinux.enable = true;

  # Use the username passed from flake
  # This makes the configuration portable across different systems/usernames
  home.username = currentUsername;
  home.homeDirectory = "/home/${currentUsername}";

  services.ssh-agent = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh.shellAliases = {
    unfuck = "git submodule deinit -f . && git submodule sync && git submodule update --init && git add .";
    comp_veh = "./Navineo.py compiler vehicule";
    wineo = "(cd Affaires/Produit/vehicule_host/mineo && wine Mineo.exe)";
    cc_icc_ucineo = "ln -fs TargetLinuxGeneric/IccUnityBuildsDebug/compile_commands.json .";
    cc_veh = "ln -fs TargetLinuxHost/VehiculeUnityBuildsDebug/compile_commands.json .";
    bc_check = "bcompare WarningsCppcheck_merge-base.xml WarningsCppcheck.xml";
    bc_dox = "bcompare WarningsDoxygen-vehicule_merge-base.txt WarningsDoxygen-vehicule.txt";

    big_monitor = ''xrandr --newmode "2560x1440_60.00"  312.25  2560 2752 3024 3488  1440 1443 1448 1493 -hsync +vsync && xrandr --addmode DP-1 "2560x1440_60.00" && xrandr --output DP-1 --mode 2560x1440_60.00'';
  };
}
