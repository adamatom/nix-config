# Minecraft through Prism Launcher, with NVIDIA driver paths for NixOS.
{
  flake.modules.homeManager.minecraft =
    { pkgs, lib, ... }:
    {
      home.packages = lib.mkAfter [
        (pkgs.writeShellScriptBin "prismlauncher-env" ''
          exec env \
            GLFW_PLATFORM="x11" \
            LIBGL_DRIVERS_PATH="/run/opengl-driver/lib/dri" \
            LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib" \
            __GLX_VENDOR_LIBRARY_NAME="nvidia" \
            __EGL_VENDOR_LIBRARY_DIRS="/run/opengl-driver/share/glvnd/egl_vendor.d" \
            __EGL_VENDOR_LIBRARY_FILENAMES="/run/opengl-driver/share/glvnd/egl_vendor.d/50_nvidia.json" \
            ${pkgs.prismlauncher}/bin/prismlauncher "$@"
        '')
      ];

      xdg.desktopEntries = {
        "org.prismlauncher.PrismLauncher" = {
          name = "Prism Launcher";
          comment = "Minecraft launcher";
          exec = "prismlauncher-env";
          icon = "prismlauncher";
          categories = [ "Game" ];
          terminal = false;
          startupNotify = true;
        };
        "minecraft-1.21.11" = {
          name = "Minecraft 1.21.11";
          comment = "Launch Minecraft";
          exec = "prismlauncher-env --launch \"1.21.11\"";
          icon = "minecraft-1.21.11";
          categories = [ "Game" ];
          terminal = false;
          startupNotify = true;
        };
      };

      xdg.dataFile = {
        "icons/hicolor/scalable/apps/minecraft-1.21.11.svg".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
            <rect width="128" height="128" fill="#4caf50"/>
            <rect x="24" y="28" width="32" height="32" fill="#0a0a0a"/>
            <rect x="72" y="28" width="32" height="32" fill="#0a0a0a"/>
            <rect x="40" y="72" width="16" height="20" fill="#0a0a0a"/>
            <rect x="72" y="72" width="16" height="20" fill="#0a0a0a"/>
            <rect x="56" y="80" width="16" height="12" fill="#0a0a0a"/>
          </svg>
        '';
      };
    };
}
