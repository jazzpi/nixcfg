{ pkgs, rootPath, ... }:
{
  home.stateVersion = "24.11";

  j.personal.enable = true;
  j.work.enable = true;
  j.gui.firefox.defaultProfile = "personal";
  j.networking.can = true;
  j.gui.im.slack.autostart = false;

  j.gui.i3 = {
    enable = true;
    workspaceAssignments = {
      "1" = "DP-1";
      "2" = "DP-1";
      "i" = "DP-2";
      "4" = "DP-2";
      "5" = "DP-2";
    };
    screens = [
      "HDMI-0"
      "HDMI-1"
      "DP-0"
      "DP-1"
      "DP-2"
      "DP-3"
    ];
  };

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "desk-all";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            position = "0,0";
          }
          {
            criteria = "DP-1";
            position = "400,1080";
          }
          {
            criteria = "DP-2";
            position = "1920,0";
          }
        ];
        profile.exec = [
          "${rootPath}/dotfiles/eww/scripts/restart.sh"
        ];
      }
    ];
  };

  j.gui.drawio.enable = true;
  home.packages = with pkgs; [
    kicad
    stm32cubemx
    gimp3-with-plugins
  ];
}
