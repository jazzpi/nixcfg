{ lib, ... }:
{
  options.j = {
    personal.enable = lib.mkEnableOption "Personal" // {
      default = false;
    };
    work.enable = lib.mkEnableOption "Work" // {
      default = false;
    };
    gui = {
      i3.enable = lib.mkEnableOption "i3 window manager" // {
        default = false;
      };
      logic.enable = lib.mkEnableOption "Saleae Logic" // {
        default = false;
      };
    };
  };
}
