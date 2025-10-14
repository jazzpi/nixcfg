{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.gimp = {
    enable = lib.mkEnableOption "GIMP" // {
      default = false;
    };
    plugins = {
      enable = lib.mkEnableOption "GIMP plugins" // {
        default = true;
      };
    };
  };

  config = lib.mkIf config.j.gui.gimp.enable {
    home.packages = with pkgs; [
      (if config.j.gui.gimp.plugins.enable then gimp-with-plugins else gimp)
    ];
  };
}
