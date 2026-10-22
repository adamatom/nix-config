# What every machine gets: identity, shell, everyday CLI tools. On NixOS also
# the user account, locale, networking and basic system tools, with
# home-manager built into the system.
{ config, inputs, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      # Bring the home-manager half along on NixOS.
      home-manager.sharedModules = [ config.flake.modules.homeManager.base ];

      # Every NixOS machine runs home-manager as part of the system build,
      # reusing the system pkgs instead of importing nixpkgs again.
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      # Flakes, plus the numtide binary cache for llm-agents and system-manager.
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };

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
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home = {
        username = "adam";
        homeDirectory = "/home/adam";
      };

      home.packages = with pkgs; [
        # CLI tools
        curlFull
        fd
        file
        fzf
        gawk
        glab
        gnupg
        gnused
        gnutar
        jq
        killall
        mcfly
        nmap
        ripgrep
        tree
        wget
        which
        xclip
        xz
        zip
        unzip
        zoxide
        zstd

        # system libs
        libxcrypt
      ];

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableZshIntegration = true;
        };

        htop.enable = true;

        bat = {
          enable = true;
          # Leave a little room on the right, so long lines don't touch the
          # terminal edge.
          config.terminal-width = "-4";
        };

        # Let home Manager install and manage itself.
        home-manager.enable = true;
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
    };
}
