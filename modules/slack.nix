# Slack, for work.
{
  flake.modules.homeManager.slack =
    {
      pkgs,
      lib,
      wrapGL,
      ...
    }:
    {
      home.packages = lib.mkAfter [ (wrapGL pkgs.slack) ];
    };
}
