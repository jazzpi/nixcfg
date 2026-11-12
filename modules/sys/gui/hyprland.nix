{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.j.gui.hypr.land.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      # Also keeps the package identical to the Hydra-cached pkgs.hyprland,
      # which is built with UWSM support.
      withUWSM = true;
    };
    security.pam.services.hyprlock = { };
    j.gui.gnome-keyring.enable = true;
    j.gui.displayManager.defaultSession = lib.mkDefault "hyprland-uwsm";
    j.gui.uwsm.enable = true;
  };
}
