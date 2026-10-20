# Tailscale VPN, as a client that can use other nodes' routes and exit nodes.
{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };
}
