{ config, pkgs, lib, ... }:

{
  options.features.remapCaps.enable = lib.mkEnableOption "Enable interception-tools with caps2esc";

  config = lib.mkIf config.features.remapCaps.enable {
    services.interception-tools = let
      itools = pkgs.interception-tools;
      itools-caps = pkgs.interception-tools-plugins.caps2esc;
    in {
      enable = true;
      plugins = [ itools-caps ];
      # requires explicit paths: https://github.com/NixOS/nixpkgs/issues/126681
      udevmonConfig = pkgs.lib.mkDefault ''
        - JOB: "${itools}/bin/intercept -g $DEVNODE | ${itools-caps}/bin/caps2esc -m 1 | ${itools}/bin/uinput -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
      '';
    };
  };
}
