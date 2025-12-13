{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.j.gui.hyprland.enable {
    programs.hyprland =
      let
        hyprPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;

        package = hyprPkgs.hyprland;
        portalPackage = hyprPkgs.xdg-desktop-portal-hyprland;
      };
    # We need to make sure we use the same mesa version as hyprland
    hardware.graphics =
      let
        hyprPkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        package = hyprPkgs.mesa;
        package32 = hyprPkgs.pkgsi686Linux.mesa;
      };
    security.pam.services.hyprlock = { };
    j.gui.gnome-keyring.enable = true;
    services.displayManager.defaultSession = lib.mkDefault "hyprland-uwsm";
  };
}
