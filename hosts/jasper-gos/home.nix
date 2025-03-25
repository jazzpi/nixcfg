{ pkgs, ... }:
{
  home.stateVersion = "24.11";

  j.work.enable = true;
  j.gui.i3 = {
    enable = true;
    screens = [
      "eDP-1"
      "DP-7"
      "DP-8"
    ];
  };
  j.gui.firefox.defaultProfile = "work";
  j.gui.logic.enable = true;
  j.gui.gimp.enable = true;
  j.gui.eww = {
    backlight = true;
    battery = {
      enable = true;
      batteryName = "BAT0";
    };
  };
  j.gui.im.telegram.enable = true;

  j.networking.can = true;

  home.packages = with pkgs; [
    libreoffice-qt-fresh
  ];
}
