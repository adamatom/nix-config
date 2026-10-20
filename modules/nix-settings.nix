# Nix itself: flakes, plus the numtide binary cache for llm-agents and
# system-manager. NixOS sets these system-wide; on Ubuntu, home-manager writes
# them to ~/.config/nix/nix.conf. flake.nix's nixConfig repeats the cache for
# the first build, because nixConfig must be a literal.
let
  experimentalFeatures = [
    "nix-command"
    "flakes"
  ];
  substituters = [ "https://cache.numtide.com" ];
  trustedPublicKeys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
in
{
  flake.modules.nixos.nix-settings = {
    nix.settings = {
      experimental-features = experimentalFeatures;
      extra-substituters = substituters;
      extra-trusted-public-keys = trustedPublicKeys;
    };
  };

  flake.modules.homeManager.nix-settings =
    { lib, ... }:
    {
      xdg.configFile."nix/nix.conf".text = ''
        experimental-features = ${lib.concatStringsSep " " experimentalFeatures}
        extra-substituters = ${lib.concatStringsSep " " substituters}
        extra-trusted-public-keys = ${lib.concatStringsSep " " trustedPublicKeys}
      '';
    };
}
