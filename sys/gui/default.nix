{ config, ... }:
{
  imports = [
    ./i3.nix
    ./logic.nix
    ./wireshark.nix
  ];

  config = {
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
