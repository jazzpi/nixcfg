{ config, lib, ... }:
{
  imports = [
    ./i3.nix
    ./logic.nix
    ./wireshark.nix
  ];

  config = lib.mkIf config.j.gui.enable {
    services = {
      redshift = {
        enable = true;
        temperature = {
          day = 5500;
          night = 3700;
        };
      };
      geoclue2.enable = true;
    };
    location = config.j.location;
  };
}
