{
  lib,
  config,
  pkgs,
  ...
}:
{
  # TODO: Do we need to declare this option both here and in the system config
  options.j.gui.logic = {
    enable = lib.mkEnableOption "Saleae Logic" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.logic.enable {
    home.packages = with pkgs; [
      saleae-logic-2
    ];
  };
}
