# Home desktop: NixOS with home-manager as a NixOS module.
{ config, inputs, ... }:
{
  flake.nixosConfigurations.hydra = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../../hosts/all.nix
      config.flake.modules.nixos.nix-settings
      config.flake.modules.nixos.gnome
      ../../hosts/hydra.nix

      # NixOS path: enable allowUnfree on the system pkgs.
      # Because we set home-manager.useGlobalPkgs = true below,
      # Home Manager will reuse this system pkgs set.
      # TODO: this machine does not get config.shared.nixpkgs.overlays yet.
      (
        { lib, ... }:
        {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          nixpkgs.config.allowUnfree = true;
        }
      )

      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p53
      inputs.home-manager.nixosModules.home-manager
      {
        # Reuse the system pkgs in HM on NixOS (so no separate HM pkgs import).
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.adam = {
          imports = [
            config.flake.modules.homeManager.base
            config.flake.modules.homeManager.ai-tools
            config.flake.modules.homeManager.dev
            config.flake.modules.homeManager.desktop-apps
            config.flake.modules.homeManager.firefox
            config.flake.modules.homeManager.ghostty
            config.flake.modules.homeManager.gnome
            config.flake.modules.homeManager.nixgl
            config.flake.modules.homeManager.discord
            config.flake.modules.homeManager.kicad
            config.flake.modules.homeManager.minecraft
          ];
        };
      }
    ];
  };
}
