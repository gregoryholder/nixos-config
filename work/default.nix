{ ... }:
{
  imports = [./git.nix ./delta.nix ./git-absorb.nix];

  home.username = "dev";
  home.homeDirectory = "/home/dev";

  home.sessionVariables = {
    HTTP_PROXY = "http://localhost:5865";
    HTTPS_PROXY = "http://localhost:5865";
    http_proxy = "http://localhost:5865";
    https_proxy = "http://localhost:5865";
    NO_PROXY = "systrans-gitlab.appli-services.com";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    CI_RUNNER_DESCRIPTION = "local";
    CCACHE_DIR = "/home/dev/.ccache/";
    CCACHE_CONFIGDIR = "/home/dev/.config/ccache/ccache.conf";
    CCACHE_VERSION = "4.8.2";
    CCACHE_SLOPPINESS = "include_file_mtime,include_file_ctime,time_macros,pch_defines";
    CCACHE_DEPEND = "true";
    ZELLIJ_AUTO_EXIT = "true";
  };

  programs.zsh.shellAliases = {
      unfuck = "git submodule deinit -f . && git submodule update --init && git add .";
      comp_veh = "./Navineo.py compiler vehicule";
      wineo = "(cd Affaires/Produit/vehicule_host/mineo && wine Mineo.exe)";
    };

}
