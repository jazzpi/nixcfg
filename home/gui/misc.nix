{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.jh = {
    qalc = {
      enable = lib.mkEnableOption "Qalculate!" // {
        default = true;
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
  };

  config = {
    home.packages =
      with pkgs;
      (lib.optional config.jh.qalc.enable qalculate-gtk)
      ++ (lib.optional config.jh.nextcloud.enable nextcloud-client)
      ++ (lib.optional config.jh.keepass.enable keepassxc);
  };
}
