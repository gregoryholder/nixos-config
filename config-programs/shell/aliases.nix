{ ... }:
{
  programs.zsh.shellAliases = {
    # Color grep variants
    dir   = "dir --color=auto";
    vdir  = "vdir --color=auto";
    grep  = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";

    # Improved ls with lsd
    ls  = "lsd -F --hyperlink auto";
    ll  = "ls -alhg";
    la  = "ls -A";
    lsa = "ls -A";
    l   = "ls -CF";

    # Git shortcuts
    gp  = "git push --force-with-lease";
    gaa = "git commit -a --no-verify --amend --no-edit";
    gr  = "cd $(git rev-parse --show-toplevel)";
    pick = "git cherry-pick -x";

    # Other utilities
    nvim_main = "nvr -s";
    sudo = "sudo -E";
    rga = "rga -g '!~$*' -g '!*.zip' -g '!*.tar'";
    comp_lint = ''bcompare WarningsCpplint_merge-base.txt WarningsCpplint.txt -title1="Cpplint [Merge base]" -title2="Cpplint [Current]"'';
  };

  programs.zsh.zsh-abbr = {
    enable = true;
    globalAbbreviations = {
      gcr = "git clone --recursive";
      tae = "./Navineo.py tests automatiques vehicule";
      ncv = "./Navineo.py compiler vehicule";
      nlc = "./Navineo.py lancer vehicule";
    };
  };
}
