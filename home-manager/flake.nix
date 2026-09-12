{
  description = "Colin's Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."colin" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ 
          { nixpkgs.config.allowUnfree = true; }
          ./home.nix 
        ];
      };
    };
}
