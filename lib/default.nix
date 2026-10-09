{ pkgs, ... }:
{
  home.packages = [
    # Nix tools
    pkgs.nil
    pkgs.nixfmt

    # Media
    pkgs.vlc

    # System utilities
    pkgs.nmap
    pkgs.lsd
    pkgs.ripgrep
    pkgs.bat
  ];
}
