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
      associations.added = {
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
        "text/plain" = [ "org.gnome.TextEditor.desktop" ];
      };
      defaultApplications = {
        "application/pdf" = [ "sioyek.desktop" ];
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
      };
    };
  };
}
