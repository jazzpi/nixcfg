{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.j.gui.i3.enable {
    environment.xfce.excludePackages = with pkgs; [
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
    j.gui.displayManager.defaultSession = lib.mkDefault "xfce+i3";
  };
}
