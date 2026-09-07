{ pkgs, lib, ... }:
{
  programs.zsh.plugins = [
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
    {
      name = "zsh-yarn-completions";
      src = pkgs.fetchFromGitHub {
        owner = "chrisands";
        repo = "zsh-yarn-completions";
        rev = "1ddb8ea6209b7c4a55b9accaea5460bec27ec8a7";
        sha256 = "sha256-S8NPSI0ItL/AmU+O8/KYqhv5HZ+F1j8Tg3sqOSEzXok=";
      };
    }
  ];
}
