# Work laptop: Ubuntu with standalone home-manager and system-manager.
#
# Note: `config` here is the flake-parts config (shared settings, feature
# modules), not the home-manager or system-manager config.
{ config, inputs, ... }:
let
  system = "x86_64-linux";
  nixpkgsSettings = config.shared.nixpkgs;
in
{
  flake.homeConfigurations.adam = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      inherit (nixpkgsSettings) config overlays;
    };
    modules = [
      config.flake.modules.homeManager.base
      config.flake.modules.homeManager.zsh
      config.flake.modules.homeManager.ai-tools
      config.flake.modules.homeManager.herdr
      config.flake.modules.homeManager.tmux
      config.flake.modules.homeManager.git
      config.flake.modules.homeManager.gdb
      config.flake.modules.homeManager.neovim
      config.flake.modules.homeManager.dev
      config.flake.modules.homeManager.desktop-apps
      config.flake.modules.homeManager.fonts
      config.flake.modules.homeManager.spellchecking
      config.flake.modules.homeManager.firefox
      config.flake.modules.homeManager.ghostty
      config.flake.modules.homeManager.gnome
      config.flake.modules.homeManager.nixgl
      config.flake.modules.homeManager.slack
      config.flake.modules.homeManager.ubuntu
      config.flake.modules.homeManager.mullvad
      config.flake.modules.homeManager.outlook-pwa
      {
        home.packages = [ inputs.system-manager.packages.${system}.default ];
      }
    ];
  };

  flake.systemConfigs.default = inputs.system-manager.lib.makeSystemConfig {
    inherit (nixpkgsSettings) overlays;
    modules = [
      {
        nixpkgs.hostPlatform = system;
        nixpkgs.config = nixpkgsSettings.config;
      }
      config.flake.modules.systemManager.mullvad
      config.flake.modules.systemManager.outlook-pwa
    ];
  };
}
