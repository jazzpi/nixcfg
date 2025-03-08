{ pkgs, ... }:
let
  users = import ../../config/users.nix;
in
{
  home = {
    username = users.default;
    homeDirectory = "/home/${users.default}";
    stateVersion = "24.11";
    packages = with pkgs; [
      kicad
    ];
  };

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
}
