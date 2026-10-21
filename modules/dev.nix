# Compilers, language servers and embedded tooling.
{
  # Hardware access for embedded work: JTAG adapters and serial ports.
  flake.modules.nixos.dev = {
    services.udev.extraRules = ''
      # FTDI FT2232H Dual RS232-HS: Vendor 0403, Product 6010, commonly used for openocd jtagging
      SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666", GROUP="dialout"
    '';

    # Serial ports (picocom, openocd) belong to the dialout group.
    users.users.adam.extraGroups = [ "dialout" ];
  };

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
