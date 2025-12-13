{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.j.gui.niri.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
  };
}
