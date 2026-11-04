{
  description = "Home Manager configuration of dev";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixgl.url = "github:nix-community/nixGL";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixgl,
      nixpkgs,
      home-manager,
      self,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nixgl.overlays.default
          (final: prev: {
            nixgl = prev.nixgl.override {
              # nixGL still invokes pcregrep, which was replaced by pcre2grep.
              pcre = final.writeShellScriptBin "pcregrep" ''
                exec ${final.pcre2}/bin/pcre2grep "$@"
              '';
            };
          })
        ];
      };

      mkHomeConfig = name: username: {
        "${name}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            currentUsername = username;
          };
          modules = [ ./home.nix ./${name} ];
        };
      };
    in
    {
      homeConfigurations = 
        mkHomeConfig "home" "gregory" // 
        mkHomeConfig "work" "dev";
    };
}
