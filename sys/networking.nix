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

  config = lib.mkIf config.j.networking.enable {
    networking.networkmanager.enable = true;
    # TODO: networking.wireless.enable ?
    networking.firewall.checkReversePath = false;

    # Make /etc/hosts editable for quick hacks -- these will be discarded on
    # the next NixOS rebuild.
    environment.etc.hosts.mode = "0644";

    environment.systemPackages =
      with pkgs;
      (lib.optional config.j.networking.wireguard wireguard-tools)
      ++ (lib.optional config.j.networking.can can-utils);
  };
}
