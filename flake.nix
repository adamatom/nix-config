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

      # pkgsHM is only for Home-Manager-only/non-NixOS installs.
      # We import nixpkgs here with allowUnfree enabled so that HM on Ubuntu, etc.
      # can build unfree packages listed in home/adam/*.
      # On NixOS we do not use this: HM reuses the system pkgs (see useGlobalPkgs below),
      # so the NixOS path must enable allowUnfree at the system level instead.
      pkgsHM = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      homeConfigurations.adam = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsHM;
        modules = [
          ./home/adam/common.nix
          ./home/adam/context-work.nix
          ./home/adam/os-ubuntu.nix
        ];
        extraSpecialArgs = {
          inherit nixgl;
        };
      };

      nixosConfigurations.hydra = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/all.nix
          ./hosts/hydra.nix

          # NixOS path: enable allowUnfree on the system pkgs.
          # Because we set home-manager.useGlobalPkgs = true below,
          # Home Manager will reuse this system pkgs set.
          ({ lib, ... }: {
            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            nixpkgs.config.allowUnfree = true; 
          })

          nixos-hardware.nixosModules.lenovo-thinkpad-p53
          home-manager.nixosModules.home-manager
          {
            # Reuse the system pkgs in HM on NixOS (so no separate HM pkgs import).
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.adam = {
              imports = [
                ./home/adam/common.nix
                ./home/adam/context-home.nix
                ./home/adam/os-nixos.nix
              ];
            };
            home-manager.extraSpecialArgs = {
              inherit nixgl;
            };
          }
        ];
      };
    };
}
