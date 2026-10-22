# Ghostty terminal.
{
  flake.modules.homeManager.ghostty =
    { pkgs, wrapGL, ... }:
    {
      programs.ghostty = {
        enable = true;
        package = wrapGL pkgs.ghostty;
        settings = {
          # programs.zsh isn't enabled (see zsh.nix), so start zsh as a login
          # shell explicitly.
          command = "${pkgs.zsh}/bin/zsh --login --interactive";
          font-family = "AdamataMonoLiga Nerd Font Mono";
          font-family-bold = "AdamataMonoLiga Nerd Font Mono";
          font-family-italic = "AdamataMonoLiga Nerd Font Mono";
          font-family-bold-italic = "AdamataMonoLiga Nerd Font Mono";
          scrollback-limit = 1000000;
          env = "LOADED_CONF=yes";
        };
      };
    };
}
