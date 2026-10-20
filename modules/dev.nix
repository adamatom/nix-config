# Compilers, language servers and embedded tooling.
{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # hiPrio: clang-tools now also ships scan-view; let clang-analyzer win the collision.
        (lib.hiPrio clang-analyzer)
        clang-tools
        cmake
        dtc
        gcc
        go
        gopls
        lua-language-server
        markdownlint-cli
        marksman
        nil
        openocd
        picocom
        pkg-config
        prettier
        python313
        python313Packages.python-lsp-server
        qemu
        rustc
        cargo
        tree-sitter
        nodejs # tree-sitter CLI shells out to node for some grammars' generate step
        universal-ctags
        uv
      ];
    };
}
