{
  pkgs,
  pkgs-stable,
  rootPath,
  ...
}:
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

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.0;
          }
        ];
        profile.exec = [
          "${rootPath}/dotfiles/eww/scripts/restart.sh"
        ];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "ASUSTek COMPUTER INC PA248QV MCLMQS198413";
            scale = 1.0;
            mode = "--custom 1920x1200@55Hz";
            position = "0,0";
          }
          {
            criteria = "ODY i27 0000000000001";
            scale = 1.0;
            mode = "1920x1080";
            position = "1920,0";
          }
          {
            criteria = "eDP-1";
            scale = 1.5;
            mode = "1920x1200";
            position = "3840,0";
          }
        ];
        profile.exec = [
          "${rootPath}/dotfiles/eww/scripts/restart.sh"
        ];
      }
      {
        profile.name = "presentation";
        profile.outputs = [
          {
            criteria = "Hisense Electric Co., Ltd. HISENSE 0x00000001";
            scale = 3.0;
            mode = "3840x2160@30Hz";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            scale = 1.0;
            mode = "1920x1200";
            position = "${builtins.toString (builtins.ceil (3840 / 3))},0";
          }
        ];
        profile.exec = [
          "${rootPath}/dotfiles/eww/scripts/restart.sh"
        ];
      }
    ];
  };

  home.packages = with pkgs; [
    libreoffice-qt-fresh
    ungoogled-chromium
    stm32cubemx
    obs-studio
    openocd
    minicom
    pkgs-stable.kicad
  ];
}
