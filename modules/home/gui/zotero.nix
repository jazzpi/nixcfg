{
  lib,
  config,
  # FIXME: zotero is broken on unstable
  pkgs-stable,
  ...
}:
{
  options.j.gui.zotero = {
    enable = lib.mkEnableOption "Zotero";
  };

  config = lib.mkIf config.j.gui.zotero.enable {
    home.packages = with pkgs-stable; [
      zotero
    ];
  };
}
