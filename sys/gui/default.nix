{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./i3.nix
    ./logic.nix
    ./wireshark.nix
    ./steam.nix
    ./nvidia.nix
  ];

  config = lib.mkIf config.j.gui.enable {
    services = {
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "altgr-intl";
        };
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
      redshift = {
        enable = true;
        temperature = {
          day = 5500;
          night = 3700;
        };
      };
      geoclue2.enable = true;
    };
    environment.systemPackages = with pkgs; [
      xsel
      xclip
    ];
    location = config.j.location;
  };
}
