{ config, lib, nixgl, ... }:

{
  # This is set by nixos, but not set on home-manager-only systems.
  targets.genericLinux.enable = lib.mkDefault true;

  # Without using programs.zsh.enable, to get discoverable .desktop files in non-NixOS, we need the
  # following settings, and this addition to your ~/.profile:
  #   export XDG_DATA_DIRS="/home/your_user/.nix-profile/share:$XDG_DATA_DIRS"
  xdg.enable = true;
  xdg.mime.enable = true;

  # On non-NixOS (Ubuntu), point HM at nixGL’s package set.
  # On NixOS, leave it unset — wrappers become no-ops.
  targets.genericLinux.nixGL.packages = nixgl.packages;

  # On non-NixOS, we need to override the pixbuf loaders. These are set by nix when we include an
  # application via programs.<program>.enable that uses GTK.
  home.sessionVariables = {
    GDK_PIXBUF_MODULE_FILE = "/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    GDK_PIXBUF_MODULEDIR   = "/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders";
    XCURSOR_THEME="Yaru";
  };

  # On non-NixOS, we need to unset the following envvars that the nix dconf modules sets. Otherwise
  # we will end up mixing system Gnome libs with nix libs, and they usually don't agree.
  # Explicitly scrub session-level exports that cause the mismatch
  home.sessionVariablesExtra = ''
    unset GIO_EXTRA_MODULES
    unset GIO_MODULE_DIR
    unset GSETTINGS_SCHEMA_DIR
    unset GTK_PATH
    unset GTK_IM_MODULE_FILE
  '';

  # Ensure GNOME launcher can find Nix executables (like firefox). We also want GTK apps to find
  # the system pixloaders and resources when we are not running on nixos.
  home.file.".config/environment.d/20-ubuntu-hacks.conf" = {
    text = ''
      PATH=/home/adam/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
      GDK_PIXBUF_MODULE_FILE=/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
      GDK_PIXBUF_MODULEDIR=/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders
      XDG_DATA_DIRS=/usr/local/share:/usr/share:/usr/share/gnome:/usr/share/ubuntu:/var/lib/snapd/desktop:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share
      XCURSOR_THEME=Yaru
    '';
  };

  # Override the default ghostty desktop entry, which sidesteps the wrapgl wrapping.
  xdg.desktopEntries = {
    "com.mitchellh.ghostty" = {
      name = "Ghostty";
      comment = "A terminal emulator";
      exec = "${config.programs.ghostty.package}/bin/ghostty --gtk-single-instance=true";
      icon = "com.mitchellh.ghostty";
      categories = [ "System" "TerminalEmulator" ];
      terminal = false;
      startupNotify = true;
      settings = {
        StartupWMClass = "com.mitchellh.ghostty";
        DBusActivatable = "false";
      };
    };
  };
}
