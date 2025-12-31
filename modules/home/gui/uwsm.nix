{ lib, config, ... }:
with lib;
{
  config = mkIf config.j.gui.uwsm.enable {
    xdg.configFile."uwsm/env".text = ''
      export XCURSOR_SIZE=24
      export QT_QPA_PLATFORMTHEME=qt5ct
      export NIXOS_OZONE_WL=1
    '';
  };
}
