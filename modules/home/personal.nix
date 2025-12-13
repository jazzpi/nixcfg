{ lib, config, ... }:
{
  config = lib.mkIf config.j.personal.enable {
    j.gui.nextcloud.enable = true;
    j.gui.keepass.enable = true;
    j.gui.im.telegram.enable = true;
    j.gui.im.signal.enable = true;
    j.gui.im.discord.enable = true;
    j.gui.libreoffice.enable = true;
  };
}
