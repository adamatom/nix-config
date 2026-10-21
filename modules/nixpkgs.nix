# nixpkgs settings shared by every machine.
#
# Machines live in separate files, so they can't share a `let` block. Instead
# this file declares an option and sets it; machine files read it back from
# `config.shared.nixpkgs`.
{ config, lib, ... }:
{
  options.shared.nixpkgs = {
    config = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = "nixpkgs config (e.g. allowUnfree) for every machine.";
    };
    overlays = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      description = "nixpkgs overlays for every machine.";
    };
  };

  config.shared.nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      # nix-direnv 3.2.0 reloads the environment at every prompt when more
      # than one direnv instance uses the same .envrc
      # (https://github.com/nix-community/nix-direnv/issues/786). Pin the
      # source to the merge of the fix until upstream cuts a release.
      # The package is a two-stage resholve build, so the source is swapped at
      # the fetcher rather than with overrideAttrs.
      (final: prev: {
        nix-direnv = prev.nix-direnv.override {
          fetchFromGitHub =
            args:
            prev.fetchFromGitHub (
              builtins.removeAttrs args [ "tag" ]
              // {
                rev = "8c7ebb294d997bc1720ddf3f7ee9ed27c290a0e6";
                hash = "sha256-nizx6hDPX8P9/M7GWLunnnQpyPJed1ZzKuNDnU+R4Oc=";
              }
            );
        };
      })
    ];
  };

  # NixOS applies the shared settings to the system pkgs, which home-manager
  # also uses there (home-manager.useGlobalPkgs).
  config.flake.modules.nixos.nixpkgs = {
    nixpkgs = {
      inherit (config.shared.nixpkgs) config overlays;
    };
  };
}
