{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.j.gui.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    security.pam.services.hyprlock = { };
    j.gui.gnome-keyring.enable = true;
    services.displayManager.defaultSession = lib.mkDefault "hyprland-uwsm";
  };
}
