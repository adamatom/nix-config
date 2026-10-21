# Hunspell with English and German dictionaries.
{
  flake.modules.homeManager.spellchecking =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        hunspell
        hunspellDicts.en_US
        hunspellDicts.de_DE
      ];
    };
}
