{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.libreoffice = {
    enable = lib.mkEnableOption "LibreOffice" // {
      default = false;
    };
  };
  config = lib.mkIf config.j.gui.libreoffice.enable {
    home.packages = with pkgs; [
      libreoffice-fresh
      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_DE
    ];
  };
}
