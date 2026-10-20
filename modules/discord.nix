# Discord.
{
  flake.modules.homeManager.discord =
    { pkgs, lib, ... }:
    {
      home.packages = lib.mkAfter [ pkgs.discord ];
    };
}
