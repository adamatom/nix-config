# GNOME: the desktop itself on NixOS, plus desktop settings, keybindings,
# shell extensions and PaperWM for home-manager.
{
  flake.modules.nixos.gnome = {
    services = {
      # Enable the GNOME Desktop Environment.
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;

      xserver = {
        enable = true;

        # Configure keymap in X11
        xkb = {
          layout = "us";
          variant = "";
        };
      };
    };
  };

  flake.modules.homeManager.gnome =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # GTK theme
        adw-gtk3

        # GNOME Shell Extensions (needed for the dconf settings to work)
        gnomeExtensions.bing-wallpaper-changer
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.grand-theft-focus
        gnomeExtensions.launch-new-instance
        gnomeExtensions.paperwm
        gnomeExtensions.resource-monitor
      ];

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
            begin-move = [ ];
            begin-resize = [ ];
            close = [ ];
            minimize = [ ];
            move-to-monitor-down = [ ];
            move-to-monitor-left = [ ];
            move-to-monitor-right = [ ];
            move-to-monitor-up = [ ];
            move-to-workspace-1 = [ "<Shift><Super>1" ];
            move-to-workspace-2 = [ "<Shift><Super>2" ];
            move-to-workspace-3 = [ "<Shift><Super>3" ];
            move-to-workspace-4 = [ "<Shift><Super>4" ];
            move-to-workspace-down = [ ];
            move-to-workspace-last = [ ];
            move-to-workspace-left = [ ];
            move-to-workspace-right = [ ];
            move-to-workspace-up = [ ];
            show-desktop = [ ];
            switch-applications = [ ];
            switch-applications-backward = [ ];
            switch-group = [ ];
            switch-group-backward = [ ];
            switch-input-source = [ ];
            switch-input-source-backward = [ ];
            switch-panels = [ ];
            switch-panels-backward = [ ];
            switch-to-workspace-1 = [ "<Super>1" ];
            switch-to-workspace-2 = [ "<Super>2" ];
            switch-to-workspace-3 = [ "<Super>3" ];
            switch-to-workspace-4 = [ "<Super>4" ];
            switch-to-workspace-last = [ ];
            switch-to-workspace-left = [ ];
            switch-to-workspace-right = [ ];
            switch-windows = [ ];
            switch-windows-backward = [ ];
            toggle-maximized = [ ];
          };

          "org/gnome/desktop/wm/preferences" = {
            num-workspaces = 10;
          };

          "org/gnome/mutter" = {
            overlay-key = "";
          };

          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-timeout = 1800;
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-battery-timeout = 1800;
            sleep-inactive-battery-type = "suspend";
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
            focus-active-notification = [ ];
            shift-overview-down = [ ];
            shift-overview-up = [ ];
            switch-to-application-1 = [ ];
            switch-to-application-2 = [ ];
            switch-to-application-3 = [ ];
            switch-to-application-4 = [ ];
            toggle-application-view = [ "<Super>space" ];
            toggle-message-tray = [ ];
            toggle-overlay = [ ];
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
            cycle-width-steps = [
              0.25
              0.33
              0.5
              0.66
              0.75
              1.0
            ];
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
            toggle-scratch = [
              "<Control><Super>Escape"
              "<Shift><Super>f"
            ];
          };

          "org/gnome/shell/extensions/vitals" = {
            hide-icons = false;
            hot-sensors = [
              "_memory_usage_"
              "_processor_usage_"
              "__temperature_avg__"
              "__network-rx_max__"
              "__network-tx_max__"
              "__fan_avg__"
            ];
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
    };
}
