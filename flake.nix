{
  description = "NixOS Flake-based + Home Manager configuration";

  # Make upstream package caches available while building this flake, including
  # the first switch before the persistent Nix settings below are activated.
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    llm-agents.url = "github:numtide/llm-agents.nix";
    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
  };

  # Everything lives in ./modules: features under modules/, machines under
  # modules/machines/. Each file is a flake-parts module.
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Provides flake.modules.<class>.<name>.
        flake-parts.flakeModules.modules
        # Every .nix file under ./modules is a flake-parts module, except
        # paths containing "/_".
        (inputs.import-tree ./modules)
      ];

      systems = [ "x86_64-linux" ];
    };
}
