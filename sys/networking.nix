{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.networking = {
    wireguard = lib.mkEnableOption "Wireguard" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.networking.enable {
    networking = {
      networkmanager.enable = true;
      # TODO: wireless.enable ?
      firewall.checkReversePath = false;
    };

    # Make /etc/hosts editable for quick hacks -- these will be discarded on
    # the next NixOS rebuild.
    environment.etc.hosts.mode = "0644";

    environment.systemPackages =
      with pkgs;
      (lib.optional config.j.networking.wireguard wireguard-tools)
      ++ (lib.optional config.j.networking.can can-utils);

    systemd.network = lib.mkIf config.j.networking.can {
      netdevs.vcan0 = {
        netdevConfig = {
          Name = "vcan0";
          Kind = "vcan";
        };
      };
      # We need to add a network matching the netdev to automatically bring up
      # the link
      networks.vcan0 = {
        matchConfig = {
          Name = "vcan0";
        };
      };
      enable = true;
      wait-online.enable = false;
    };
  };
}
