{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui.obsidian = {
    enable = lib.mkEnableOption "Obsidian" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.gui.obsidian.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
