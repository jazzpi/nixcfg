{
  lib,
  config,
  pkgsu,
  ...
}:
{
  options.j.gui.obsidian = {
    enable = lib.mkEnableOption "Obsidian" // {
      default = config.j.gui.enable;
    };
  };

  config = lib.mkIf config.j.gui.obsidian.enable {
    home.packages = with pkgsu; [
      obsidian
    ];
  };
}
