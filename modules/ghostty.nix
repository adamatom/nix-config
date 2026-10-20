# Ghostty terminal.
{
  flake.modules.homeManager.ghostty =
    { pkgs, wrapGL, ... }:
    {
      programs.ghostty = {
        enable = true;
        package = wrapGL pkgs.ghostty;
      };
    };
}
