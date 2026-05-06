{ ... }:
{
  home.sessionVariables = {
    CI_RUNNER_DESCRIPTION = "local";
    CCACHE_DIR = "/home/dev/.ccache/";
    CCACHE_CONFIGDIR = "/home/dev/.config/ccache/ccache.conf";
    CCACHE_VERSION = "4.8.2";
    CCACHE_SLOPPINESS = "include_file_mtime,include_file_ctime,time_macros,pch_defines";
    CCACHE_DEPEND = "true";
    ZELLIJ_AUTO_EXIT = "true";
  };
}
