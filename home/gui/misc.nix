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

  config =
    lib.mkIf config.jh.qalc.enable {
      home.packages = with pkgs; [
        qalculate-gtk
      ];
    }
    // lib.mkIf config.jh.nextcloud.enable {
      home.packages = with pkgs; [
        nextcloud-client
      ];
    }
    // lib.mkIf config.jh.keepass.enable {
      home.packages = with pkgs; [
        keepassxc
      ];
    };
}
