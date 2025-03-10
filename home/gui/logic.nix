{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.j.gui.logic.enable {
    home.packages = with pkgs; [
      saleae-logic-2
    ];
  };
}
