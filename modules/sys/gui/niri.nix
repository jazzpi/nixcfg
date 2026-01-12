{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    {
      # We manage the cache ourselves in flake.nix
      niri-flake.cache.enable = false;
    }
    (lib.mkIf config.j.gui.niri.enable {
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };

      # TODO: Do we need to add xdg-desktop-portal-hyprland to the packages?
      # TODO: Replace with xdg-desktop-portal-wlr for individual window support?
      # TODO: Why doesn't this work if we configure it in the HM module?
      xdg.portal = {
        enable = true;
        config.niri.default = [
          "hyprland"
          "gnome"
        ];
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
    })
  ];
}
