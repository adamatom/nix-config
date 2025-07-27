{ config, pkgs, ... }:

{
  # NixOS settings used for any host.
  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware = {
    graphics.enable = true;
    saleae-logic.enable = true;
  };

  networking.networkmanager.enable = true;

  services = {
    # Just ignore the lid
    logind.lidSwitch = "ignore";

    # Load nvidia driver for Xorg and Wayland
    xserver.videoDrivers = ["nvidia"];

    # Enable the X11 windowing system.
    xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    udev = {
      extraRules = ''
        # FTDI FT2232H Dual RS232-HS: Vendor 0403, Product 6010, commonly used for openocd jtagging
        SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666", GROUP="dialout"
      '';
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      browsing = true;  # allow discovering network printers via DNS-SD
      defaultShared = false;  # dont share this printer with others
      drivers = [ 
        # enable if IPP everywhere printing has issues:
        # pkgs.cups-brother-hll2350dw 
      ];
    };

    # Enable avahi for discoverying printers (and other things)
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable sound with pipewire.
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable tailscale
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };
  security.rtkit.enable = true;

  # security.pam.enableLimits = true;

  security.pam.loginLimits = [
    {
      domain = "adam";
      type = "hard";
      item = "rtprio";
      value = "99";
    }
    {
      domain = "adam";
      type = "soft";
      item = "rtprio";
      value = "99";
    }
    {
      domain = "adam";
      type = "hard";
      item = "msgqueue";
      value = "16777216";
    }
    {
      domain = "adam";
      type = "soft";
      item = "msgqueue";
      value = "16777216";
    }
  ];


  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  virtualisation.docker.enable = true;

  # Install programs with more complete OS integration (desktop files, etc).
  # programs.pkg.enable is prioritized over pkgs.pkg if it exists.
  programs = {
    zsh.enable = true;

    # This needs to be installed at the host level/nixos level to fill in for the
    # /lib/ld-linux-x86-64.so.2 interpreter that unpatched binaries expect. If we were running
    # home-manager on Ubuntu, then I think the unpatched binaries would just run
    nix-ld.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };

  # Install simpler programs/binaries
  environment.systemPackages = with pkgs; [
      sysstat
      lm_sensors
      ethtool
      pciutils
      usbutils
    ];

  users = {
    defaultUserShell = pkgs.zsh;
    extraGroups.plugdev = { };
    users.adam = {
      isNormalUser = true;
      description = "adam";
      shell = pkgs.zsh;
      extraGroups = [
        "networkmanager"
        "wheel"
        "dialout"
        "plugdev"
        "docker"
      ];
      packages = with pkgs; [ ];
    };
  };
}
