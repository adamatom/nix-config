# zsh, with its startup files kept as plain files so they read like zsh.
# Plugins (zplug, powerlevel10k) are still installed at runtime by .zshrc, so
# this doesn't use programs.zsh.enable, which would generate its own .zshrc.
{
  flake.modules.homeManager.zsh =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.zsh ];

      home.file = {
        ".zshenv".source = ./zshenv;
        ".zprofile".source = ./zprofile;
        ".zshrc".source = ./zshrc;
        ".p10k.zsh".source = ./p10k.zsh;
        ".profile".source = ./profile;
      };
    };
}
