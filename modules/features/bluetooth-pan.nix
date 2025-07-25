{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge;
in {
  options.bluetoothPan.enable = lib.mkEnableOption "Bluetooth PAN (NAP) server";

  config = mkIf config.bluetoothPan.enable (mkMerge [
    {
      # Enable required packages and services
      environment.systemPackages = with pkgs; [ bluez-tools bluez ];

      services.dbus.enable = true;
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;

      # Enable IP forwarding system-wide
      boot.kernel.sysctl."net.ipv4.ip_forward" = "1";

      # Set up the bridge interface pan0 using systemd-networkd
      systemd.network.enable = true;

      systemd.network.netdevs.pan0 = {
        netdevConfig = {
          Name = "pan0";
          Kind = "bridge";
        };
      };

      systemd.network.networks."bt-client" = {
        matchConfig.Name = "enp0s20f0u*";
        networkConfig = {
          Bridge = "pan0";
        };
      };

      systemd.network.networks.pan0 = {
        matchConfig.Name = "pan0";
        networkConfig = {
          Address = "172.20.1.1/24";
          DHCPServer = true;
          IPv4Forwarding = true;
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          PoolSize = 50;
          DefaultLeaseTimeSec = 600;
          MaxLeaseTimeSec = 3600;
        };
      };

      # Optional: enable NAT (replace wlp82s0 with your internet iface)
      networking.nat = {
        enable = true;
        internalInterfaces = [ "pan0" ];
        externalInterface = "wlp82s0";
      };

      # Set up systemd services for bt-agent and bt-network
      systemd.services.bt-agent = {
        description = "Bluetooth Auth Agent";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.bluez-tools}/bin/bt-agent -c NoInputNoOutput";
          Type = "simple";
        };
      };

      systemd.services.bt-network = {
        description = "Bluetooth PAN NAP server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.bluez-tools}/bin/bt-network -s nap pan0";
          Type = "simple";
        };
      };

      hardware.bluetooth.settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";  # Optional, but helps
          Experimental = true;
          ControllerMode = "dual";
          Name = "hydra";
          Class = "0x000100";
          MultiProfile = "multiple";
        };
      };

      services.dnsmasq = {
        enable = true;
        settings = {
          interface = "pan0";
          bind-interfaces = true;
          dhcp-range = "172.20.1.100,172.20.1.150,12h";
        };
      };

      systemd.services.bluetooth.serviceConfig.ExecStart = lib.mkForce [
        ""  # reset existing ExecStart
        "${pkgs.bluez}/libexec/bluetooth/bluetoothd --compat"
      ];
    }
  ]);
}

