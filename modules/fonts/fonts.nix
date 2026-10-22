# Fonts for terminals and editors: Nerd Fonts and Adamata.
{
  flake.modules.homeManager.fonts =
    { pkgs, ... }:
    let
      # All Adamata styles in one archive; zstd shares glyph data across
      # files, shrinking 56M of .ttf to 4M. To rebuild it from a folder of
      # .ttf files:
      #   tar --sort=name --owner=0 --group=0 --mtime=@0 -cf - */*/*.ttf \
      #     | zstd -19 --long=27 -o adamata.tar.zst
      adamata = pkgs.stdenvNoCC.mkDerivation {
        pname = "adamata";
        version = "local";
        src = ./adamata.tar.zst;
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.zstd ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/fonts/truetype
          tar --zstd -xf $src -C $out/share/fonts/truetype
          runHook postInstall
        '';
      };
    in
    {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs.nerd-fonts; [
        adamata
        pkgs.nerd-fonts."m+"
        caskaydia-cove
        envy-code-r
        fira-mono
        jetbrains-mono
        meslo-lg
        monaspace
        zed-mono
      ];
    };
}
