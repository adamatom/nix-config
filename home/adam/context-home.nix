{ pkgs, lib, ... }:

{
  home.packages = lib.mkAfter [
    pkgs.discord
    pkgs.kicad
  ];
}
