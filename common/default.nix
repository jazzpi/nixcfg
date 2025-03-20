{ lib, config, ... }:
{
  options.j = {
    personal.enable = lib.mkEnableOption "Personal" // {
      default = false;
    };
    work.enable = lib.mkEnableOption "Work" // {
      default = false;
    };
    gui = {
      enable = lib.mkEnableOption "GUI" // {
        default = true;
      };
      i3.enable = lib.mkEnableOption "i3 window manager" // {
        default = config.j.gui.enable;
      };
      logic.enable = lib.mkEnableOption "Saleae Logic" // {
        default = false;
      };
    };
    networking = {
      enable = lib.mkEnableOption "Networking" // {
        default = true;
      };
      can = lib.mkEnableOption "CAN" // {
        default = false;
      };
    };
  };
}
