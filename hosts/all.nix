{ pkgs, ... }:

{
  # NixOS settings used for any host.

  # Install simpler programs/binaries
  environment.systemPackages = with pkgs; [
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
  ];

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

  networking.networkmanager.enable = true;

  # Install programs with more complete OS integration (desktop files, etc).
  # programs.pkg.enable is prioritized over pkgs.pkg if it exists.
  programs = {
    # This needs to be installed at the host level/nixos level to fill in for the
    # /lib/ld-linux-x86-64.so.2 interpreter that unpatched binaries expect. If we were running
    # home-manager on Ubuntu, then I think the unpatched binaries would just run
    nix-ld.enable = true;
    zsh.enable = true;
  };

  services = { };

  security = {
    # pam.enableLimits = true;

    pam.loginLimits = [
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

  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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
        "plugdev"
      ];
      packages = [ ];
    };
  };
}
