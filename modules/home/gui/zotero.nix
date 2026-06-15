{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.zotero = {
    enable = lib.mkEnableOption "Zotero";
  };

  config = lib.mkIf config.j.gui.zotero.enable {
    home.packages = with pkgs; [
      zotero
    ];
  };
}
