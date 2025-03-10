{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    j.networking = {
      enable = lib.mkEnableOption "Networking" // {
        default = true;
      };
      wireguard = lib.mkEnableOption "Wireguard" // {
        default = false;
      };
      can = lib.mkEnableOption "CAN" // {
        default = false;
      };
    };
  };

  config =
    lib.mkIf config.j.networking.enable {
      networking.networkmanager.enable = true;
      # TODO: networking.wireless.enable ?
      networking.firewall.checkReversePath = false;

      # Make /etc/hosts editable for quick hacks -- these will be discarded on
      # the next NixOS rebuild.
      networking.extraHosts = "192.168.2.103 books.jazzpi.de";
    }
    // lib.mkIf config.j.networking.wireguard {
      environment.systemPackages = with pkgs; [
        wireguard-tools
      ];
    }
    // lib.mkIf config.j.networking.can {
      environment.systemPackages = with pkgs; [
        can-utils
      ];
    };
}
