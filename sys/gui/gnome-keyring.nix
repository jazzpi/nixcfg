{
  lib,
  config,
  ...
}:
{
  options.j.gui.gnome-keyring = {
    enable = lib.mkEnableOption "gnome-keyring" // {
      default = false;
    };
  };
  config = lib.mkIf config.j.gui.gnome-keyring.enable {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm-password.enableGnomeKeyring = true;
    environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";
  };
}
