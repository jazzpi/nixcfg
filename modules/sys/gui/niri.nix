{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.j.gui.niri.enable {
    programs.niri.enable = true;

    # TODO: Do we need to add xdg-desktop-portal-hyprland to the packages?
    # TODO: Replace with xdg-desktop-portal-wlr for individual window support?
    # TODO: Why doesn't this work if we configure it in the HM module?
    xdg.portal = {
      enable = true;
      config.niri.default = lib.mkForce [
        "wlr"
        "hyprland"
        "gnome"
      ];
      configPackages = [ pkgs.xdg-desktop-portal-wlr ];
    };

    j.gui.uwsm = {
      enable = true;
      compositors = {
        niri = {
          name = "Niri";
          binPath = "${pkgs.niri}/bin/niri";
          extraArgs = [ "--session" ];
        };
      };
    };
    j.gui.displayManager.defaultSession = lib.mkDefault "niri-uwsm";
  };
}
