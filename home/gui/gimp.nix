{
  lib,
  config,
  pkgs-stable,
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
    # TODO: As of 2025-07-16 unstable GIMP fails to build
    home.packages = with pkgs-stable; [
      (if config.j.gui.gimp.plugins.enable then gimp-with-plugins else gimp)
    ];
  };
}
