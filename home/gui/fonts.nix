{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.j.gui.fonts = {
    enable = lib.mkEnableOption "Install fonts" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.gui.fonts.enable {
    home.packages = with pkgs; [
      font-awesome_5
    ];
  };
}
