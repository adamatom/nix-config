{
  config,
  pkgs,
  lib,
  ...
}:

let
  wrapGL = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;
in
{
  home.packages = lib.mkAfter [
    (wrapGL pkgs.slack)
  ];

  # Chromium exists only to host the Outlook and Teams PWAs, which open every
  # link in Chromium. The "Open in Firefox" extension (Reverse Mode) sends
  # non-Microsoft links to Firefox through its native messaging host.
  # The PWAs and the extension's settings are Chromium policy, which lives in
  # /etc and is managed by system-manager (see system/chromium-policies.nix).
  programs.chromium = {
    enable = true;
    package = wrapGL pkgs.chromium;
    extensions = [
      # andy-portmen's "Open in Firefox", installed from the Chrome Web Store.
      { id = "lmeddoobegbaiopohmpmmobpnpjifpii"; }
    ];
    nativeMessagingHosts = [
      (pkgs.callPackage ../../pkgs/add0n-native-client.nix {
        # The same nixGL- and memcap-wrapped Firefox as the desktop launcher.
        firefox = config.programs.firefox.finalPackage;
      })
    ];
  };
}
