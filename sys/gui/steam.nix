{
  lib,
  config,
  pkgs,
  host,
  ...
}:
{
  options.j.gui.steam = {
    enable = lib.mkEnableOption "Steam" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.steam.enable {
    programs.steam = {
      enable = true;
    };
  };
}
