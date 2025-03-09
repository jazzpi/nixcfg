{ lib, config, ... }:
{
  options.j.personal = {
    enable = lib.mkEnableOption "Personal" // {
      default = false;
    };
  };
  config = lib.mkIf config.j.personal.enable {
    jh.nextcloud.enable = true;
    jh.keepass.enable = true;
    j.im.telegram.enable = true;
    j.im.signal.enable = true;
    j.gui.libreoffice.enable = true;
  };
}
