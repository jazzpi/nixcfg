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
      autostart = lib.mkEnableOption "Nextcloud autostart" // {
        default = true;
      };
    };
    keepass = {
      enable = lib.mkEnableOption "KeePassXC" // {
        default = false;
      };
    };
    drawio = {
      enable = lib.mkEnableOption "Draw.io" // {
        default = false;
      };
    };
  };

  config = {
    home.packages =
      with pkgs;
      [
        file-roller
      ]
      ++ (lib.optional config.j.gui.qalc.enable qalculate-gtk)
      ++ (lib.optional config.j.gui.nextcloud.enable nextcloud-client)
      ++ (lib.optional config.j.gui.keepass.enable keepassxc)
      ++ (lib.optional config.j.gui.drawio.enable drawio);
    xdg.autostart.entries =
      lib.optionals (config.j.gui.nextcloud.enable && config.j.gui.nextcloud.autostart)
        [
          "${pkgs.nextcloud-client}/share/applications/nextcloud.desktop"
        ];
  };
}
