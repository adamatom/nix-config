{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.mullvad-vpn ];

  systemd.services.mullvad-daemon = {
    description = "Mullvad VPN daemon";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "NetworkManager.service"
      "systemd-resolved.service"
    ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad-daemon -v --disable-stdout-timestamps";
      Restart = "always";
      RestartSec = 1;
    };
  };
}
