{ lib, config, ... }:
{
  config = lib.mkIf config.j.personal.enable {
    j.gui = {
      nextcloud.enable = true;
      keepass.enable = true;
      calibre.enable = true;
      libreoffice.enable = true;
      im = {
        telegram.enable = true;
        signal.enable = true;
        discord.enable = true;
        element.enable = true;
      };
    };
  };
}
