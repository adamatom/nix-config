# Printing through CUPS, with network printers discovered over Avahi (DNS-SD).
{
  flake.modules.nixos.printing = {
    services = {
      # Enable avahi for discoverying printers (and other things)
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      # Enable CUPS to print documents.
      printing = {
        enable = true;
        browsing = true; # allow discovering network printers via DNS-SD
        defaultShared = false; # dont share this printer with others
        drivers = [
          # enable if IPP everywhere printing has issues:
          # pkgs.cups-brother-hll2350dw
        ];
      };
    };
  };
}
