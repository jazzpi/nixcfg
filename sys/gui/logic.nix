{
  lib,
  config,
  ...
}:
{
  # TODO: Do we need to declare this option both here and in the home config
  options.j.gui.logic = {
    enable = lib.mkEnableOption "Saleae Logic" // {
      default = false;
    };
  };

  config = lib.mkIf config.j.gui.logic.enable {
    hardware.saleae-logic.enable = true;
  };
}
