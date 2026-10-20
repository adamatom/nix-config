# KiCad electronics design suite.
{
  flake.modules.homeManager.kicad =
    { pkgs, lib, ... }:
    {
      home.packages = lib.mkAfter [ pkgs.kicad ];
    };
}
