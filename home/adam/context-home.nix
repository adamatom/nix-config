{ pkgs, lib, ... }:

{
  home.packages = lib.mkAfter [
    (pkgs.writeShellScriptBin "prismlauncher-env" ''
      exec env \
        LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib" \
        __GLX_VENDOR_LIBRARY_NAME="nvidia" \
        __EGL_VENDOR_LIBRARY_FILENAMES="/run/opengl-driver/share/glvnd/egl_vendor.d/50_nvidia.json" \
        ${pkgs.prismlauncher}/bin/prismlauncher "$@"
    '')
    pkgs.discord
    pkgs.kicad
  ];
}
