{
  config,
  pkgs,
  extraSpecialArgs,
  currentUsername,
  ...
}:

{
  imports = [
    ./config-programs
    ./config-features
    ./lib/default.nix
  ];

  programs = {
    nh.enable = true;

    lazygit = {
      enable = true;
      settings = {
        os = {
          edit = "nvr --servername \"$NVIM_LISTEN_ADDRESS\" --remote-tab \"{{filename}}\"";
          editAtLine = "nvr --servername \"$NVIM_LISTEN_ADDRESS\" --remote-tab +\"{{line}}\" \"{{filename}}\"";
          editAtLineAndWait = "nvr --servername \"$NVIM_LISTEN_ADDRESS\" --remote-wait +\"{{line}}\" \"{{filename}}\"";
        };
      };
    };
    bottom.enable = true;

    gh.enable = true;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = { };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/gregory/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [ ];
}
