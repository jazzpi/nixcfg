{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.gui.i3 = {
    enable = lib.mkEnableOption "i3 window manager" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.i3.enable {
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };
    services.displayManager = {
      defaultSession = "none+i3";
    };
  };
}
