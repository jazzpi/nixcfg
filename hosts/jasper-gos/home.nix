{ pkgs, rootPath, ... }:
{
  home.stateVersion = "24.11";

  j.work.enable = true;
  j.gui.i3.enable = true;
  j.gui.firefox.defaultProfile = "work";
  j.gui.logic.enable = true;
  j.gui.gimp.enable = true;

  home.packages = with pkgs; [
    (writeShellScriptBin "setup-slcan" (builtins.readFile "${rootPath}/scripts/setup-slcan"))
  ];
}
