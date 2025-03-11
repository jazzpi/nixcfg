{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.gui = {
    qalc = {
      enable = lib.mkEnableOption "Qalculate!" // {
        default = config.j.gui.enable;
      };
    };
    nextcloud = {
      enable = lib.mkEnableOption "Nextcloud" // {
        default = false;
      };
    };
    keepass = {
      enable = lib.mkEnableOption "KeePassXC" // {
        default = false;
      };
    };
    vscode = {
      enable = lib.mkEnableOption "Visual Studio Code" // {
        default = config.j.gui.enable && config.j.programming.enable;
      };
    };
  };

  config = {
    home.packages =
      with pkgs;
      (lib.optional config.j.gui.qalc.enable qalculate-gtk)
      ++ (lib.optional config.j.gui.nextcloud.enable nextcloud-client)
      ++ (lib.optional config.j.gui.keepass.enable keepassxc);

    programs.vscode.enable = config.j.gui.vscode.enable;
  };
}
