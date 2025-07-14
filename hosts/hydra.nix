# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../modules/hardware/hydra.nix
    ];

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "fs.mqueue.msg_max" = 16384;
    "fs.mqueue.queues_max" = 1024;
    "fs.mqueue.msgsize_max" = 8192;
  };

  # This will disable the discrete graphics, but also kills sound
  # boot.kernelParams = ["module_blacklist=i915"];

  # Enable OpenGL
  hardware = {
    graphics.enable = true;

    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      open = false;

      # Enable the Nvidia settings menu,
          # accessible via `nvidia-settings`.
          nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    printers = {
      ensureDefaultPrinter = "Brother_HL_L2350DW";
      ensurePrinters = [
        {
          name = "Brother_HL_L2350DW";
          deviceUri = "dnssd://Brother%20HL-L2350DW%20series._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-a8934a957a34";
          model = "everywhere";       # Use IPP Everywhere
          ppdOptions = {
            PageSize = "A4";
          };
        }
      ];
    };

    saleae-logic.enable = true;
  };

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
  };

  networking = {
    hostName = "hydra";
    networkmanager.enable = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
