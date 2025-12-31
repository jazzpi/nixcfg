{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  hyprNixPkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = lib.mkIf config.j.gui.hypr.land.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;

      package = hyprPkgs.hyprland;
      portalPackage = hyprPkgs.xdg-desktop-portal-hyprland;
    };
    # We need to make sure we use the same mesa version as hyprland
    hardware.graphics = {
      package = hyprNixPkgs.mesa;
      package32 = hyprNixPkgs.pkgsi686Linux.mesa;
    };
    security.pam.services.hyprlock = { };
    j.gui.gnome-keyring.enable = true;
    services.displayManager.defaultSession = lib.mkDefault "hyprland-uwsm";

    j.gui.uwsm = {
      enable = true;
      compositors = {
        hyprland = {
          name = "Hyprland";
          binPath = "${hyprPkgs.hyprland}/bin/hyprland";
        };
      };
    };
  };
}
