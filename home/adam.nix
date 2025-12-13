{ config, pkgs, lib, nixgl, atWork ? false, isNixOs ? false, ... }:

let
  notNixOs = !isNixOs;

  # helper fn to save typing.
  wrapGL = pkg: config.lib.nixGL.wrap pkg;
in
{
  # This is set by nixos, but not set on home-manager-only systems.
  targets.genericLinux.enable = lib.mkDefault true;

  # Without using programs.zsh.enable, to get discoverable .desktop files in non-NixOS, we need the
  # following settings, and this addition to your ~/.profile:
  #   export XDG_DATA_DIRS="/home/your_user/.nix-profile/share:$XDG_DATA_DIRS"
  xdg.enable = lib.mkIf notNixOs true;
  xdg.mime.enable = lib.mkIf notNixOs true;

  # On non-NixOS (Ubuntu), point HM at nixGL’s package set.
  # On NixOS, leave it unset — wrappers become no-ops.
  nixGL.packages = lib.mkIf notNixOs nixgl.packages.${pkgs.system};

  # On non-NixOS, we need to override the pixbuf loaders. These are set by nix when we include an
  # application via programs.<program>.enable that uses GTK.
  home.sessionVariables = lib.mkIf notNixOs {
    GDK_PIXBUF_MODULE_FILE = "/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    GDK_PIXBUF_MODULEDIR   = "/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders";
    XCURSOR_THEME="Yaru";
  };

  # On non-NixOS, we need to unset the following envvars that the nix dconf modules sets. Otherwise
  # we will end up mixing system Gnome libs with nix libs, and they usually don't agree.
  # Explicitly scrub session-level exports that cause the mismatch
  home.sessionVariablesExtra = lib.mkIf notNixOs ''
    unset GIO_EXTRA_MODULES
    unset GIO_MODULE_DIR
    unset GSETTINGS_SCHEMA_DIR
    unset GTK_PATH
    unset GTK_IM_MODULE_FILE
  '';

  # Ensure GNOME launcher can find Nix executables (like firefox). We also want GTK apps to find
  # the system pixloaders and resources when we are not running on nixos.
  home.file.".config/environment.d/20-ubuntu-hacks.conf" = lib.mkIf notNixOs {
    text = ''
      PATH=/home/adam/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
      GDK_PIXBUF_MODULE_FILE=/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
      GDK_PIXBUF_MODULEDIR=/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders
      XDG_DATA_DIRS=/usr/local/share:/usr/share:/usr/share/gnome:/usr/share/ubuntu:/var/lib/snapd/desktop:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share
      XCURSOR_THEME=Yaru
    '';
  };

  home = {
    username = "adam";
    homeDirectory = "/home/adam";
  };

  # Packages that should be installed to the user profile.
  home.packages = 
    let
      base = with pkgs; [
        # I dont want to give up my .zshrc yet, so I cant use programs.zsh.enable.
        zsh

        # CLI tools
        bat
        curlFull
        diff-so-fancy
        fd
        file
        fzf
        gawk
        gitFull
        git-lfs
        gnupg
        gnused
        gnutar
        jq
        killall
        mcfly
        neovim
        nmap
        picocom
        qemu
        ripgrep
        tmux
        tree
        wget
        which
        xclip
        xz
        zip unzip
        zoxide
        zstd

        # GUI apps
        baobab
        gitg
        mpv
        saleae-logic-2
        (wrapGL slack)
        spotify

        # Development tools
        clang-analyzer
        clang-tools
        cmake
        dtc
        gcc
        go
        gopls
        lua-language-server
        markdownlint-cli
        openocd
        pkg-config
        python313
        python313Packages.python-lsp-server
        rustup
        universal-ctags
        uv

        # system libs
        libxcrypt

        # Fonts
        nerd-fonts."m+"
        nerd-fonts.envy-code-r
        nerd-fonts.fira-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
        nerd-fonts.monaspace
        nerd-fonts.zed-mono

        # GTK theme
        adw-gtk3

        # Spellchecking
        hunspell hunspellDicts.en_US hunspellDicts.de_DE

        # GNOME Shell Extensions (needed for the dconf settings to work)
        gnomeExtensions.bing-wallpaper-changer
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.grand-theft-focus
        gnomeExtensions.launch-new-instance
        gnomeExtensions.paperwm
        gnomeExtensions.resource-monitor
      ];

      # Conditionals:
      workPkgs     = lib.optionals atWork      [ (wrapGL pkgs.teams-for-linux) ];
      personalPkgs = lib.optionals (!atWork)   [ (wrapGL pkgs.discord) (wrapGL pkgs.kicad) ];
      NixOsPkgs    = lib.optionals (!notNixOs) [ pkgs.rofi ];
    in
      base ++ workPkgs ++ personalPkgs ++ NixOsPkgs;

  # Install programs with more complete OS integration (desktop files, etc).
  # programs.pkg.enable is prioritized over pkgs.pkg if it exists.
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    firefox = {
      enable = true;
      package = wrapGL pkgs.firefox;
    };

    ghostty = {
      enable = true;
      package = wrapGL pkgs.ghostty;
    };

    htop.enable = true;

  };

  dconf = {
    enable = true;
    # tip: use `dconf watch /`, then make changes in gui to capture what to add here.
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Yaru-olive-dark";
        enable-hot-corners = false;
        accent-color = "green";
        show-battery-percentage = true;
      };

      "org/gnome/desktop/wm/keybindings" = {
        begin-move = [];
        begin-resize = [];
        close = [];
        minimize = [];
        move-to-monitor-down = [];
        move-to-monitor-left = [];
        move-to-monitor-right = [];
        move-to-monitor-up = [];
        move-to-workspace-1 = [ "<Shift><Super>1" ];
        move-to-workspace-2 = [ "<Shift><Super>2" ];
        move-to-workspace-3 = [ "<Shift><Super>3" ];
        move-to-workspace-4 = [ "<Shift><Super>4" ];
        move-to-workspace-down = [];
        move-to-workspace-last = [];
        move-to-workspace-left = [];
        move-to-workspace-right = [];
        move-to-workspace-up = [];
        show-desktop = [];
        switch-applications = [];
        switch-applications-backward = [];
        switch-group = [];
        switch-group-backward = [];
        switch-input-source = [];
        switch-input-source-backward = [];
        switch-panels = [];
        switch-panels-backward = [];
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-to-workspace-last = [];
        switch-to-workspace-left = [];
        switch-to-workspace-right = [];
        switch-windows = [];
        switch-windows-backward = [];
        toggle-maximized = [];
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
      };
 
      "org/gnome/mutter" = {
        overlay-key = "";
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "toggle rofi super-return";
        command = "rofi -show drun";
        binding = "<Super>Return";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "toggle rofi super-space";
        command = "rofi -show drun";
        binding = "<Super>Space";
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-timeout=1800;
        sleep-inactive-ac-type="nothing";
        sleep-inactive-battery-timeout=1800;
        sleep-inactive-battery-type="suspend";
      };

      "org/gnome/shell" = {
        disable-user-extensions = false; # enables user extensions
        enabled-extensions = [
          pkgs.gnomeExtensions.bing-wallpaper-changer.extensionUuid
          pkgs.gnomeExtensions.clipboard-indicator.extensionUuid
          pkgs.gnomeExtensions.grand-theft-focus.extensionUuid
          pkgs.gnomeExtensions.launch-new-instance.extensionUuid
          pkgs.gnomeExtensions.paperwm.extensionUuid
          pkgs.gnomeExtensions.resource-monitor.extensionUuid
        ];
      };

      "org/gnome/shell/keybindings" = {
        focus-active-notification = [];
        shift-overview-down = [];
        shift-overview-up = [];
        switch-to-application-1 = [];
        switch-to-application-2 = [];
        switch-to-application-3 = [];
        switch-to-application-4 = [];
        toggle-application-view = [ "<Shift><Super>space" ];
        toggle-message-tray = [];
      };

      "org/gnome/shell/extensions/bingwallpaper" = {
        icon-name = "mid-frame-symbolic";
      };

      "org/gnome/shell/extensions/clipboard-indicator" = {
        cache-size = 90;
        disable-down-arrow = true;
        display-mode = 0;
        history-size = 100;
        preview-size = 30;
      };

      "org/gnome/shell/extensions/paperwm" = {
        animation-time = 0.20000000000000004;
        cycle-width-steps = [ 0.25 0.33 0.5 0.66 0.75 1.0 ];
        disable-topbar-styling = false;
        edge-preview-click-enable = false;
        edge-preview-scale = 0.0;
        gesture-enabled = false;
        gesture-horizontal-fingers = 4;
        horizontal-margin = 0;
        maximize-width-percent = 1.0;
        minimap-scale = 0.0;
        minimap-shade-opacity = 154;
        open-window-position = 0;
        open-window-position-option-right = true;
        overview-ensure-viewport-animation = 2;
        overview-min-windows-per-row = 11;
        restore-attach-modal-dialogs = "true";
        restore-edge-tiling = "true";
        restore-workspaces-only-on-primary = "true";
        selection-border-radius-top = 0;
        selection-border-size = 0;
        show-focus-mode-icon = true;
        show-window-position-bar = true;
        show-workspace-indicator = true;
        vertical-margin = 0;
        vertical-margin-bottom = 0;
        window-gap = 8;
        window-switcher-preview-scale = 0.15;
        winprops = [
          ''{"wm_class":"ulauncher","scratch_layer":true}''
        ];
      };

      "org/gnome/shell/extensions/paperwm/workspaces" = {
        list = [
          "9fc9ad15-f615-4734-8ffb-8f2c539aef98"
          "f013fd95-1bcc-46d4-a92c-8fc51965a6e1"
          "83b767ff-0cda-49ac-8d9a-55d35ded0303"
          "a9ca6656-7a05-4b9d-9071-a275c41662c7"
          "ded085f6-360b-49ca-b5b0-88a82cc30b1b"
          "955bc102-ebd1-4dd4-818e-ddc8e2c7f88a"
          "af2ed855-51f2-478c-a71c-a8dfe5050ba8"
          "187bc83c-2430-4759-b489-78f83734b0c5"
          "55b74379-32ef-4a19-95d2-ab2f9df63ee6"
          "680594cd-d7f2-4aba-8fc0-43716677250e"
        ];
      };

      "org/gnome/shell/extensions/paperwm/workspaces/9fc9ad15-f615-4734-8ffb-8f2c539aef98" = {
        background = "";
        color = "rgb(0,0,0)";
        index = 0;
        name = "Workspace 1";
        show-top-bar = true;
      };

      "org/gnome/shell/extensions/paperwm/workspaces/f013fd95-1bcc-46d4-a92c-8fc51965a6e1" = {
        index = 1;
        name = "Workspace 2";
        show-position-bar = true;
        show-top-bar = true;
      };

      "org/gnome/shell/extensions/paperwm/workspaces/83b767ff-0cda-49ac-8d9a-55d35ded0303" = {
        index = 2;
        name = "Workspace 3";
        show-top-bar = true;
      };

      "org/gnome/shell/extensions/paperwm/workspaces/a9ca6656-7a05-4b9d-9071-a275c41662c7" = {
        index = 3;
        name = "Workspace 4";
      };

      "org/gnome/shell/extensions/paperwm/workspaces/ded085f6-360b-49ca-b5b0-88a82cc30b1b" = {
        index = 4;
        name = "Workspace 5";
      };

      "org/gnome/shell/extensions/paperwm/workspaces/955bc102-ebd1-4dd4-818e-ddc8e2c7f88a" = {
        index = 5;
        name = "Workspace 6";
      };

      "org/gnome/shell/extensions/paperwm/workspaces/af2ed855-51f2-478c-a71c-a8dfe5050ba8" = {
        index = 6;
        name = "Workspace 7";
      };

      "org/gnome/shell/extensions/paperwm/workspaces/187bc83c-2430-4759-b489-78f83734b0c5" = {
        index = 7;
        name = "Workspace 8";
      };

      "org/gnome/shell/extensions/paperwm/workspaces/55b74379-32ef-4a19-95d2-ab2f9df63ee6" = {
        index = 8;
        name = "Workspace 9";
      };

      "org/gnome/shell/extensions/paperwm/workspaces/680594cd-d7f2-4aba-8fc0-43716677250e" = {
        index = 9;
        name = "Workspace 10";
      };

      "org/gnome/shell/extensions/paperwm/keybindings" = {
        close-window = [ "<Shift><Super>q" ];
        move-down = [ "<Shift><Super>j" ];
        move-down-workspace = [ "<Control><Super>j" ];
        move-left = [ "<Shift><Super>h" ];
        move-right = [ "<Shift><Super>l" ];
        move-up = [ "<Shift><Super>k" ];
        move-up-workspace = [ "<Control><Super>k" ];
        new-window = [ "<Super>n" ];
        switch-down-workspace = [ "<Super>j" ];
        switch-next = [ "<Super>l" ];
        switch-previous = [ "<Super>h" ];
        switch-up-workspace = [ "<Super>k" ];
        toggle-scratch = [ "<Control><Super>Escape" "<Shift><Super>f" ];
      };

      "org/gnome/shell/extensions/vitals" = {
        hide-icons = false;
        hot-sensors = [ "_memory_usage_" "_processor_usage_" "__temperature_avg__" "__network-rx_max__" "__network-tx_max__" "__fan_avg__" ];
        icon-style = 0;
        include-static-info = true;
        show-battery = false;
        show-storage = false;
        show-system = false;
        show-voltage = false;
        use-higher-precision = false;
      };

      "org/gnome/shell/extensions/weatherornot" = {
        position = "right";
      };
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
