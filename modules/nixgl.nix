# nixGL wrapping for graphical apps.
#
# On Ubuntu, home-manager's nixGL support (config.lib.nixGL) wraps an app so
# it can find the host's GPU drivers. On NixOS it isn't set up, and wrapGL
# returns the package unchanged.
{
  # wrapGL needs home-manager's config, which only exists while home-manager
  # evaluates, so it is shared as a home-manager module argument. Any
  # home-manager module can take `{ wrapGL, ... }:` like it takes `pkgs`.
  flake.modules.homeManager.nixgl =
    { config, ... }:
    {
      _module.args.wrapGL = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;
    };
}
