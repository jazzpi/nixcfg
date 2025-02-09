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
    environment.xfce.excludePackages = with pkgs.xfce; [
      mousepad
      parole
      ristretto
      xfce4-appfinder
      xfce4-notifyd
      xfce4-screenshooter
      xfce4-session
      xfce4-taskmanager
      xfce4-terminal
    ];
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
      desktopManager = {
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
    };
    services.displayManager = {
      defaultSession = "xfce+i3";
    };
  };
}
