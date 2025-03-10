{ lib, config, ... }:
{
  options.j.gui.common = {
    enable = lib.mkEnableOption "Common GUI Config" // {
      default = true;
    };
  };
  config = lib.mkIf config.j.gui.common.enable {
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
    location = config.j.common.location;
  };
}
