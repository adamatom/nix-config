{
  config,
  pkgs,
  lib,
  ...
}:

let
  wrapGL = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;
in
{
  home.packages = lib.mkAfter [
    (wrapGL pkgs.teams-for-linux)
  ];
}
