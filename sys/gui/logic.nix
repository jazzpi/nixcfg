{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.j.gui.logic.enable {
    hardware.saleae-logic.enable = true;
  };
}
