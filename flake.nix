{
  description = "NixOS Flake-based + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, nixgl, ... }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations.adam = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/adam.nix ];
        extraSpecialArgs = { inherit nixgl; };
      };

      nixosConfigurations.hydra = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/all.nix
          ./hosts/hydra.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-p53
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.adam = import ./home/adam.nix;
            home-manager.extraSpecialArgs = { inherit nixgl; };
          }
        ];
      };
    };
}
