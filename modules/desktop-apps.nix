# Graphical apps.
{ config, ... }:
{
  # udev rules so the Saleae Logic app can reach the analyzer over USB.
  flake.modules.nixos.desktop-apps = {
    # Bring the home-manager half along on NixOS.
    home-manager.sharedModules = [ config.flake.modules.homeManager.desktop-apps ];

    hardware.saleae-logic.enable = true;
  };

  flake.modules.homeManager.desktop-apps =
    { pkgs, wrapGL, ... }:
    {
      home.packages = with pkgs; [
        # GUI apps
        baobab
        (wrapGL fractal)
        gitg
        litemdview
        (wrapGL saleae-logic-2)
        (wrapGL spotify)
      ];
    };
}
