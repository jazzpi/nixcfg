{ pkgs, ... }:
{
  home.stateVersion = "24.11";

  j.personal.enable = true;
  j.gui.firefox.defaultProfile = "personal";

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
      "HDMI-1"
      "DP-1"
      "DP-2"
    ];
  };

  home.packages = with pkgs; [
    kicad
  ];
}
