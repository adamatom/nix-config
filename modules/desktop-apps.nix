# Graphical apps, fonts and spellchecking.
{
  # udev rules so the Saleae Logic app can reach the analyzer over USB.
  flake.modules.nixos.desktop-apps = {
    hardware.saleae-logic.enable = true;
  };

  flake.modules.homeManager.desktop-apps =
    { pkgs, wrapGL, ... }:
    {
      home.packages = with pkgs; [
        # GUI apps
        baobab
        (wrapGL fractal)
        gitg
        litemdview
        (wrapGL saleae-logic-2)
        (wrapGL spotify)

        # Fonts
        nerd-fonts."m+"
        nerd-fonts.envy-code-r
        nerd-fonts.fira-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
        nerd-fonts.monaspace
        nerd-fonts.zed-mono

        # Spellchecking
        hunspell
        hunspellDicts.en_US
        hunspellDicts.de_DE
      ];
    };
}
