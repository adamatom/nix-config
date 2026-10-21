# Nerd Fonts for terminals and editors.
{
  flake.modules.homeManager.fonts =
    { pkgs, ... }:
    {
      home.packages = with pkgs.nerd-fonts; [
        pkgs.nerd-fonts."m+"
        envy-code-r
        fira-mono
        jetbrains-mono
        meslo-lg
        monaspace
        zed-mono
      ];
    };
}
