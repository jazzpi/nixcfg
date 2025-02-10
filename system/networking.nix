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

    };
  };

  config =
    lib.mkIf config.j.networking.enable {
      networking.networkmanager.enable = true;
      # TODO: networking.wireless.enable ?
      networking.firewall.checkReversePath = false;
    }
    // lib.mkIf config.j.networking.wireguard {
      environment.systemPackages = with pkgs; [
        wireguard-tools
      ];
    };
}
