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

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "desc:AU Optronics B140UAN08.0, 1920x1200, 3840x0, 1.5"
      "desc:ODY i27 0000000000001, 1920x1080, 1920x0, 1"
      "desc:ASUSTek COMPUTER INC PA248QV MCLMQS198413, 1920x1200, 0x0, 1"
      ", preferred, auto, auto"
    ];
  };

  home.packages = with pkgs; [
    libreoffice-qt-fresh
    ungoogled-chromium
    stm32cubemx
  ];
}
