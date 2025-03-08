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
  j.gui.i3.enable = true;
  j.gui.firefox.defaultProfile = "personal";
}
