{ config, pkgs, lib, ... }:

let
  wrapGL = pkg: config.lib.nixGL.wrap pkg;
in
{
  home.packages = lib.mkAfter [
    (wrapGL pkgs.teams-for-linux)
  ];
}
