{
  lib,
  config,
  pkgs,
  rootPath,
  ...
}:
{
  config = lib.mkIf config.j.gui.hyprland.enable {
    j.gui.kitty.enable = true;
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    j.gui.eww.enable = true;
    # Needed for eww scripts
    home.packages = with pkgs; [ socat ];

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile "${rootPath}/dotfiles/hypr/hyprland.conf";
    };
  };
}
