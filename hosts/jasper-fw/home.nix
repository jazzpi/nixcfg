{ pkgs, ... }:
{
  home.stateVersion = "24.11";

  j.personal.enable = true;
  j.gui.i3 = {
    enable = true;
    screens = [
      "eDP-1"
    ];
  };
  j.gui.gimp.enable = true;
  j.gui.eww = {
    backlight = true;
    battery = {
      enable = true;
      batteryName = "BAT1";
    };
  };

  home.packages = with pkgs; [
    kicad
    stm32cubemx
  ];
}
