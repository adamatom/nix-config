# Outlook and Teams as Chromium PWAs, with every non-Microsoft link opened in
# Firefox by the "Open in Firefox" extension (Reverse Mode) and its native host.
#
# One feature, two halves: home-manager installs Chromium, the extension and
# the native host; system-manager writes the Chromium policy to /etc.
let
  # andy-portmen's "Open in Firefox" (Chrome Web Store).
  openInFirefox = "lmeddoobegbaiopohmpmmobpnpjifpii";
in
{
  flake.modules.homeManager.outlook-pwa =
    {
      config,
      pkgs,
      wrapGL,
      ...
    }:
    {
      programs.chromium = {
        enable = true;
        package = wrapGL pkgs.chromium;
        extensions = [ { id = openInFirefox; } ];
        nativeMessagingHosts = [
          (pkgs.callPackage ../pkgs/add0n-native-client.nix {
            # The same nixGL- and memcap-wrapped Firefox as the desktop launcher.
            firefox = config.programs.firefox.finalPackage;
          })
        ];
      };
    };

  # Chromium only reads policy from /etc, so this half needs system-manager.
  flake.modules.systemManager.outlook-pwa = {
    environment.etc."chromium/policies/managed/outlook-teams.json".text = builtins.toJSON {
      # Install both apps as standalone windows, with app launcher entries.
      WebAppInstallForceList = [
        {
          url = "https://outlook.office.com/mail/";
          default_launch_container = "window";
          fallback_app_name = "Outlook";
        }
        {
          url = "https://teams.cloud.microsoft/";
          default_launch_container = "window";
          fallback_app_name = "Microsoft Teams";
        }
      ];

      # Settings for Open in Firefox, read through its managed storage schema.
      # Reverse mode sends every link to Firefox except these hosts, so mail,
      # chat and Microsoft sign-in stay inside the PWAs.
      "3rdparty".extensions.${openInFirefox} = {
        reverse = true;
        hosts = [
          "outlook.office.com"
          "outlook.office365.com"
          "outlook.cloud.microsoft"
          "teams.microsoft.com"
          "teams.cloud.microsoft"
          "login.microsoftonline.com"
        ];
      };
    };
  };
}
