{ lib, config, ... }:
{
  options.j.gui.mime = {
    enable = lib.mkEnableOption "MIME types" // {
      default = config.j.gui.enable;
    };
  };

  config = lib.mkIf config.j.gui.mime.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "sioyek.desktop" ];
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      };
    };
  };
}
