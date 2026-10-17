# Chromium policy for the Outlook and Teams PWAs. Chromium only reads policy
# from /etc, so this lives in system-manager rather than home-manager.
let
  # andy-portmen's "Open in Firefox" (Chrome Web Store).
  openInFirefox = "lmeddoobegbaiopohmpmmobpnpjifpii";
in
{
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
}
