# Ghostty terminal.
{
  flake.modules.homeManager.ghostty =
    { pkgs, wrapGL, ... }:
    {
      programs.ghostty = {
        enable = true;
        package = wrapGL pkgs.ghostty;
        settings = {
          # zsh isn't managed by home-manager (I keep my own .zshrc), so start
          # it as a login shell explicitly.
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
