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
    };
  };
}
