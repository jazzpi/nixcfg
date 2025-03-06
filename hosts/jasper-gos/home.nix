{ pkgs, rootPath, ... }:
let
  users = import ../../config/users.nix;
in
{
  home = {
    username = users.default;
    homeDirectory = "/home/${users.default}";
    stateVersion = "24.11";
  };

  j.work.enable = true;
  j.gui.i3.enable = true;
  j.gui.firefox.defaultProfile = "work";
  j.gui.logic.enable = true;

  home.packages = with pkgs; [
    (writeShellScriptBin "setup-slcan" (builtins.readFile "${rootPath}/scripts/setup-slcan"))
  ];
}
